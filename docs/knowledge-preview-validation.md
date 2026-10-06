# Knowledge preview: local validation

On 5 October 2026 the branch based on
`9b85a40ad6eaf8cd968fabafd82d73b8253fc0fb` was tested on Windows.
This is evidence from limited cases, not a release or a general conformance claim.
The local preparation also corrected omitted skill-index filters (empty arrays
instead of null) and aligned the marketplace version with the root manifest.

## Static checks

Frontmatter validation passed with no errors or warnings. Knowledge retrieval
round-tripped 307 articles and 507 samples. Review-contract checks passed eight
cases; review fixtures cover 70 cases and 18 leaf domains. The skill index
preserves the 17 Microsoft review leaves and admits only `al-knowledge` for
`knowledge-query`. The response schema has positive and negative cases covering
conditional unknown dimensions, missing reasons, empty completed citations,
and prohibition of citations for failed/no-knowledge responses.

Static routing checks establish input compatibility, not actual agent dispatch.
A schema cannot prove that an article was read or that it supports an answer.

## Actual host tests

Each host installed the local preview independently. All observed manifests
reported `0.3.0-knowledge-preview.1` and exposed `al-code-review` and
`al-knowledge`. The installed copies must not be confused with the mutable
development checkout or the Microsoft `0.2.0` plugin.

The initial question was:

> Use the installed al-knowledge skill to explain when SetLoadFields is useful
> in Business Central AL. Cite the BCQuality articles you read. Do not review
> my app.

| Host | Observed execution |
| --- | --- |
| Copilot CLI 1.0.91 | Loaded the adapter, Entry, knowledge action and articles. The first run returned prose, violating the declared output contract. A fresh run explicitly requesting unchanged JSON and the exact caller message returned a schema-valid response and three citations with observed article reads. |
| Claude Code 2.1.286 | Loaded the plugin and returned schema-valid JSON with six citations backed by observed reads, but reformulated `question`, violating input fidelity. A separate performance review of the SetLoadFields bad sample dispatched `al-performance-review` and returned one finding. |
| Codex CLI 0.160.0 | In read-only mode, with explicit path-discovery fallback, returned schema-valid JSON preserving the complete question and citing four articles read from the installed plugin; companion samples were also read. A separate DataTransfer question with unknown BC version correctly returned a conditional reference with `unknown: [bc-version]`. |

Some index/shell operations were denied under the test permissions. Those runs
used the documented path-based fallback; discovery does not prove successful
index generation. Successful output in one run does not erase a contract
violation in another. Copilot Chat in VS Code was not validated by these CLI
installations. No AL app compilation, tenant tests, full model evaluation, or
ALDC knowledge-plugin adoption is claimed.

The local handoff keeps complete transcripts, tool calls, extracted results,
validation logs and installation provenance. Reproduce in a new session and
record expected version, observed version, installed root, source revision or
file hashes, actual article reads and the unmodified action result separately.
