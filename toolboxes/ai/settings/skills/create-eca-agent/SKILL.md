---
name: create-eca-agent
description: Use when creating or revising an ECA agent (.eca/agents, settings/agents), when create-agent would emit Claude Code fields, or when agent YAML will not parse. Writes ECA-loadable agents with map-form eca__ tools and compact descriptions. Replaces create-agent for ECA.
---

# Create ECA Agent

Write agents ECA can list, spawn, and tool. `create-agent` is Claude Code; loading it for ECA work produces unloadable files.

**Do not load `create-agent`.** If it is already in context, this skill overrides it. Do not merge the two.

**Not this skill:** skills, rules, commands, product code.

## Where to write

Named or existing path wins. This toolbox: `settings/agents/<kebab-name>.md` is source; `.eca/agents/` is a generated copy. No existing path: `.eca/agents/<kebab-name>.md`. Never `.claude/agents/` or `${CLAUDE_PLUGIN_ROOT}`.

## Frontmatter (hard)

The block between `---` must parse as YAML. If it would not parse, the agent does not exist.

Allowed keys only: `name`, `description`, `mode`, `model`, `variant`, `maxSteps` or `steps`, `tools`, `disabledTools`, `inherit`, `spawnableBy`.

Forbidden: `color`, `permissionMode`, `disallowedTools`, `allowed-tools`, `skills`, `hooks`, `mcpServers`, `isolation`, `memory`, `background`.

| Field | Rule |
|---|---|
| `name` | kebab-case, 3–50 chars, matches filename without `.md` |
| `description` | Single-line unquoted scalar, or quoted/folded. Starts with `Use this agent when...`. Compact. No `<example>`, HTML, or colon-plus-newline in an unquoted value. Examples go in the **body**. |
| `mode` | `primary`, `subagent`, or `[primary, subagent]` |
| `model` | Full ECA id (`xai/grok-4.6`). Never `sonnet` / `opus` / `haiku` / `inherit` |
| `tools` | Map, not a string, not a Claude Code list |

```yaml
tools:
  byDefault: ask
  allow:
    - eca__directory_tree
    - eca__grep
    - eca__read_file
  ask:
    - eca__write_file
    - eca__edit_file
    - eca__shell_command
```

ECA names only: `eca__read_file`, `eca__write_file`, `eca__edit_file`, `eca__grep`, `eca__directory_tree`, `eca__shell_command`, `eca__skill`, `eca__spawn_agent`, `eca__preview_file_change`, `eca__editor_diagnostics`.

Never: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `Task`, `Skill`, `WebFetch`, `WebSearch`, `NotebookEdit`. Never tell the model to use the Task tool. Spawning is `eca__spawn_agent`.

Start allow-list read-only. Add write/shell only if the job cannot finish without them. No tabs. Two-space indent.

## Body

Order: Title, Identity, Goal, Input, CRITICAL Load Context, Process. Reasoning column before decision. Produce the file, then self-critique. Do not dump examples into `description`.

## Process

1. **Decompose** — purpose, triggers, constraints, success criteria, existing files, when-NOT.
2. **Solve** — structure, triggering, workflow, test scenarios. Do not write yet.
3. **Produce** — write the complete agent to the source path.
4. **Re-read** — if frontmatter would fail a YAML parse, fix it before returning.
5. **Self-critique** — run the checklist. Fix every miss. Then output.

User says skip / "just write it": still enforce this contract. Still re-read. Still self-critique.

## Checklist

Path is source. Frontmatter parses. No forbidden keys. Description single-line, starts `Use this agent when...`. Model is a full ECA id. Tools are an ECA `eca__*` map. Body order as specified. File re-read after write.

## Rationalizations

| Excuse | Reality |
|---|---|
| "`create-agent` is official" | Official for Claude Code. ECA will not list that file. |
| "Examples in description improve triggering" | Unquoted multi-line YAML does not parse. Agent does not exist. |
| "Write Claude tools, translate later" | Later never runs. Agent cannot read or write. |
| "`inherit` / `sonnet` is the default" | Not an ECA model id. |
| "Write `.eca/agents` even if settings/ is source" | devenv overwrites the copy. |
| "Task is how agents spawn" | ECA spawning is `eca__spawn_agent`. |

## Red flags — rewrite the file

`color:`, `model: inherit`, `tools: ["Read"`, `<example>` in frontmatter, `Task` as spawner, path under `.claude/` or `${CLAUDE_PLUGIN_ROOT}`.
