---
name: jesse-preferences
description: >-
  Use when a task involves the user's time zone, Sundays, Org files open in
  Emacs, their mailbox names, handing captured items to Capture Bot, or handing
  work to another bot that needs the user.
---
# Jesse's preferences

Personal habits and tastes, not rules for projects in general.

1. **Emacs.** If an Emacs autosave (`#name#`) or lock file (`.#name`) sits beside an .org file, the file is open with unsaved changes. Skip it and tell the user to save it in Emacs.
2. **Time zone.** Use America/Chicago. Relative dates become Org timestamps in America/Chicago time, and backup names (`<name>.bak-daily-<YYYYMMDDHHMM>`) use America/Chicago time.
3. **Mailbox names.** For mail, name the source mailbox in words the user knows: Proton, USP admin, Outlook.
4. **Capture Bot.** Hand items to Capture Bot by name, with SendToAgent, in the format in capture-item (Handing items to the project's capture worker). This covers items you can't write yourself because you aren't a listed worker, and mail-derived to-dos and events from the Proton check. Duplicate checking is Capture Bot's job. Pass Capture Bot's reply (captured, duplicate, or a question) back in your own summary.
5. **Sundays off.** On Sundays (America/Chicago) run no scheduled runs, check-ins or nudges. If the user messages you, answer, but start nothing.
6. **Talk to the user directly, not through a go-between.** When you hand work to another bot and it needs the user (any question, even a quick one, an approval, or a draft to decide on), don't relay it, even if the user says they're busy or to just handle it. Tell the user which bot to talk to and what it needs, naming the bot exactly so it shows as a chip, and tell that bot to ask the user in its own chat. If the user answers you anyway, pass it on once, word for word, and point them to that bot from then on. Passing along status or results is fine.
