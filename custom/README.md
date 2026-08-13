# Custom layer

This folder is the template for partner- and customer-specific overrides. Use it to add knowledge and skills that apply to your organization but are not appropriate for the shared Microsoft or Community layers.

## Structure

```
custom/
├── knowledge/    # Your organization's knowledge files (same format as /microsoft/knowledge/)
└── skills/       # Your organization's action skills
```

## How to use

Fork or clone BCQuality into your own repository and add your content here. Knowledge files in `/custom/knowledge/` follow the same frontmatter schema and section requirements as every other layer. Action skills in `/custom/skills/` follow the Action Skill template defined in `/skills/`.

When agents consume BCQuality, the custom layer is loaded alongside Microsoft and Community — your overrides apply automatically.

## What this fork adds

This fork populates the layer with ALDC's **project-structure** conventions —
repository and deployment rules that the Microsoft layer deliberately excludes,
since its selective-admission principle covers BC quality knowledge rather than
how a partner organizes and ships a repository.

| Path | Covers |
| --- | --- |
| `knowledge/project-structure/extend-never-modify-base-objects.md` | customizations stay inside the extension model |
| `knowledge/project-structure/al-go-app-test-project-separation.md` | AL-Go `App/` ↔ `Test/` split and dependency direction |
| `knowledge/project-structure/feature-based-folder-organization.md` | source grouped by business feature, not object type |
| `skills/al-project-conventions-review.md` | the leaf action skill that evaluates all three |

`al-project-conventions-review` is intentionally **not** listed in
`al-code-review`'s `sub-skills`. Entry's super-skill precedence only drops a
candidate that the winning super-skill declares, so an unlisted custom leaf is
dispatched *alongside* `al-code-review` — the custom layer extends coverage
without editing a file in the Microsoft layer, which would otherwise turn every
upstream sync into a conflict.

Consumers that relied on ALDC's native A/C/G checks can retire them once this
layer is installed: the same rules are now citable knowledge with a `references`
path, instead of prose in an agent file.
