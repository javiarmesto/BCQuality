# Plugin capability announcement

BCQuality contributes a small `SessionStart` hook so external orchestrators can
recognize that the plugin is active in the current GitHub Copilot Chat session.
It does not start a review or change the user's request.

## Contract

The hook injects one line of additional context with this shape:

```text
BCQUALITY_CAPABILITY={"schemaVersion":1,"provider":"bcquality-plugin","plugin":"bcquality","pluginVersion":"0.1.0","capabilities":["bcquality-al-review"],"status":"active"}
```

Consumers may prefer `bcquality-al-review` after receiving a valid positive
announcement. They must still handle skill invocation failure and retain their
normal fallback.

No announcement means **availability is unknown**. It does not prove that the
plugin is absent: hooks may be disabled by policy, unsupported by the host, or
unable to run.

The hook performs no network access and writes no files. It only emits the
capability metadata to standard output.

## Validation

Run the static and Linux execution check from the repository root:

```bash
python .github/scripts/validate_plugin_capability.py
```

For GitHub Copilot Chat, start a new session with the plugin enabled and inspect
the GitHub Copilot Chat Hooks output or agent debug log. Confirm that the
announcement appears and that `/bcquality:bcquality-al-review` is available.
Then disable the plugin, start another new session, and confirm that neither the
announcement nor the skill is available.

Windows execution must also be verified manually in a new VS Code session before
the contract is proposed upstream.
