# ALDC agents and BCQuality: plugin and external multiroot

These diagrams describe the ALDC agent contracts as consulted while preparing
this fork. This branch identifies itself as plugin version
`0.3.0-knowledge-preview.1`; it has not been released or validated in a host.
They document **current** review access, the **current** multiroot
read path for Architect and Spec, and the **proposed** `al-knowledge` plugin
path provided by this branch. Adding a skill to BCQuality does not by itself
change ALDC's agent contracts or establish host execution evidence.

## Two access paths

| Purpose | Plugin | External multiroot |
| --- | --- | --- |
| Consult knowledge during architecture or specification | **Proposed integration:** host discovers this fork's `al-knowledge` skill; its adapter passes `knowledge-query` to Entry; the dispatched action reads articles and returns `knowledge-response`. ALDC still needs to adopt this read path. | **Current ALDC path:** Architect and Spec read the external corpus at configured `home`, applying the design-guidance selection contract. No review skill executes. |
| Review an AL increment or audit | **Current ALDC configuration:** host discovers the configured `bcquality` plugin and `al-code-review`; adapter enters Entry and returns the actual review result. | **Current ALDC configuration:** host reads configured `home/entryPoint`, usually `skills/entry.md`, then executes its actual dispatch. |
| Identity and fallback | Observe plugin identity, loaded body, actual results, and index status independently. A plugin installation cannot silently become a multiroot checkout. | Observe corpus revision and actual Entry execution. Failure or missing domain coverage retains ALDC native review. |

The plugin and multiroot paths can be different BCQuality revisions. Never
equate their citations or coverage without checking observed provenance.
For knowledge consultations, `knowledge-response` is guidance, not a review
finding or an approval gate. A discovered skill is not an executed action.

## Agent infographics

| Agent | BCQuality relationship | Infographic |
| --- | --- | --- |
| AL Architect | Reads guidance for design constraints; plugin skill is proposed | [Architect](infographics/architect.svg) |
| AL Spec Agent | Reads guidance for review criteria; plugin skill is proposed | [Spec Agent](infographics/spec.svg) |
| AL Conductor | Resolves provider selection and passes scoped review context | [Conductor](infographics/conductor.svg) |
| AL Review Subagent | Executes review for a phase | [Review Subagent](infographics/review-subagent.svg) |
| AL Developer Reviewer | Independent read-only review | [Developer Reviewer](infographics/developer-reviewer.svg) |
| Dredd | On-demand codebase audit | [Dredd](infographics/dredd.svg) |
| AL Triage | Optional focused consultation during diagnosis | [Triage](infographics/triage.svg) |
| AL Planning Subagent | Records the Conductor's decision; never probes provider | [Planning Subagent](infographics/planning.svg) |

Agents without a BCQuality step (for example AL Developer) are omitted. This
is an integration explainer; the authoritative ALDC contracts live in
[`javiarmesto/ALDC-AL-Development-Collection`](https://github.com/javiarmesto/ALDC-AL-Development-Collection),
especially `docs/bcquality.md`, `docs/templates/bcquality-provider-contract.md`,
`docs/templates/bcquality-design-guidance.md`, and the role files under
`agents/`. The BCQuality protocol lives in `skills/entry.md`, `skills/read.md`,
and `skills/do.md` in this fork.

## Example knowledge request

After installing **this fork's branch** in a host capable of exposing its
skills, ask:

> Use `al-knowledge` to explain when SetLoadFields is useful in Business
> Central AL. Cite the articles you read. Do not review my app.

The adapter binds the exact question as `knowledge-query`. The action skill
returns a cited `knowledge-response`; it does not call `al-code-review`.
