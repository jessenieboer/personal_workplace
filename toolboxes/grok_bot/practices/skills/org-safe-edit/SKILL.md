---
name: org-safe-edit
description: >-
  Before changing any .org file in Dropbox _kingdom_management (or any Org file
  read and written through the Dropbox connector). Backup, write, verify,
  restore on drift.
---
# Safe Org edit
1. Get the file's exact bytes through a temporary download link, not extracted text.
2. Check for an Emacs autosave or lock file beside it, as jesse-preferences says. If one is there, skip the file.
3. Rename the original to `<name>.bak-daily-<YYYYMMDDHHMM>` (user's local time; see jesse-preferences).
4. Upload the new file to the original path.
5. Download it again and diff it against the backup. Only the lines you meant to change may differ.
6. If anything else changed, restore the backup to the original path and report what went wrong.

Never delete a .org file. Backups older than 3 days are cleaned up by the project's capture worker's daily routine, not by this skill.
