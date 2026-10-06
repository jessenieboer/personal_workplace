---
name: create-eca-agent
description: Use when creating or revising an ECA agent, when the file must be spawnable, or when create-agent would emit Claude Code fields. Writes a YAML agent ECA 0.161 lists and spawns, with subagent mode and map-form eca__ tools. Replaces create-agent for ECA.
---

# Create ECA Agent

Write an agent ECA can discover and spawn. Do not load `create-agent`. If it is in context, this skill overrides it. Do not merge.

**Not this skill:** skills, rules, commands, product code. Primary-only is a chat persona, not a spawnable agent.

Checked against ECA 0.161.1. Do not invent a stricter schema.

## Land

ECA scans `.eca/agents/*.md` and `~/.config/eca/agents/*.md` only. Not `settings/agents/`.

Named path wins when it is one of those two. Else write the source a copy task installs, and make that task name this file. One hardcoded install does not install the next. No copy task: write `.eca/agents/<id>.md`. Gitignored `.eca/` is still loaded.

## Contract

- `name`: lowercase kebab-case, equals filename stem. No spaces. No `subagent-` prefix.
- Frontmatter is a `---` mapping. Invalid YAML means no agent. No Claude Code keys (`color`, `permissionMode`, `disallowedTools`, `allowed-tools`, `skills`, `hooks`, `mcpServers`, `isolation`, `memory`, `background`).
- `mode`: `subagent`, or `[primary, subagent]`. Absent defaults to both. `primary` alone is not spawnable.
- `model`: omit, or a full id (`xai/grok-4.7`). Never `sonnet`, `opus`, `haiku`, `inherit`.
- `description`: one line, what and when. No `<example>`, no HTML, no bare colon-newline.
- `tools`: map, `byDefault: deny`, plus tools the job needs. A Claude list is coerced to allow-with-ask. A string is ignored. Write or shell only if the job cannot finish without them.
- `disabledTools`: name without `eca__` (`edit_file`), or `server__tool`. `maxSteps`: omit for unlimited. `inherit`: unknown or self is ignored. `spawnableBy`: omit unless a parent must be restricted.

```yaml
tools:
  byDefault: deny
  allow:
    - eca__directory_tree
    - eca__grep
    - eca__read_file
```

Use `eca__*` names from this session's tool list. Never `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `Task`, `Skill`. Not `eca__compact_chat`. Spawn is `eca__spawn_agent`. Subagents cannot nest.

## Done

Fail the file unless a parent can pass the id to `eca__spawn_agent`: scanned path or a copy task that names this file, `mode` includes `subagent`, `name` is the stem, YAML parses, body tools are on the map.

`/subagents` must list the id. No reload this session: say unverified. Do not claim it spawned.

Body: when to act, when not to, process, output, stop. Short. One example. Do not paste a skill in. Name the skill and the stop condition if the job is to load one.

## Process

1. Decompose: job, trigger, when-not, tools, step cap, scanned path.
2. Solve the mode, tool map, and filename. Do not write yet.
3. Produce the source. Change the copy task if ECA will not see it.
4. Re-read. Fix until Done passes. "Just write it" does not skip this.

## Rationalizations

| Excuse | Reality |
|---|---|
| "`create-agent` is official" | Official for Claude Code. Follow this file. |
| "ECA coerces a Claude tool list" | Coercion is allow-with-ask. Ship the map. |
| "`color` is ignored" | Do not emit Claude Code keys. |
| "`primary` is enough" | Primary-only is not spawnable. |
| "settings/agents is source, so ECA loads it" | ECA does not scan that path. |
| "The copy task will pick it up" | A one-file install will not install the next. |
| "Omit mode; default is fine" | Default is both. Say `subagent` unless it is also a chat persona. |
| "Task is how agents spawn" | `eca__spawn_agent`. No nesting. |
| "I wrote the path, so it loaded" | A path is not a reload. Say unverified. |

## Red flags -- rewrite

`mode: primary` only. `model: inherit` or `sonnet`. `tools:` as a string or Claude names. `name` not the filename stem. File only under `settings/agents/` with no copy. Body says `Task` or "spawn a subagent". `<example>` in frontmatter.
