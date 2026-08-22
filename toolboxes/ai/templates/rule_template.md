---
# Optional frontmatter — omit entirely for a static rule that always applies

# agent: code                    # restrict to one agent, or a list:
# agent:
#   - code
#   - plan

# model: ".*grok.*"              # regex matched against the full model id

# paths: "features/**/*.feature" # path-scoped rule (glob); makes it on-demand
# paths:
#   - "src/**/*.{ts,tsx}"
#   - "features/**/*.feature"

# enforce: modify                # for path-scoped rules only
# enforce: [read, modify]        # force fetch before read and/or modify tools
---

# Rule Title

One short paragraph that states the rule clearly and why it exists.

## Do

- Concrete positive behaviors
- Preferred patterns
- Required practices

## Don't

- Concrete anti-patterns
- Things the agent must never do
- Common mistakes to avoid

## Examples (optional)

Good:
```text
...

```

Bad:
```text
...

```
