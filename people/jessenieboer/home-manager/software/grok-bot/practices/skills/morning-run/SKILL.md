---
name: morning-run
description: >-
  Run or take part in a multi-bot morning run: the coordinator asks each
  participant in turn, and each participant answers with a real completion or
  blocked status. Use when a bot or routine starts a morning run or receives a
  request to run one.
---
# Morning run

This skill grants no messaging authority. A bot's own description sets who it may message. If this skill and that description disagree, the description wins.

Inputs come from the caller's description or routine:
- the start request text
- the ordered list of participants
- each participant's assigned work
- a checkpoint or deadline for deciding that a participant hasn't replied

Do not invent a timer, delay, polling loop, or new routine.

## Prerequisite

Under each participant's role, the coordinator must be an allowed recipient of that participant's status. If it isn't, don't widen your authority. Tell the user that this participant can't report status to the coordinator.

## Statuses (exactly two)

- `done`: the assigned work completed. A successful run with nothing to raise also counts as done.
- `blocked: <reason>`: the assigned work did not complete, because it was held or failed.

Never send `done` for work that didn't complete. No one may redefine `done`, not even the coordinator.

## Coordinator

1. Send the start request to participants one at a time, in the configured order. Wait for each one's async reply before sending to the next. Don't poll.
2. Record each status as it was sent.
3. When every participant has replied, or the caller's checkpoint has passed, run your own review. Name any participant that was blocked or never replied; give the reported reason, if known. Continue unless your description says otherwise.
4. If no checkpoint was supplied, don't claim you can tell that a participant never replied.

## Participant

1. Do only the assigned work.
2. Reply to the coordinator with exactly one status, and only if the prerequisite holds.
3. On a hold, follow your own hold rules, including telling the user. Make no extra retries and take no connector shortcuts.
