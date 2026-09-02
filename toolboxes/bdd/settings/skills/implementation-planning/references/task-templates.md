# Task templates

Use these shapes. Drop sections that would be empty.

## tasks/plan.md

```markdown
# Implementation Plan: [name from spec]

## Overview
[One paragraph. Behavior only, no stack manifesto.]

## Spec sources
- [path or "user message"]

## Decisions
- [Only decisions that change task order or files]

## Task index
### Phase 1
- [ ] Task 1: ...
- [ ] Task 2: ...

### Checkpoint: first working path
- [ ] Verification command for Task 1 passes
- [ ] Human reviewed before more tasks

### Phase 2
- [ ] Task 3: ...

## Out of scope
- [Behavior or tooling explicitly not in this plan]

## Open questions
- [Only blockers. Omit the heading if none]
```

## tasks/todo.md

```markdown
## Task 1: [short title]

**Description:** [What this slice makes true.]

**Acceptance criteria:**
- [ ] [Testable condition from the spec]
- [ ] [Testable condition]

**Verification:**
- [ ] [exact command, e.g. uv run pytest]
- [ ] Manual: [only if the spec is user-visible and tests cannot see it]

**Dependencies:** None

**Files likely touched:**
- `src/...`
- `tests/...`

**Estimated scope:** S
```

## Sizing

| Size | Files | Action |
|------|-------|--------|
| XS | 1 | Keep |
| S | 1-2 | Keep |
| M | 3-5 | Keep if it is one scenario |
| L / XL | 5+ | Split |

Break further if the title contains "and", criteria exceed three bullets, or two subsystems move at once.
