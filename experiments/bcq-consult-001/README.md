# BCQ-CONSULT-001 — Pre-code AL technical consultation

## Status

Experimental design on `experiment/bcq-consult-001`.

This experiment tests a second public BCQuality capability for **pre-code technical decision support**:

- `bcquality-al-review` remains the code-review capability for real AL source/diffs.
- proposed `bcquality-al-consult` answers bounded AL technical-pattern questions before implementation.

The experiment must not weaken or overload `bcquality-al-review`.

## Problem

`bcquality-al-review` is intentionally designed around review inputs such as `pr-diff` and `file-path`. Architecture and specification agents sometimes need a different question:

> Is this proposed AL pattern supported/recommended by the knowledge in BCQuality, under these constraints?

Trying to satisfy that question by manually reading BCQuality knowledge files and then labelling the result as a code review loses provenance and confuses consultation with review.

## Goal

Provide a citable, structured **Consult Report** that helps an architecture/specification agent decide whether a proposed AL technical pattern is:

- `supported`
- `conditionally-supported`
- `unsupported`
- `insufficient-evidence`

The consultation must explicitly say what BCQuality can and cannot prove.

## Non-goals

`bcquality-al-consult` MUST NOT:

- review a PR, diff or real AL file;
- emit blocker/major/minor review findings;
- verify Base Application object/event existence or signatures (Symbols territory);
- prove Base Application call order/placement (BC Code Atlas territory);
- claim official runtime guarantees beyond the cited knowledge (Microsoft docs/runtime tests territory);
- generate implementation code.

## Proposed public capability

```text
bcquality-al-consult
        ↓
Entry
        ↓
goal = assess AL technical pattern
inputs-available = [technical-question]
        ↓
consult action skill(s)
        ↓
BCQuality knowledge retrieval + applicability + precedence
        ↓
Consult Report
```

The bridge is conceptually parallel to `bcquality-al-review`, but with a different input/output contract.

## Proposed task context

```yaml
task-context:
  goal: "Assess an AL technical pattern"
  inputs-available: [technical-question]
  technologies: [al]
  bc-version: 28
  countries: [w1]
  application-area: [all]
  enabled-layers: [microsoft, community, custom]
  disabled-skills: []

technical-question:
  question: "Can this pattern satisfy the stated constraints?"
  candidate-pattern:
    - "TryFunction around Record.Insert"
    - "Session.LogMessage on failure"
    - "no Commit"
  constraints:
    - "audit failure must not fail posting"
    - "caller transaction must not be altered"
  evidence-needed:
    - "quality suitability"
```

`technical-question` is deliberately abstract: no customer data, proprietary code or implementation file is required.

## Proposed Consult Report

```json
{
  "skill": { "id": "al-technical-consult", "version": 1 },
  "outcome": "supported | conditionally-supported | unsupported | insufficient-evidence | failed",
  "assessment": "short conclusion",
  "conditions": ["condition that must hold"],
  "risks": ["known risk"],
  "rejected-patterns": ["pattern rejected by cited knowledge"],
  "unproven": ["claim BCQuality cannot prove"],
  "references": [
    { "path": "microsoft/knowledge/...", "sha": "optional" }
  ],
  "confidence": "high | medium | low",
  "routing": {
    "entry-outcome": "routed",
    "skills-run": ["al-technical-consult"]
  }
}
```

### Outcome semantics

- `supported`: cited BCQuality normative guidance supports the pattern for the supplied context and no material condition remains inside BCQuality's domain.
- `conditionally-supported`: the pattern is acceptable only when named conditions hold.
- `unsupported`: cited normative guidance rejects or conflicts with the pattern.
- `insufficient-evidence`: BCQuality cannot establish the requested property; the report MUST state the unresolved claim and suggest the appropriate external evidence domain without pretending it was executed.
- `failed`: the consultation pipeline itself failed; no reliable conclusion.

`insufficient-evidence` is a first-class successful research outcome, not a tool failure.

## Provider boundaries

| Question | Provider |
|---|---|
| Does this target object/event/signature exist? | `al-symbols-mcp` |
| Where/how does Base Application execute it? | `bc-code-atlas` |
| Is this AL engineering pattern recommended/known-risky? | `bcquality-al-consult` |
| What does the runtime officially guarantee? | `microsoftdocs/mcp` / runtime test |
| Does the real implementation comply with quality guidance? | `bcquality-al-review` |

Consult must never convert a quality recommendation into a runtime guarantee.

## Entry / DO contract impact

Current Entry routes `kind: action-skill` candidates by goal + input intersection, so a consult action skill can be discovered if it declares `inputs: [technical-question]`.

However the current DO contract defines only `findings-report` as an action-skill output. A clean implementation therefore requires an explicit contract decision before code is added:

### Option A — extend DO

Allow action skills to declare `outputs: [findings-report | consult-report]` and define Consult Report semantics in DO or a linked meta-contract.

Pros: Entry remains generic; consultation is another action-skill job.

### Option B — introduce `consult-skill`

Add a new skill kind and extend Entry to route both `action-skill` and `consult-skill`.

Pros: hard semantic separation.

Cons: larger change to the stable Entry contract and more parser/orchestrator impact.

### Experiment decision

Start with **Option A** because Entry is already intentionally generic and routes by inputs + goal. Keep review and consultation separated by their public bridges and output contracts, not by duplicating the routing architecture.

No stable contract file is modified in Phase 0.

## Evaluation cases

The prototype must pass at least these cases before any upstream PR is proposed:

1. **OQ-1 TryFunction / transaction-isolation case** — expected result should not claim runtime transaction isolation unless BCQuality knowledge actually proves it. `insufficient-evidence` or `conditionally-supported` is acceptable.
2. **Codeunit.Run inside an existing write transaction** — should identify relevant known constraints from cited knowledge without reviewing source code.
3. **Simple supported pattern** — a technical pattern with clear normative BCQuality best-practice support should return `supported` with references.
4. **No relevant knowledge** — must return `insufficient-evidence`, never fabricate a recommendation.
5. **Review regression** — `bcquality-al-review` behavior and output remain unchanged.

## Acceptance gates

BCQ-CONSULT-001 is viable only if:

- Entry routes consultation deterministically from `technical-question`;
- the public bridge can be explicitly invoked as `bcquality-al-consult`;
- the result carries real BCQuality paths/references;
- `insufficient-evidence` is preserved instead of model inference being promoted to BCQuality evidence;
- no review severities/findings are emitted by consultation;
- `bcquality-al-review` regression tests remain green;
- the OQ-1 field case produces a more truthful result than manual knowledge-file reading.

## Planned phases

### Phase 0 — contract design

- [x] define capability boundary;
- [x] define proposed task context;
- [x] define proposed Consult Report;
- [x] define provider boundaries;
- [x] define evaluation cases;
- [ ] review the contract against Entry/READ/DO maintainers' invariants.

### Phase 1 — minimal prototype

- [ ] extend DO output contract to include `consult-report` (minimal compatible change);
- [ ] add `microsoft/skills/consult/al-technical-consult.md`;
- [ ] add `skills/bcquality-al-consult/SKILL.md` bridge;
- [ ] add routing/contract tests;
- [ ] keep `bcquality-al-review` unchanged.

### Phase 2 — field validation

- [ ] execute OQ-1 through `bcquality-al-consult`;
- [ ] execute two additional synthetic consultation cases;
- [ ] compare consultation output with subsequent `bcquality-al-review` on real implementation;
- [ ] record false certainty / missing-evidence behavior.

### Phase 3 — upstream proposal

Only after Phase 2 passes:

- [ ] prepare a focused upstream PR;
- [ ] document backward compatibility;
- [ ] include evaluation evidence;
- [ ] avoid ALDC-specific terminology in the upstream feature contract.
