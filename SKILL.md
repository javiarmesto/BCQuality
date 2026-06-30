---
name: bcquality
description: Business Central / AL quality knowledge base and skills. Use when reviewing or generating Business Central (AL) code, pipelines, APIs, telemetry, or AppSource artifacts, and a consistent BC-specific quality bar is needed. Routes the task to the action skill(s) that apply (performance, security, privacy, upgrade, style, UI) and grounds findings in a curated BC knowledge corpus.
license: MIT
---

# BCQuality

Quality knowledge and skills for Business Central development, packaged as a
single, self-contained skill bundle. Everything an agent needs ships inside
this directory: the routing entry-point, the meta-skill contracts, the action
skills, and the full knowledge corpus.

This `SKILL.md` is the **initialization skill** — a thin entry-point that
preserves BCQuality's original consumption model. It does **not** reimplement
routing. The canonical routing logic lives untouched in
[`skills/entry.md`](skills/entry.md), exactly as it does in the upstream
BCQuality repository. This file only adapts that contract to the
agentskills.io / APM runtime so the bundle can be distributed and installed
as a unit.

## How to use this skill

When invoked, follow BCQuality's original flow — do not shortcut it:

1. **Invoke the entry-point.** Read [`skills/entry.md`](skills/entry.md) and run
   it against the task context the orchestrator supplied (goal, inputs
   available, technologies, BC version, countries, application area, enabled
   layers). Entry returns a **dispatch record** naming the action skill(s) to
   invoke. Routing is a skill, not orchestrator logic.
2. **Read the contracts on demand.** When the first dispatched skill runs, read
   [`skills/read.md`](skills/read.md) (how to interpret knowledge-file
   frontmatter and layer precedence) and [`skills/do.md`](skills/do.md) (the
   action-skill four-step pattern and output contract). These are not
   prerequisites for invoking Entry.
3. **Execute each dispatched action skill.** For every entry in the dispatch
   record, read the referenced action skill (e.g.
   [`microsoft/skills/review/al-code-review.md`](microsoft/skills/review/al-code-review.md))
   and execute its Source -> Relevance -> Worklist -> Action steps, grounding
   each finding in the knowledge files it cites.
4. **Return structured output.** Emit the findings-report(s) in the common JSON
   format defined by `skills/do.md` so the orchestrator can consume them
   without skill-specific parsing.

## What ships in this bundle

The entire BCQuality tree is copied verbatim into the consumer's
`skills/bcquality/` directory, preserving every relative path the skills rely
on:

- **`skills/`** — the `entry.md` entry-point plus the READ / DO / WRITE
  meta-skill contracts.
- **`microsoft/`** — Microsoft-endorsed layer (`knowledge/` + `skills/`).
- **`community/`** — BC community layer (`knowledge/` + `skills/`).
- **`custom/`** — partner/customer overrides (empty by default; populated in
  forks).

The knowledge corpus — the bulk of BCQuality — travels as bundle assets. APM
has no dedicated "knowledge" primitive, so distributing BCQuality as one skill
bundle is what keeps the corpus, the layer precedence model, and the
skill-to-knowledge relative references intact. All three layers are enabled by
default, matching BCQuality's design.

## Relationship to the upstream repository

This bundle is a faithful repackaging, not a fork of behaviour. `skills/entry.md`,
`skills/read.md`, `skills/do.md`, `skills/write.md`, and every action skill and
knowledge file are byte-for-byte the upstream content. The only additions are
this `SKILL.md` (the initialization entry-point) and `apm.yml` (the manifest
that turns the repository into a distributable HYBRID package). See the
[README](README.md) and [agent-consumption.md](agent-consumption.md) for the
full design rationale.
