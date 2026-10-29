---
name: bulk-transfer
description: >-
  Before uploading, copying, or moving more than a handful of files or items in
  one job (Drive, WordPress media, Dropbox, or any API), including a retry of
  one that stopped partway.
---
# Bulk transfer
1. **Open the log** at `/workspace/bulk-logs/<job-slug>.tsv` (columns: `source`, `destination`, `name`, `size_or_hash`, `status`, `time`). If it exists, skip rows marked `done`. If it doesn't exist, still treat the job as possibly half-done.
2. **List both sides once.** Pull the name and size or hash of every item in the source and the destination with paged list calls, not one call per item. Write a row per source item:
   - Same name and same size or hash at the destination: mark it `skipped-exists`.
   - Same name but a different size or hash: mark it `conflict`. Don't overwrite or rename it; leave it for the user.
   - Otherwise: mark it `pending`.
3. **Work in chunks of about 50.** Prefer a native move (for Drive, a parent change) over copy-then-delete. After each chunk, list the destination again and mark an item `done` only when its name and size or hash match. Mark mismatches `failed` with the reason.
4. **Report after each chunk** with counts of done, skipped, conflicts, and failed, plus the failed names. If more than a few failed, stop and report instead of starting the next chunk.
5. **Copy-then-delete moves:** delete or trash a source item only after its destination row is `done`. Trash rather than permanently delete when the service allows it.
6. **Finish** with totals that add up to the source count, and the log path.
