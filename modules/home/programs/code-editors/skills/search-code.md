---
name: search-code
description: Search code context with Context7 and Exa. Combines library docs, web results, and real snippets for API usage, configuration, and debugging help.
context: fork
---
# Search Code

## Tool Usage (Critical)

Always run all of these in parallel and combine the results:

- Context7 docs lookup
- Exa `get_code_context_exa`
- Exa `web_search_exa`

Do not stop after the first useful result. Cross-check the sources and synthesize one answer.

## Token Isolation (Critical)

Never run the tools in main context. Always spawn Task agents:

- Agent runs Context7 docs lookup, Exa `get_code_context_exa`, and Exa `web_search_exa`
- Agent extracts the minimum viable snippet(s), official API details, and setup constraints
- Agent deduplicates near-identical results such as mirrors, forks, repeated StackOverflow answers, and duplicate docs examples before presenting
- Agent resolves conflicts in favor of official docs, then validates with real-world examples
- Agent returns copyable snippets plus a brief explanation
- Main context stays clean regardless of search volume

## When to Use

Use these tools for any programming-related request:

- API usage and syntax
- SDK or library examples
- config and setup patterns
- framework how-to questions
- debugging when you need authoritative snippets

Default source roles:

- Context7: official or current library and framework documentation
- Exa `get_code_context_exa`: real code snippets and implementation patterns
- Exa `web_search_exa`: broader web results, issue threads, troubleshooting, release notes, and ecosystem context

## Inputs (Supported)

`get_code_context_exa` supports:

- `query` (string, required)
- `tokensNum` (number, optional; default about 5000; typical range 1000 to 50000)

`web_search_exa` supports a normal web query. Use it to confirm edge cases, error messages, and recent changes.

Context7 should be used to retrieve the matching library docs before presenting any library-specific guidance.

## Query Writing Patterns (High Signal)

To reduce irrelevant results and cross-language noise:

- Always include the programming language in the query. Example: use `Go generics` instead of just `generics`.
- When applicable, also include framework plus version, such as `Next.js 14`, `React 19`, or `Python 3.12`.
- Include exact identifiers such as function names, class names, config keys, and error messages when you have them.

## Dynamic Tuning

Token strategy:

- Focused snippet needed: `tokensNum` 1000 to 3000
- Most tasks: `tokensNum` 5000
- Complex integration: `tokensNum` 10000 to 20000
- Only go larger when necessary to avoid dumping large context

## Output Format (Recommended)

Return one combined result:

1. Best minimal working snippet(s) that stay copy-paste friendly
2. Notes on version, constraints, and gotchas
3. A short synthesis of what Context7 docs say versus what Exa examples show
4. Sources, including URLs when present in returned context

Before presenting:

- Deduplicate similar results and keep only the best representative snippet per approach
- Prefer Context7 for canonical API behavior and Exa results for practical usage examples
- If sources disagree, say so explicitly and explain which result you trust more
