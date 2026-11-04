---
name: jesse-hardware
description: >-
  Use when a task touches the user's own machines: their NixOS computer being
  offline, the ~/kingdoms drive mount, holds when the computer or drive is down,
  Proton Bridge on the box, or the Drive sign-in on the box.
---
# Jesse's hardware

Rules that fit the user's own machines, not projects in general.

## 1. NixOS computer offline: retry once
If a call to the user's NixOS computer fails with a connection error (unreachable or timed out), wait about 5 seconds and retry the same call once, even under time pressure. If the retry fails too, tell the user the computer is offline and stop. Don't retry again or quietly switch to another route like a connector. Offer alternatives only as options for the user to pick.

## 2. Drive mount: check before reading or writing
The user's ~/kingdoms is a bind mount from an external drive (wd-1T).
1. Before reading or writing under it, run `mountpoint -q ~/kingdoms` on the user's computer, not the box. Check that root, not a subpath.
2. If it fails, or reads error out, tell the user the drive isn't mounted. Then don't create, write or edit any of their files, there or through any connector, and don't hand the work to another bot, even if it's urgent or files look present. Empty folders there are the bare SSD.

Reference (wd-1T): the drive mounts at `/media/wd-1T`, nofail, on nucbox and the laptop; config is `computers/hardware/wd-1T.nix` in personal_workplace. Backups from the Oct 31, 2026 move: `/media/wd-1T/home-backup-2026-07-31` and `~/backups/2026-10-31-pre-wd-1T` (on nucbox).

## 3. Where things live
See jesse-preferences rule 7. Check the mount (section 2) before using those paths; if it fails, stop.

## 4. Holds
- Capture (capture-item): if the computer is offline, the drive isn't mounted, or reads error out, hold the capture. Don't write through a connector or anywhere else, even if it's urgent. Tell the user it's held until the computer and drive are back.
- Daily pass (kingdom-daily-pass): if the NixOS computer is offline, hold the whole pass: no captures and no state changes, written nowhere. Tell the user it's held until the computer is back.

## 5. Proton Bridge check
Proton mail is reachable only through Bridge (IMAP 127.0.0.1:1143, STARTTLS, self-signed cert). The password is in the env var `PROTON_IMAP_PASS`; never print or log it. Bridge can stall, and the program has gone missing from the box while its tmux session kept looping.

Check before every Proton read, cheapest first:
1. Installed: `command -v protonmail-bridge`. If missing, reinstall the `protonmail-bridge` package the way it was installed before; the saved login has carried over. Then go to step 3.
2. Looping on a missing binary: `tail -3 ~/protonbridge-loop.log`. Repeated `exited 127` lines mean step 1 failed even though tmux looks alive.
3. Running: `tmux has-session -t protonbridge`. If not, start it: `tmux new -d -s protonbridge ~/protonbridge-loop.sh`.
4. Listening: `(echo > /dev/tcp/127.0.0.1/1143)` succeeds.
5. Answering: IMAP login with a 20 s timeout, `SELECT INBOX`, logout. Use `BODY.PEEK` so nothing is marked read. Port open but login times out means Bridge has stalled: kill and restart the tmux session, then retry once.
6. Still failing after the retry: name the failed step in your reply or digest ("Proton Bridge down, step N").

Helper scripts in /workspace (`proton_list.py`, `proton_read.py`, `proton_move.py`) do the IMAP work. Fetch in small batches; large pulls stall Bridge.

Handoff of mail-derived to-dos and events: follow jesse-preferences (capture worker and mailbox names).

## 6. Drive access check (box)
Before Google Drive work on the box (cleanup, labeling, bulk reads): confirm the gcloud sign-in's token, scopes and account, and make one real Drive call. Setup (scopes, quota project, session length, re-sign-in) is `website-photo-picker` section 0. Do not repeat it. gcloud is at `/home/box/google-cloud-sdk/bin/gcloud`; the sign-in is stored there. Never print a token. The expected account and quota project id are in the bot's description.
1. `TOKEN=$(gcloud auth application-default print-access-token)`. If this errors, do a fresh sign-in per section 0, then restart at step 1.
2. `curl -s "https://oauth2.googleapis.com/tokeninfo?access_token=$TOKEN"`: the scope list has `drive`, `drive.labels.readonly` and `cloud-platform`, and the email is the expected account.
3. One real call: `curl -s -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <quota-project-id>" "https://www.googleapis.com/drive/v3/about?fields=user"`. A `user` in the reply means ready. `USER_PROJECT_DENIED` right after enabling an API usually clears within minutes; retry twice.
4. Report one line: account, scopes, call OK.
