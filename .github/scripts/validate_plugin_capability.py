#!/usr/bin/env python3
"""Validate the BCQuality plugin capability announcement contract."""

from __future__ import annotations

import json
import pathlib
import subprocess
import sys


EXPECTED_SKILL = "bcquality-al-review"
EXPECTED_PROVIDER = "bcquality-plugin"
CONTEXT_PREFIX = "BCQUALITY_CAPABILITY="


def fail(message: str) -> None:
    raise ValueError(message)


def main() -> int:
    root = pathlib.Path(__file__).resolve().parents[2]
    plugin = json.loads((root / "plugin.json").read_text(encoding="utf-8"))
    hooks_document = json.loads((root / "hooks.json").read_text(encoding="utf-8"))

    if plugin.get("name") != "bcquality":
        fail("plugin.json name must remain 'bcquality'")
    if plugin.get("skills") != [f"./skills/{EXPECTED_SKILL}/"]:
        fail(f"plugin.json must expose only the public skill '{EXPECTED_SKILL}'")
    if plugin.get("hooks") != "./hooks.json":
        fail("plugin.json must reference ./hooks.json")

    if hooks_document.get("version") != 1:
        fail("hooks.json must use schema version 1")
    session_hooks = hooks_document.get("hooks", {}).get("SessionStart", [])
    if len(session_hooks) != 1:
        fail("hooks.json must contain exactly one SessionStart hook")

    hook = session_hooks[0]
    if hook.get("type") != "command":
        fail("SessionStart must be a command hook")
    if not hook.get("windows"):
        fail("SessionStart must include an explicit Windows command")
    if int(hook.get("timeoutSec", 0)) > 5:
        fail("SessionStart timeout must not exceed five seconds")

    command_text = " ".join(str(hook.get(key, "")) for key in ("command", "windows"))
    forbidden = ("curl ", "wget ", "invoke-webrequest", "http://", "https://")
    if any(token in command_text.lower() for token in forbidden):
        fail("SessionStart must not use the network")

    completed = subprocess.run(
        hook["command"],
        cwd=root,
        shell=True,
        check=True,
        capture_output=True,
        text=True,
        timeout=5,
    )
    envelope = json.loads(completed.stdout)
    output = envelope.get("hookSpecificOutput", {})
    if output.get("hookEventName") != "SessionStart":
        fail("hook output must identify SessionStart")

    context = output.get("additionalContext", "")
    if not context.startswith(CONTEXT_PREFIX):
        fail(f"additionalContext must start with {CONTEXT_PREFIX}")
    capability = json.loads(context.removeprefix(CONTEXT_PREFIX))

    expected = {
        "schemaVersion": 1,
        "provider": EXPECTED_PROVIDER,
        "plugin": plugin["name"],
        "pluginVersion": plugin["version"],
        "capabilities": [EXPECTED_SKILL],
        "status": "active",
    }
    if capability != expected:
        fail(f"unexpected capability announcement: {capability!r}")

    print(
        "Plugin capability validation PASSED: "
        f"{plugin['name']} {plugin['version']} announces {EXPECTED_SKILL}."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError, ValueError, json.JSONDecodeError, subprocess.SubprocessError) as error:
        print(f"Plugin capability validation FAILED: {error}", file=sys.stderr)
        raise SystemExit(1)
