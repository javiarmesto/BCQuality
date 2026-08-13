---
kind: action-skill
id: al-project-conventions-review
version: 1
title: AL project conventions review
description: Reviews AL source changes against project-structure conventions — extension-only customization, AL-Go App/Test separation, and feature-based folder organization.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL project conventions review

Reviews AL source changes against the `project-structure` knowledge domain and emits a findings report. This is a leaf action skill: it invokes no sub-skills.

This skill exists because the concerns it covers are **repository and deployment conventions**, not BC quality knowledge in the sense the Microsoft layer curates: whether a customization stays inside the extension model, whether the AL-Go projects are separated in the supported direction, and whether source is grouped by business feature. They are evaluated from paths, object declarations and `app.json`, and they are decided by the consuming organization — which is why they live in the `custom` layer.

It is **not** listed in `al-code-review`'s `sub-skills`, so Entry dispatches it alongside that super-skill rather than having it superseded. An orchestrator invokes it with either a `pr-diff` or a `file-path`. The skill produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone). Take the index entries whose `domain` is `project-structure` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below.

Unlike the code-shaped domains, this skill's evidence is largely **structural**: the set of changed file paths, the object declarations at the top of each changed file, and the `app.json` of each project touched. Read those from the task input; never infer a project's layout from object names alone.

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version` — from the consuming app's `app.json`, or `unknown` when unavailable.
- `technologies` — `[al]`.
- `countries` — from the consuming app's `app.json`; `unknown` when absent.
- `application-area` — the actual set declared by the changed objects; do not substitute `[all]`.

These conventions are version- and country-independent in practice, so an `unknown` dimension rarely excludes an article here. It still caps `confidence` at `medium` per READ, and the unknown dimension must be named in `message`.

## Worklist

Narrow the relevant files to the subset that applies to the change. Compute overlap against:

- **Object declarations in changed files** — the declaration line of each changed `.al` file: object type, ID, name, and any `extends` clause.
- **Changed file paths** — every path segment between the project root and the file, plus the project prefix (`App/`, `Test/`, or neither).
- **Project manifests** — `app.json` `id`, `name`, `idRanges` and `dependencies` for each project in the change.
- Tokens extracted from the diff (`tableextension`, `pageextension`, `reportextension`, `enumextension`, `EventSubscriber`, `Subtype = Test`, `Library-`, `Assert`, `dependencies`, `idRanges`).

High-signal mappings, applied before fuzzy topic ranking:

- A changed file declares a base object type at an ID **outside** the extension's declared `idRanges` — or an object whose ID falls in the base application's range — → `extend-never-modify-base-objects.md`.
- A `Subtype = Test` codeunit, or a `Library-*` fixture, at a path under the app project → `al-go-app-test-project-separation.md`.
- An `app.json` under the app project gaining a dependency on the test app → `al-go-app-test-project-separation.md`.
- A new source path whose first segment under `src/` is an AL object type (`Tables`, `Pages`, `Codeunits`, `Reports`, `Queries`, `XmlPorts`, `Enums`) → `feature-based-folder-organization.md`.

Judge folder organization from the **change under review**, not from the repository's whole history. A pre-existing type-folder layout that this change merely adds one more file to is a finding at most once, against that change's own files; do not re-litigate the entire tree in every review, and never emit one finding per pre-existing file.

When the post-conflict worklist is empty because no applicable project-structure knowledge exists, emit `outcome: "no-knowledge"`. When it is empty because nothing in the change matched, emit `outcome: "completed"` with an empty `findings` array. When the change contains no AL objects and no project manifests, emit `outcome: "not-applicable"`.

## Action

For each worklist entry, evaluate the change against the article's `## Best Practice` and `## Anti Pattern` sections.

Severity calibration — these conventions differ sharply in consequence, so do not flatten them:

- **`blocker`** — a customization outside the extension model: a base object re-declared, base source copied into the extension, or a base ID used by an extension object. The extension cannot be supported across a base-application update, so this is not a preference.
- **`major`** — the AL-Go dependency inverted (`App/` depending on the test project), or test objects/`Library-*` fixtures inside the app project. The shipping artifact is contaminated: test surface reaches production and the app can no longer build independently.
- **`minor`** — feature-folder organization, including type-named folders and a feature split across directories. Real maintainability cost, no delivery or upgrade consequence.

Never raise a folder-organization finding above `minor` and never lower an extension-model finding below `blocker`; the gap between them is the point of this skill.

Set `confidence` to `high` when the judgment rests on an unambiguous structural fact (a declared ID, a manifest dependency, a literal path segment), `medium` when it relies on a heuristic or any frontmatter dimension was `unknown`, and `low` for advisories derived only from applicability.

After evaluating each worklist entry, consider whether the change exhibits a project-structure defect that no worklisted article covers. Emit those as agent findings — `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing both the issue and a concrete recommendation. Hold them to the precision bar in `skills/do.md` (*Agent findings*). The scope is strictly project structure: a defect in what the code *does* belongs to a behavioural domain leaf, not here, even when it can be reworded as a layout concern.

**`suggested-code` almost never applies in this domain.** The fixes are file moves, project relocations and manifest edits, not literal line replacements — so omit it and set `suggested-code-omission-reason` (for example, "fix is a file move from App/src/ to Test/src/, not a source edit"). Emit `suggested-code` only for a genuinely local manifest edit, such as removing one entry from a `dependencies` array.

Outcome selection:

- `completed` — every worklist item was evaluated.
- `no-knowledge` — no applicable project-structure knowledge survived filtering.
- `not-applicable` — the change contains no AL objects and no project manifests.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. Every finding this skill emits MUST set `findings[].domain` to `"Project Structure"`. A populated example:

```json
{
  "skill": { "id": "al-project-conventions-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "custom/knowledge/project-structure/al-go-app-test-project-separation.md",
      "severity": "major",
      "message": "MTLImportTests.Codeunit.al declares Subtype = Test but sits under App/src/MonthlyTypeLiquidation/. Test objects belong in the Test/ project: the App/ project must build and ship without them, and a test codeunit inside it puts test surface into the delivered extension.",
      "location": {
        "file": "App/src/MonthlyTypeLiquidation/MTLImportTests.Codeunit.al",
        "line": 1
      },
      "references": [
        { "path": "custom/knowledge/project-structure/al-go-app-test-project-separation.md" }
      ],
      "confidence": "high",
      "domain": "Project Structure",
      "suggested-code-omission-reason": "Fix is a file move to Test/src/MonthlyTypeLiquidation/, not a source edit."
    }
  ],
  "suppressed": []
}
```
