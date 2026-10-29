---
name: org-safe-edit
description: >-
  Before changing any .org file, wherever it lives (local disk, Dropbox
  connector, or another remote store). Backup, write, verify, restore on drift.
---
# Safe Org edit
1. Get the file's exact bytes. On a local disk (your box or the user's computer through its machine shell), read the file directly. Through a connector, use a raw download (for Dropbox, a temporary download link), never extracted text.
2. If an Emacs autosave (`#name#`) or lock file (`.#name`) sits beside it, the file is open with unsaved changes. Skip it and tell the user to save it in Emacs.
3. Back up the original as `<name>.bak-daily-<YYYYMMDDHHMM>` (user's local time) in the same folder.
4. Write the new file to the original path (local write or connector upload). Keep Org syntax intact: headline stars, property drawers (`:PROPERTIES:` … `:END:`), timestamps like `<2026-10-29 Thu 14:00>`, and the file's existing line endings.
5. Read it back and diff it against the backup. Only the lines you meant to change may differ.
6. If anything else changed, restore the backup to the original path and report what went wrong.

Never delete a .org file. Backup cleanup is the job of whichever routine owns that folder, not this skill.
