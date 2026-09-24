---
name: al-knowledge
description: Answer Business Central development questions from BCQuality's installed knowledge articles, with exact citations and no code review. Use for design, specification, or a focused knowledge question.
---

# AL knowledge consultation

This is a thin host-native adapter. Routing, article selection, precedence, and
output policy belong to Entry, READ, DO, and the dispatched action skill.

## Execute

1. Resolve `PLUGIN_ROOT` from the installed plugin's `plugin.json`; this file is
   `PLUGIN_ROOT/skills/al-knowledge/SKILL.md`. Never assume the user's app root
   is the plugin root.
2. Build Entry's `task-context`. Copy the caller's question verbatim into `goal`.
   Set `inputs-available: [knowledge-query]` and bind `knowledge-query` to that
   exact question. Pass `technologies`, `bc-version`, `countries`, and
   `application-area` only when provided or reliably determined. Pass the
   optional `BCQUALITY_ENABLED_LAYERS` and `BCQUALITY_DISABLED_SKILLS` settings
   using the same parsing rules as `al-code-review`.
3. Read and execute `PLUGIN_ROOT/skills/entry.md`, including Preparation,
   resolving all paths against `PLUGIN_ROOT`. If `pwsh` or index generation is
   unavailable, use the documented path-based discovery fallback.
4. Execute only the dispatched action skills with their exact input subsets.
   Read `PLUGIN_ROOT/skills/read.md` and `PLUGIN_ROOT/skills/do.md` on demand.
   Do not call `al-code-review` for this knowledge question, synthesize a
   dispatch, or turn an explanation into a finding.
5. Return the action skill's `knowledge-response` unchanged, or Entry's
   `no-match` / `failed` dispatch record unchanged.
