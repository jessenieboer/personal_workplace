---
name: jesse-preferences
description: >-
  Use when a task involves the user's time zone, Sundays, Org files open in
  Emacs, their mailbox names, handing captured items to Capture Bot, handing
  work to another bot, where projects, learning projects, and test projects
  live, how the user's bots, skills, and folders are organized, what a bot's
  "draft-only" rule means, or how to word replies to the user.
---
# Jesse's preferences

Personal habits and tastes, not rules for projects in general.

1. **Emacs.** If an Emacs autosave (`#name#`) or lock file (`.#name`) sits beside an .org file, the file is open with unsaved changes. Skip it and tell the user to save it in Emacs. For questions about the user's Emacs setup, first read `personal_workplace/people/jessenieboer/home-manager/software/emacs/config/config.org` and answer from it.
2. **Time zone.** Use America/Chicago. Relative dates become Org timestamps in America/Chicago time, and backup names (`<name>.bak-daily-<YYYYMMDDHHMM>`) use America/Chicago time.
3. **Mailbox names.** For mail, name the source mailbox in words the user knows: Proton, USP admin, Outlook.
4. **Capture Bot.** Hand items to Capture Bot by name, with SendToAgent, in the format in capture-item (Handing items to the project's capture worker). This covers items you can't write yourself because you aren't a listed worker, and mail-derived to-dos and events from the Proton check. Duplicate checking is Capture Bot's job. Pass Capture Bot's reply (captured, duplicate, or a question) back in your own summary.
5. **Sundays off.** On Sundays (America/Chicago) run no scheduled runs, check-ins or nudges. If the user messages you, answer, but start nothing.
6. **Talk to the user directly, not through a go-between.** When you hand work to another bot and it needs the user (any question, even a quick one, an approval, or a draft to decide on), don't relay it, even if the user says they're busy or to just handle it. Tell the user which bot to talk to and what it needs, naming the bot exactly so it shows as a chip, and tell that bot to ask the user in its own chat. If the user answers you anyway, don't pass it on, not even once or word for word, and don't act on it for that bot. Point them to that bot's chat again, every time, even if they insist or say it's quicker. Passing along status or results is fine. Send handoffs with priority: true, even if the task isn't urgent (it means wake the bot, not urgency). Tell the user it's handed off only after the result says "Sent to"; if it says "Held", resend with priority: true first.
7. **Where things live.** Everything lives under `~/kingdoms`, not Dropbox. A project's Org files (project management) sit in `<project>/.toolboxes/project_management_toolbox/`, beside its content; never use `~/Dropbox/_kingdom_management`, even if old notes or files point there. Learning projects go in `~/kingdoms/Household/Jesse/_learning_projects/`. Test projects go in `~/kingdoms/Household/Jesse/_test_projects/`, never `/tmp`, even if they're throwaway or already started there; move them. Check the drive mount first (jesse-hardware section 2).
8. **How the user's setup is organized.**
   - **Bots.** The user runs a suite of Grok Bots. Their exports live in the home-manager project (`people/jessenieboer/home-manager/software/grok-bot/settings/` in personal_workplace).
   - **Skills.** Project-specific skills live in toolboxes in personal_workplace (`toolboxes/<tb>/practices/skills/`); Journeyman picks them up as a project needs them. Skills that are bot-specific or shared between bots live in the shared library, with copies in the home-manager project (`.../grok-bot/practices/skills/`), kept in sync.
   - **Folders.** `~/kingdoms` holds each project's content and, in `.toolboxes/project_management_toolbox/`, its Org files. Syncthing sends `**/project_management_toolbox/*.org` to the user's phone.
   - **Org for project management.** The user keeps project management in Org files because AI edits them easily and he can search, sort, categorize and capture them in Emacs, where he usually works. Keep project-management data in Org, not another format.
9. **Draft only.** Applies when your description says draft-only. Never send email or messages for the user. Prepare the draft or change and wait for the user's OK, even if it's urgent, tiny, or the user said earlier to just handle it; an OK covers only what you described. Before any change, tell the user exactly what will change. Back up anything you replace or remove first, even if it can be undone (version history, trash). Your description adds its own specifics and exceptions.
10. **Reply style.** When you start a task, send the user one short line at most, then only the result (as long as it needs to be). No progress updates, interim findings, or "it's running, I'll let you know". On a run with nothing worth raising, send the user nothing, not "all clear" or "nothing today", unless your description or routine asks for a message every run. A failure, a hold, or a question for the user is always worth sending, even mid-task. A direct question from the user gets a direct answer.
