# Task List template

## Task template
Use this shape. Drop sections that would be empty.

```markdown
## Task [N]: [short title]

**Description:** [What this task accomplishes]

**Acceptance criteria:**
- [ ] [Testable condition]
- [ ] [Testable condition]

**Verification:**
- [ ] Tests pass
- [ ] Repo build succeeds
- [ ] Human check (only if necessary or requested)

**Dependencies:** [Task numbers this depends on, or "None"]

**Files likely touched:**
- `src/...`
- `tests/...`

**Estimated scope:** [Small: 1-2 files | Medium: 3-5 files | Large: 5+ files]
```

## Sizing

| Size | Files | Action |
|------|-------|--------|
| XS | 1 | Keep |
| S | 1-2 | Keep |
| M | 3-5 | Keep if it is one scenario |
| L / XL | 5+ | Split |

Break further if the title contains "and", criteria exceed three bullets, or two subsystems move at once.
