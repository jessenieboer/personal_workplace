# Review template

Write exactly this shape. Drop Findings if there are none.

```markdown
# Design review

## Sources
- Context: `.toolboxes/bdd_toolbox/CONTEXT.md`
- Features: [directory paths, not individual filepaths]
- Date: [ISO date]

## Verdict
Ready | Not ready

## Findings
- THIN: [policy or scenario] — [missing edge/error/actor] -> gherkin-authoring
- ORPHAN-POLICY: [policy that can fail, no scenario] -> gherkin-authoring
- ORPHAN-SCENARIO: [scenario] uses [undefined term or outcome] -> domain-modeling
- CLASH: [context line] vs [scenario] -> grilling
```

## Rejected shapes

Do not put any of these in the review:

- Setup / Action / Expect restatements of scenarios
- Operation catalogs
- `def test_...` or other code
- Implementation tasks
