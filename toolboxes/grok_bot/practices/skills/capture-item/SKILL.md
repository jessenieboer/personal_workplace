---
name: capture-item
description: >-
  When turning short phrases ("buy nail clippers", "Iowa Canvassing team meeting
  oct 29") into captured items in the project_management Org files. Also the
  message format for handing items to the project's capture worker when you
  aren't a listed worker.
---
# Capture an item
The methodology lives in the project_management README (github.com/jessenieboer/personal_workplace, toolboxes/project_management). Read it first. Each project's .org files are in `<project>/.toolboxes/project_management_toolbox/`. Edit them directly in place. Never write .org files at the project root; only that folder syncs to the phone. For where projects live and when to hold a capture, follow jesse-hardware. Follow jesse-preferences for time zone, mailbox names and the capture worker's name.

0. **Check that you're a worker.** Look at CAPTURED_BY_ALL in the project's `project_management_toolbox_dir_locals`. If your name isn't listed, don't write anything. Send the item to the project's capture worker (format below), or tell the user.
1. **Pick the project and template.** Choose the CATEGORY and the capture template from the dir-locals: Task, Imminent Task, Time-bound Task, Routine, Time-bound Routine, Practice, Occurrence, Recurrence, Reference, or Journal Entry. Task titles start with a verb. Occurrence and Recurrence titles name the event and don't start with a verb ("Iowa Canvassing team meeting", not "attend…").
2. **Fix the dates.** Turn relative dates into real Org timestamps in the user's time zone. "friday" means the next Friday.
3. **Check for duplicates.** Search the .org files in that folder, including its `_inbox.org`, for the same or a similar title or date. If you find a likely duplicate, show it and wait.
4. **Add follow-up detail to the existing item.** If the message adds detail to an item that already exists, such as an idea for an existing task, add it as a note on that item. Don't make a new inbox entry or a new item.
5. **Write it** directly in the .org file. Use the template exactly and put the item under the right headline. Set CAPTURED_BY to your worker name and REVIEWED to `no`. Fill only the properties the template and the user's words support.
6. **Handle unclear items.** Ask one short question per item, and batch the questions. With no answer, leave the raw text in `_inbox.org` in that folder.

Report one line per item: what was captured or noted and where, or why it wasn't. Never delete an item, and never prioritize or estimate one.

## Handing items to the project's capture worker
Send with SendToAgent, one message per batch. Skip items you already sent; a new message in the same thread is the same item unless it changes the ask.

```
Please capture each once and check for duplicates:
1. <verb-first to-do> (<source>, from <sender>, subject "<subject>")
2. <event as a noun phrase with date, time and place> (<source>, from <sender>, subject "<subject>")
```

- To-dos start with a verb ("review ...", "reply to ..."). Events are noun phrases with date, time and place spelled out ("nov 10 6pm").
- Source is where the item came from, in words the user knows (for mail, the mailbox). Drop the sender and subject when there are none.
- Duplicate checking is the capture worker's job.
- Pass the capture worker's reply (captured, duplicate, or a question) back in your own summary.
