---
name: proton-bridge-check
description: >-
  Before reading Proton Mail through Proton Bridge on the box, check that Bridge
  is running and answering. Also the exact message format for handing
  mail-derived to-dos and events to Capture Bot.
---
# Proton Bridge check and mail handoff

Proton mail is reachable only through Bridge (IMAP 127.0.0.1:1143, STARTTLS, self-signed cert). The password is in the env var `PROTON_IMAP_PASS`; never print or log it. Bridge can stall, and the program has gone missing from the box while its tmux session kept looping.

## Check (before every Proton read, cheapest first)
1. Installed: `command -v protonmail-bridge`. If missing, reinstall the `protonmail-bridge` package the way it was installed before; the saved login has carried over. Then go to step 3.
2. Looping on a missing binary: `tail -3 ~/protonbridge-loop.log`. Repeated `exited 127` lines mean step 1 failed even though tmux looks alive.
3. Running: `tmux has-session -t protonbridge`. If not, start it: `tmux new -d -s protonbridge ~/protonbridge-loop.sh`.
4. Listening: `(echo > /dev/tcp/127.0.0.1/1143)` succeeds.
5. Answering: IMAP login with a 20 s timeout, `SELECT INBOX`, logout. Use `BODY.PEEK` so nothing is marked read. Port open but login times out means Bridge has stalled: kill and restart the tmux session, then retry once.
6. Still failing after the retry: name the failed step in your reply or digest ("Proton Bridge down, step N").

Helper scripts in /workspace (`proton_list.py`, `proton_read.py`, `proton_move.py`) do the IMAP work. Fetch in small batches; large pulls stall Bridge.

## Handoff to Capture Bot
Use `capture-item` for what counts as an item. Send with SendToAgent, one message per batch, and skip items you already sent (check your memory of what went out; a new message in the same thread is the same item unless it changes the ask).

```
Please capture each once and check for duplicates:
1. <verb-first to-do> (<account>, from <sender>, subject "<subject>")
2. <event as a noun phrase with date, time and place> (<account>, from <sender>, subject "<subject>")
```

- To-dos start with a verb ("review ...", "reply to ..."). Events are noun phrases with date, time and place spelled out ("nov 10 6pm").
- Account is the mailbox name Jesse knows (Proton, USP admin, Outlook).
- Duplicate checking is Capture Bot's job.
- Pass Capture Bot's reply (captured, duplicate, or a question) back in your own summary.
