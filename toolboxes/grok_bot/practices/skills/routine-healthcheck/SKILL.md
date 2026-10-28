---
name: routine-healthcheck
description: >-
  Use when auditing every bot's scheduled and event routines for token waste and
  proposing fixes, e.g. from a weekly healthcheck routine.
---
# Routine healthcheck

1. **Gather routines.** Your own: the latest automation status. Other bots: their live routine lists aren't readable from here, so infer from `/home/box/agent-data/search-index.db` (SQLite; use Python's `sqlite3`, the CLI may be missing): look for routine wakes, routine create/update/pause messages, and any exported bot configs that list routines. Note which source each finding came from.
2. **Flag each routine** against these checks:
   - `too-frequent`: fires more often than its job needs (hourly polling for a daily need, a waiting loop that could be a trigger).
   - `long-chat`: only when the run's work actually happens inside a long chat. Routine runs normally execute in their own isolated session and just hand results back, so a result landing in a big chat is not this flag. Routines can't be moved to another chat; the only fix is a dedicated bot.
   - `noisy-empty`: sends filler ("no change") when nothing happened. Fix: stay quiet in the saved prompt.
   - `dead`: targets something finished, paused for good, or no longer wanted.
   - `duplicate`: two routines (same or different bots) doing the same job.
   - `orphan-skill`: the prompt names a skill that doesn't exist, or a skill exists only for a removed routine.
3. **Skip what's fixed.** Check later chat messages for a stop, pause, or reschedule before flagging.
4. **Report.** A short numbered list, one line each: `bot | routine | flag | suggested fix`. Write each fix as an edit to the routine's existing prompt or schedule (the line to change and its replacement), not as new text added to the prompt. Then one line naming what was checked and cleared, and any visibility gaps. If nothing is worth proposing, send nothing.
5. **Don't act.** Edit no routine, skill, or bot until the user picks. Never edit another bot's routines directly; ask that bot to do it after the user approves.
