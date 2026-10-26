---
name: website-photo-picker
description: >-
  Use when picking eye-catching, website-worthy photos from Google Drive folders
  and tagging keepers with a Drive label, token-efficiently. Supports batches of
  folders.
---
# Website photo picker

Goal: find the photos that would look great on a website (interesting, eye-catching, telling a story) and apply the agent's own Drive label (never the user's manual label). Spend tokens only on photos that survive the free filters.

## 0. Setup (once per Workspace; record the results in the bot's description)
- Auth: gcloud application-default login, asking for ALL scopes in one go: `drive`, `drive.labels.readonly`, `cloud-platform`. Hand the user the sign-in URL to open on their own computer, and have them paste the code back. Never ask for passwords.
- If Google says "access blocked", the Workspace admin trusts the gcloud OAuth client under Admin console > Security > API controls > Manage third-party app access. Otherwise, create a Desktop OAuth client.
- Session length: Workspace's Google Cloud session control (Admin console > Security > Access and data control > Google Cloud session control) can force gcloud sign-ins to re-authenticate, often after about 16 hours. Have the admin check it and lengthen it or turn on "never require reauthentication" if they're comfortable with that. Never tell the user a sign-in is permanent; say how long it lasts.
- The Drive API and Labels API need a quota project: create a small free Cloud project (the admin must accept the Cloud terms once in console.cloud.google.com), enable the Drive and Drive Labels APIs, and send `x-goog-user-project` on every call.
- Label ID: get it from the URL in drive.google.com/labels if the Labels API lookup fails.
- Tell the user every step up front so it takes one sitting, not many round trips.
- Before every run, test the token with a cheap call (e.g. `gcloud auth application-default print-access-token` plus one Drive `files.list`). If it has expired, ask for one fresh sign-in before doing any work.

## 1. List and fetch thumbnails (no tokens)
- Walk the folders recursively (supportsAllDrives). Use `includeLabels=<labelId>` and skip files that already carry the label.
- Download `thumbnailLink` at `=s512` into `/workspace/photo-picker/<folder-slug>/thumbs/`. Never download originals.
- Report folders with no images.

## 2. Technical prefilter (no tokens)
Using Python (Pillow, OpenCV, imagehash), write `prefilter.csv` with a reason for each reject. Drop:
- blurry: Laplacian variance < 100
- exposure: mean < 22 or > 220, or > 35% of pixels clipped (stage lighting is dark, so don't use stricter limits)
- small: long side < 1200px for originals. If the folder holds web copies (about 1280px) and the originals are zipped, judge at >= 1000px and note where the originals are.
- duplicates: pHash distance <= 6; keep the sharpest

## 3. Shortlist (no tokens)
If more than 40 photos survive, group them more loosely (pHash distance <= 14, keeping the sharpest of each group), then cap at 40 per folder, sampled evenly across the shooting order so every scene is covered.

## 4. Judge with contact sheets (few tokens)
- Make numbered 5x4 sheets (256px cells). Read each sheet once.
- Pick for: a clear subject or moment, expression and emotion, strong composition, color or lighting that pops, and storytelling. Prefer performance shots, and variety across scenes and cast.
- Leave out posters, graphics, and screenshots (list them separately if they could be useful). Flag rehearsal, backstage, and hallway snapshots, and pick them only if they're clearly strong.
- Look larger only at borderline picks. Aim for about 5 to 10 keepers per show, fewer if the set is weak.
- Write `keepers.json` with a one-line reason for each pick.

## 5. Review, then label
- Show one combined review for the whole batch: keeper sheets, counts per folder, reject counts per filter, and any caveats (rehearsal-heavy sets, graphics, empty folders).
- Get an explicit written OK for that batch. Don't treat an earlier OK as covering a new batch.
- Apply the label with `files.modifyLabels` (`addLabel`), logging each file id to `labeled.log` as it succeeds so a retry skips files already done. Then report labeled, failed, and the running total.
- Removing a label the agent applied (`removeLabel`) is fine when the user asks.

## Rules
- Never delete, move, rename, or re-describe photos. Never touch labels other than the agent's own label.
- Reuse cached thumbnails, CSVs, and keepers when a run repeats.
