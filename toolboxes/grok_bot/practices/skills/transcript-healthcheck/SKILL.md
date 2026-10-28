---
name: transcript-healthcheck
description: >-
  Use when scanning recent bot chats for user friction and proposing fixes
  (skill, bot, or routine), e.g. from a scheduled healthcheck routine.
---
# Transcript healthcheck

1. **Window.** Since the last successful run (read `transcript-healthcheck/last-success.txt` in this bot's store), else the last 24h.
2. **Find chats.** Prefer `/home/box/agent-data/search-index.db` (SQLite; read it with Python's `sqlite3` module since the CLI may be missing). Fall back to `/home/box/agent-data/agent-transcripts/*.jsonl` only if they are fresh; they can go stale. Skip `sand-subagent-` sessions.
3. **Mine friction.** Look for: the user repeating or correcting an instruction, asking for a different format or length, a bot missing context the user had to supply, a bot asking a teammate for something its profile should hold, failed or retried steps, and manual tasks done more than once.
4. **Map each to a fix.** One per finding, typed `skill | bot | routine`: a bot description edit (compare against the live `profile.json`), a new or updated skill, or a routine. Skip anything already fixed.
5. **Shape each fix.** Give the error (what happened), its root cause, and one short imperative rule that prevents it. Point to the sentence or step in the target's existing text that the rule merges into or replaces. Add a new line only when nothing fits, and never a new paragraph. If the rule repeats or contradicts existing text, edit that text instead.
6. **Report.** A short numbered list, one bullet per fix: target, error, root cause, and the rule shown as a before and after of the merged line. No filler. If nothing is worth proposing, send nothing.
7. **Don't act.** Create or edit nothing until the user picks.
8. **Mark success.** Write the current UTC timestamp to `transcript-healthcheck/last-success.txt`.
