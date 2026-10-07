---
kind: action-skill
id: al-knowledge
version: 1
title: AL knowledge consultation
description: Answer a Business Central development question with cited knowledge, without reviewing source code.
inputs: [knowledge-query]
outputs: [knowledge-response]
---

# AL knowledge consultation

`knowledge-query` is the caller's exact question. This skill accepts optional
target context from Entry. It does not require an app, a file, or a diff.

## Source

Search `knowledge-index.json` for matching domains, titles, descriptions, and
keywords across enabled layers. Resolve the index against BCQuality's root.
When the index could not be generated, discover candidate article paths in
`<enabled-layer>/knowledge/**/` instead. The index is discovery metadata,
never the article body or evidence of applicability.

## Relevance

Apply READ's frontmatter matching rules for any known BC version, technology,
country, and application area. Exclude definite mismatches. Keep conditional
matches with their exact unknown dimensions. Interpret competing articles and
layer precedence under READ; record any displaced article in `suppressed`.

## Worklist

Choose the smallest set of articles that answers the actual question. Match
the question's concepts to article descriptions, filenames, and keywords.
Open each chosen article in full, including relevant sibling samples if cited
by that article. If the question spans domains, select each necessary domain;
do not turn a narrow question into an exhaustive corpus summary. Do not cite
an article merely because it appeared in the index.

## Action

Answer only what the read articles support. State conditions, exceptions,
unknown target dimensions, and any unresolved conflict. Cite exact article
paths in the answer and `references`; do not infer a path from a title. This
is guidance, not a code review: do not inspect source to produce defects,
invoke review action skills, emit severities, or generate a findings-report.
If no applicable article answers the question, return `no-knowledge` instead
of filling the gap from general model knowledge under BCQuality's name.

## Output

Return one JSON value following `schemas/knowledge-response.schema.json` and
DO's knowledge-response rules. `question` preserves the caller's question.
`completed` requires at least one fully read, checked reference. `partial`
requires a reason and only cites articles actually read; `failed` cites none.
Illustrative response after reading the cited article:

    {"skill":{"id":"al-knowledge","version":1},"outcome":"completed",
     "question":"When is SetLoadFields useful?","answer":"For a wide table when the procedure reads only a few fields, consider SetLoadFields before the read (`microsoft/knowledge/performance/use-setloadfields-for-partial-records.md`).",
     "references":[{"path":"microsoft/knowledge/performance/use-setloadfields-for-partial-records.md",
                    "applicability":"applicable","unknown":[]}],"suppressed":[]}
