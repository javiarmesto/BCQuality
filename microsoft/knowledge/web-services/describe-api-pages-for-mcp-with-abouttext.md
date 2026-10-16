---
bc-version: [21..]
domain: web-services
keywords: [api-page, api-query, abouttext, abouttitle, mcp, tool-description, agents, entitysetcaption]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Describe API pages and queries with `AboutText` for MCP tools

## Description

The Business Central MCP server exposes API pages and API queries as tools, and an agent picks a tool by reading its description. The server builds that description from `AboutText` first, then falls back to `EntitySetCaption`, then to the camelCase `EntityName`. An API page without `AboutText` therefore reaches the agent as a bare plural noun, with nothing about what the entity holds, which rows it returns or which values are computed. LLMs treat `AboutText` and `AboutTitle` as UI teaching-tip properties and leave them off API objects, because API pages are never shown in the client. The compiler and the analyzers do not flag the omission.

## Best Practice

On every `PageType = API` page and `QueryType = API` query that may be exposed as an MCP tool, set `AboutText` to one or two sentences. Say what one record is, which records the endpoint returns (filters, document types, scope) and any value that is computed at read time instead of stored. Set `AboutTitle` as well, since the platform expects the pair. Write it for a reader who only sees the tool list, and keep it consistent with `EntityCaption` and `EntitySetCaption`.

See sample: [`describe-api-pages-for-mcp-with-abouttext.good.al`](describe-api-pages-for-mcp-with-abouttext.good.al).

## Anti Pattern

An API page or API query with no `AboutText`, or with a value that only repeats the entity name, such as "Margin lines". The agent cannot tell the endpoint apart from similar ones, or know that a field like a margin percentage is recalculated live. It then picks the wrong tool or misreads the data. The detection signal: a `PageType = API` page or `QueryType = API` query that does not set `AboutText`.

See sample: [`describe-api-pages-for-mcp-with-abouttext.bad.al`](describe-api-pages-for-mcp-with-abouttext.bad.al).

## References

- [AboutText property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-abouttext-property)
- [API page type: describe the API for MCP tools](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-api-pagetype#describe-the-api-for-mcp-tools)
