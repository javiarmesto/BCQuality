---
bc-version: [all]
domain: ui
keywords: [onaftergetrecord, page-variable, global-variable, computed-field, stale-value, repeater, api-page, clear]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reset per-row page variables at the start of `OnAfterGetRecord`

## Description

A list, subpage or API page often shows values that are computed per record into global page variables in `OnAfterGetRecord`. Those variables live on the page object, not on the record, so they keep whatever the previous row left in them. When the computation only assigns some variables on some paths (an early `exit`, a lookup that finds nothing, a branch that applies only to certain lines), the current row silently shows the previous row's values. In a repeater this is visible only on some rows; through OData or MCP it ships wrong data that looks plausible. LLMs write the happy path, assigning each variable where it is computed, and do not reset the others. The compiler and the analyzers do not catch it.

## Best Practice

Start `OnAfterGetRecord` by resetting every per-row variable, with `Clear` on each one or a single helper procedure that clears the whole set. Then compute. Every exit path then leaves defined values, such as zero, empty or the "not applicable" status, instead of the previous record's. Keep the per-row variables together, so the reset list stays complete when a new one is added.

See sample: [`reset-per-row-page-variables-in-onaftergetrecord.good.al`](reset-per-row-page-variables-in-onaftergetrecord.good.al).

## Anti Pattern

An `OnAfterGetRecord` that assigns page variables only inside conditions or after a lookup that can fail, and never resets them first. A row without an authorization entry, for example, shows the previous row's authorized-by user and exception number. The detection signal: a global variable assigned in `OnAfterGetRecord` on a path that can be skipped, with no `Clear` or reset of that variable at the start of the trigger.

See sample: [`reset-per-row-page-variables-in-onaftergetrecord.bad.al`](reset-per-row-page-variables-in-onaftergetrecord.bad.al).
