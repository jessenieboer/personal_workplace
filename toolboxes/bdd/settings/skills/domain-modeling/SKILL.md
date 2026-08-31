---
name: domain-modeling
description: Update product context when a domain term or rule is settled. Use during or after grilling when vocabulary must be captured.
# license: MIT
# metadata:
#   audience: developers
#   workflow: bdd
---

# Domain modeling

Update the product context when domain terms or rules are settled. Do not write features.

## When to use this skill

- A term, synonym, or policy rule was just settled in conversation
- The user is editing or creating the context
- Talk uses a word that fights a term in the context

## When not to use this skill

- The domain is still fuzzy and no term has been decided -> use `grilling`
- The user asked to write features using an agreed context -> use `gherkin-authoring`
- You only need to *read* the context. That is not this skill

## References
- context: `.toolboxes/bdd_toolbox/CONTEXT.md`

## Inputs you expect

- Provided: the settled term or rule; current context if it exists
- Infer: clashes with existing entries
- Ask: which meaning wins when two terms collide. Do not pick a winner.

## Instructions

1. Read context if it exists. If it does not, create it only when the first term or policy is settled.
2. For each settled item or policy, write or edit the matching section now. Do not batch until the end of the chat.
3. If the user's term or policy fights an existing entry, stop and ask which meaning is canonical, then edit the context.
4. If a term is vague, propose one canonical term and one or two rejected synonyms, then wait.
5. After each edit, one line: what changed in context

## Constraints

- Context only contains terms, their synonyms to avoid, and short policy rules
- No implementation, stack, Gherkin syntax, scenarios, or scratch notes in context
- Do not write `.feature` files
- Do not invent terms the user did not settle
- Context uses this shape:

```markdown
# Product Context

## Terms
- **name**: definition
  avoid: terms to reject

## Policies
- One line describing a rule
```

## Done when

- Settled terms and policies from this turn are in the context
- Return entries changed, and any unresolved clash

## If blocked

- Two meanings for one word -> ask which wins; do not merge
- User wants features mid-edit -> stop and use `gherkin-authoring` only after the context is consistent
- Implementation offered as term or policy -> reject for context
