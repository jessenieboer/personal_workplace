---
name: glossary-org
description: Create, extend, or clean up a glossary.org file (terms with ids, aliases and links that export to GLOSSARY.md). Use when adding, renaming, or linking glossary terms, seeding a new glossary, or copying one between projects.
---

# Maintaining glossary.org

Edit glossary.org directly; it is git-tracked. Touch only glossary.org files. Never edit GLOSSARY.md; Emacs exports it from the .org (ox-gfm), so tell the user to re-export.

1. Find the file: `.toolboxes/glossary_toolbox/glossary.org`. Edit the existing one; never add a second. If none exists, seed it from `toolboxes/glossary/templates/glossary.org` in personal_workplace.
2. Header, in this order: `#+title:`, `#+EXPORT_FILE_NAME:` (`GLOSSARY.md`, or `../../GLOSSARY.md` for a file inside `.toolboxes/<x>/`), `#+OPTIONS: toc:nil prop:nil`, then a one-line purpose.
3. One top-level heading per term. The heading is lowercase, singular, and alphabetical among its siblings.
4. Under each heading a `:PROPERTIES:` drawer: `:ID:` (fresh uuid, from `cat /proc/sys/kernel/random/uuid`), `:ALIASES:` (space-separated, multi-word aliases in double quotes), `:CONTEXT:` (`<toolbox>_toolbox`), and `:PRIME:` (`false` when the definition links another term, `true` when it does not). All four are required.
5. Body is the definition. Put a blank line before any `Example:` or `See also:` line, or the export merges it into the definition paragraph.
6. Links are `[[id:<uuid>][wording as used]]`. Each glossary stands alone: link only to terms in the same file, and never link a term inside its own entry. When a term or alias is added or renamed, check the other definitions that use that word and link them; update `:PRIME:` where it applies. Flag circular, vague, or duplicate definitions you notice.
7. Copying terms or a whole glossary into another file: give every copied term a fresh `:ID:` and rewrite its links to match. Duplicate ids make org jump to the wrong file. Tell the user to run `M-x org-id-update-id-locations`.
8. Wording: the user decides what a term means. Ask questions to sharpen a definition, and propose new or changed definitions as a diff; write only after OK. If pasted text holds a stray secret-looking string (for example a YubiKey one-time code), leave it out and say so.
9. Verify: run the check below on the file. It must print `ok`.

```python
import re,sys
t=open(sys.argv[1]).read()
hs=re.findall(r'^\* (.+)$',t,re.M); ss=re.split(r'^\* .+$',t,flags=re.M)[1:]
ids={};bad=[]
for h,s in zip(hs,ss):
    m=re.search(r':ID:\s+(\S+)',s)
    if not m: bad.append(h+': no ID'); continue
    if m[1] in ids: bad.append(h+': duplicate ID')
    ids[m[1]]=h
    links=re.findall(r'\[\[id:([^\]]+)\]',s)
    if m[1] in links: bad.append(h+': links itself')
    if not re.search(r':ALIASES:',s): bad.append(h+': no ALIASES')
    if not re.search(r':CONTEXT:\s+\S',s): bad.append(h+': no CONTEXT')
    p=re.search(r':PRIME:\s+(\S+)',s)
    if not p: bad.append(h+': no PRIME')
    elif (p[1]=='true')==bool(links): bad.append(h+': PRIME mismatch')
for h,s in zip(hs,ss):
    bad+=[h+': dangling link' for l in re.findall(r'\[\[id:([^\]]+)\]',s) if l not in ids]
if hs!=sorted(hs): bad.append('not alphabetical')
print('\n'.join(bad) or 'ok')
```
