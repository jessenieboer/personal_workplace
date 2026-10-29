---
name: usp-drive-auth
description: >-
  Per-run check before Google Drive work on the box (cleanup, labeling, bulk
  reads): confirm the gcloud sign-in's token, scopes and account, and make one
  real Drive call. First-time setup is website-photo-picker section 0.
---
# Drive access check

Setup (scopes, quota project, session length, re-sign-in) is `website-photo-picker` section 0. Do not repeat it. gcloud is at `/home/box/google-cloud-sdk/bin/gcloud`; the sign-in is stored there. Never print a token. The expected account and quota project id are in the bot's description.

1. `TOKEN=$(gcloud auth application-default print-access-token)`. If this errors, do a fresh sign-in per section 0, then restart at step 1.
2. `curl -s "https://oauth2.googleapis.com/tokeninfo?access_token=$TOKEN"`: the scope list has `drive`, `drive.labels.readonly` and `cloud-platform`, and the email is the expected account.
3. One real call: `curl -s -H "Authorization: Bearer $TOKEN" -H "x-goog-user-project: <quota-project-id>" "https://www.googleapis.com/drive/v3/about?fields=user"`. A `user` in the reply means ready. `USER_PROJECT_DENIED` right after enabling an API usually clears within minutes; retry twice.
4. Report one line: account, scopes, call OK.
