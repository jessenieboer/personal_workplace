---
name: implementation-planning
description: Break a Spec into ordered vertical-slice tasks with acceptance criteria and verification. Use when Spec exists but implementation has not started, or when implementation work is too large for one session. Do not use for a single obvious file change.
license: MIT
---

# Implementation Planning

Decompose specified behavior into a sequence of small stack-agnostic tasks that implementation agents can finish, verify, and stop after.

## When to use

- Features, Context, and Design Review exist and need implementable units
- Work should survive a new chat or a language switch
- Implementation order is not obvious

## When not to use

- Single-file change with obvious scope
- A complete Task List already exists for Spec
- User is still shaping product behavior
- Design Review says Not ready

## References

- Plan template: `references/plan-template.md`
- Task List template: `references/task-list-template.md`

## Inputs

- Design Review: make sure design is ready
- Context: domain terms and policies
- Features: acceptance criteria
- Plan and Task List if they exist

## Workflow

Work in phases. Do not skip a phase unless the user says to.

### Phase 1: Orient

- Read Design Review to check Ready vs Not ready verdict. Stop if not ready.
- List Features and read the ones that match the request
- Read Context
- Read Plan and Task List if they exist

### Phase 2: Slice

From Features and Context, list vertical slices. One slice = one user-visible path that can be made true end to end.

- Each slice delivers working, testable functionality.
- Start with 
- Do not slice by layer (all fixtures, then all functions, then all CLI)
- If slice title needs "and", or acceptance criteria would exceed three bullets, split

If any slice is unclear, stop and ask. Do not write files yet.



### Phase 4: Write tasks

Read `references/task-templates.md` and write:

- `tasks/plan.md` — overview, decisions, ordered index, one checkpoint after the first working path, risks only if they change order
- `tasks/todo.md` — the task bodies the implementer will execute

Each task must include acceptance criteria, a verification command that exists in this repo (or `manual` if none), dependencies, likely files, and size (XS/S/M). Split L and XL.

Verification commands are discovered, not assumed:

- Python → `uv run pytest` when pytest is in the project
- JavaScript → the test script in `package.json` if any
- Rust → `cargo test`
- Otherwise say how a human will check, and keep it one command

### Phase 5: Done

Done when:

- Every specified behavior is in some task, or explicitly out of scope
- Tasks are ordered so each leaves something runnable
- Human can approve or cut before any implementation agent runs

Summarize the task list. Do not start implementing.
