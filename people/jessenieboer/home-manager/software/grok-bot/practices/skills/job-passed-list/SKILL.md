---
name: job-passed-list
description: >-
  Keep a file of jobs the user has passed on and filter every job search or
  digest through it. Use whenever searching for jobs, sending a digest, or when
  the user says they're not interested in or want to skip a listing. Works
  alongside job-search.
---
# Passed-jobs list

Use with `job-search`: search as usual, then filter through this list before showing results.

File: `/workspace/job-scout/passed-jobs.tsv` on the box. If missing, create the folder and the file with the header line `date<TAB>company<TAB>title<TAB>url<TAB>reason`. Plain text, one job per line.

1. Record: when the user says they are passing on or skipping a job, append a line right away: today's date, company, title, listing URL with tracking parameters removed, and their reason in a few words. Confirm in one line. Only jobs the user passes on go in; employer rejections are not recorded.
2. Filter: before each digest or answer, read the whole file and drop any result that matches a line by URL, or by company plus title (ignore case, "Inc.", and "Sr." versus "Senior"). The same job on another board matches.
3. A different role at the same company does not match.
4. Bring back: if the user names a passed job and asks for it again, delete its line and say so.
