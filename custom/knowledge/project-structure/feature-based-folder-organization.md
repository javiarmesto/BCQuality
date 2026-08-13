---
bc-version: [all]
domain: project-structure
keywords: [folder-structure, feature-folder, src, organization, object-type-folder, common, shared]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Organize source folders by business feature, not by object type

## Description

Source under `src/` is grouped by the business capability the objects serve — `src/Sales/Invoice/`, `src/Inventory/Replenishment/` — with code shared across features in `src/Common/` or `src/Shared/`. Folders named after AL object types (`Tables/`, `Pages/`, `Codeunits/`, `Reports/`) are not used.

Type folders look tidy and are actively unhelpful. Every feature is scattered across four or five directories, so the objects that change together are never adjacent; a reviewer reading a pull request cannot see a feature's surface in one place, and a developer removing a capability has to hunt for its pieces by name. Type is already visible in the file name (`PostSalesInvoice.Codeunit.al`) and in symbol search, so encoding it a second time in the path buys nothing. Feature folders, by contrast, make the extension's shape legible: the directory listing *is* the feature list.

The rule scales downward, not just at the top level. A feature large enough to have distinguishable parts gets sub-folders for them (`src/Sales/Invoice/`, `src/Sales/Credit Memo/`) rather than one flat folder holding forty files.

## Best Practice

`src/<Feature>/<SubFeature>/…`, named for business capabilities as the domain experts describe them. Cross-cutting helpers in `src/Common/` or `src/Shared/`. Keep the objects that implement one feature — its table extensions, pages, codeunits, permission sets and enums — together in that feature's folder. Mirror the same tree in the test project.

See sample (folder organization is structural; no AL sample shipped here).

## Anti Pattern

`src/Tables/`, `src/Pages/`, `src/Codeunits/`, `src/Reports/` as the top-level split; a flat `src/` holding every object; folders named after technical layers (`src/Data/`, `src/UI/`) instead of business features; or a feature whose objects are split across type folders so that no directory shows the feature as a whole.
