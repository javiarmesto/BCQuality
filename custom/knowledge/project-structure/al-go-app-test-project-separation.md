---
bc-version: [all]
domain: project-structure
keywords: [al-go, app-folder, test-folder, project-layout, app-json, dependency, test-project]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep the AL-Go `App/` and `Test/` projects separate, with the dependency one way only

## Description

An AL-Go repository holds two AL projects: the shipping extension under `App/` and its automated tests under `Test/`. Each has its own `app.json`. The `Test/` project declares a dependency on the `App/` project; **`App/` never declares a dependency on `Test/`**, and test objects never live inside `App/`.

The direction of that dependency is the whole point. It is what lets the shipping extension be built, signed and published without the test project, its `Library-*` fixtures, or its `Subtype = Test` codeunits being compiled into the customer's tenant. Invert it — or place a single test codeunit under `App/src/` — and the test surface becomes part of the delivered app: test fixtures ship to production, the AppSource submission carries objects it should not, and the build can no longer produce a clean artifact without also satisfying the test project.

The mirror rule follows from the same idea: `Test/` reproduces `App/`'s feature folders (`App/src/Sales/Invoice/…` → `Test/src/Sales/Invoice/…`), with shared helpers under `Test/src/Common/`, so a reviewer can find the tests for a feature without searching.

## Best Practice

Application objects under `App/src/`, test objects under `Test/src/`. `Test/app.json` lists the app in its `dependencies`; `App/app.json` lists nothing from `Test/`. Mirror the feature-folder tree across both projects and keep shared test helpers in `Test/src/Common/`. A test codeunit is identified by `Subtype = Test` and belongs in the test project no matter which feature it exercises.

See sample (project layout is structural; no AL sample shipped here).

## Anti Pattern

A `Subtype = Test` codeunit under `App/src/`; a `Library-*` fixture codeunit shipped in the app project; `App/app.json` declaring a dependency on the test app; a flat `Test/src/` with no correspondence to the app's feature folders; or a single project holding both application and test objects.
