---
name: capture-item
description: >-
  When turning short phrases ("buy nail clippers", "Iowa Canvassing team meeting oct 29")
  into captured items in the project_management Org files. Pass captures here
  instead if you aren't a listed worker.
---
# Capture an item
The methodology lives in the project_management README (github.com/jessenieboer/personal_workplace, toolboxes/project_management). Read it first. Projects are in Dropbox `_kingdom_management`, and their .org files are usually in `<project>/.toolboxes/project_management_toolbox/`.

0. **Check that you're a worker.** Look at CAPTURED_BY_ALL in the project's `project_management_toolbox_dir_locals` (devenv.nix doesn't sync to Dropbox). If your name isn't listed, don't write anything. Send the item to Capture Bot, or tell the user.
1. **Pick the project and template.** Choose the CATEGORY and the capture template from the dir-locals: Task, Imminent Task, Time-bound Task, Routine, Time-bound Routine, Practice, Occurrence, Recurrence, Reference, or Journal Entry. Task titles start with a verb. Occurrence and Recurrence titles name the event and don't start with a verb ("Iowa Canvassing team meeting", not "attend…").
2. **Fix the dates.** Turn relative dates into real Org timestamps in America/Chicago time. "friday" means the next Friday.
3. **Check for duplicates.** Search the project's .org files and its `_inbox.org` for the same or a similar title or date. If you find a likely duplicate, show it and wait.
4. **Add follow-up detail to the existing item.** If the message adds detail to an item that already exists, such as an idea for an existing task, add it as a note on that item (through org-safe-edit). Don't make a new inbox entry or a new item.
5. **Write it** with the org-safe-edit skill. Use the template exactly and put the item under the right headline. Set CAPTURED_BY to your worker name and REVIEWED to `no`. Fill only the properties the template and the user's words support.
6. **Handle unclear items.** Ask one short question per item, and batch the questions. With no answer, leave the raw text in the project's `_inbox.org`.

Report one line per item: what was captured or noted and where, or why it wasn't. Never delete an item, and never prioritize or estimate one.
