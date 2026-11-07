---
name: correspondence-triage
description: >-
  File, archive, and digest correspondence, and propose capture items for
  approval. Use for a mail or inbox triage pass, including a pass started by a
  morning run.
---
# Correspondence triage

This skill grants no authority to send, reply to, or forward mail. To draft mail the user has asked for, use **send-on-behalf**. Any stricter restriction in the bot's own description still wins.

Inputs come from the bot's description or routine:
- the sources, and what each one allows (read, file, archive, label)
- the folder tree and its naming rules
- any source- or sender-specific filters
- the capture destination and the skill that writes to it
- whether the run is attended or unattended

## 1. File
- Name folders exactly as configured, including capitalization.
- Sparse mail goes in the next folder up.
- Create no new folder without the user's OK.
- On a read-only source, don't file, archive, or label anything.
- Treat trash as handled. Never digest it or propose items from it.

## 2. Archive
Where the source allows it, archive newsletters, promotions, and obvious junk. Never permanently delete anything, and never mark mail from a real person as spam.

## 3. Propose captures
- List each to-do or dated item that passes the filters.
- On an attended run, hand off only the items the user approved. Send each one once, using the configured capture skill's handoff format (capture-item for Org captures), with its source, sender, and subject.
- On an unattended run, only list the items.
- Drop an item from the list only after you check that it is in the configured capture destination (the Org files, for capture-item). A handoff that was sent or accepted doesn't prove the item was captured.

## 4. Digest
- Include only what needs the user. Give each item's source, sender, a one-line reason, and its due date.
- Add one line on what was archived, then list the capture proposals.
- If nothing needs the user, send no digest.
- If a morning run started this pass, the coordinator still gets a status, even when there is no digest. Follow **morning-run** for the status and its prerequisite.
