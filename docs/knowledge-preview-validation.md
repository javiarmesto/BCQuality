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

## Inline invocation follow-up (preview.2)

On 6 October 2026 both public adapters were clarified: in instruction-file hosts,
execute steps 1–5 inline in the caller context. The dispatched action's actual
result remains authoritative; neither dispatches nor citations may be invented.
The package and marketplace now report 0.3.0-knowledge-preview.2 so installs can
identify the updated adapter bodies independently of the original preview tests.

A fresh Copilot CLI test used --plugin-dir with the updated source and
--excluded-tools skill. With the invocation tool disabled, the agent read the
adapter, Entry, READ, DO, the internal knowledge action, and the full
validate-table-relation-false-suppresses-rename-propagation article plus its good
sample. It returned a completed knowledge-response with the exact caller message
and one observed citation. The saved JSON passes schema and citation-read audit.
This is a controlled instruction-only CLI test, not a completed Hogargas Step 5
or a VS Code Copilot Chat execution test. Review-adapter validation is static;
no new full AL review execution is claimed for preview.2.

Deployment consumers must update their actual installed plugin or corpus and
record its new commit as well as the version. ALDC's corpus installer regenerates
an index receipt only in external-multiroot mode; it exits without doing so in
plugin mode. A stale receipt is unverified provenance, not evidence that helpers
automatically switch discovery mode. Follow the loaded provider's recovery rules.
