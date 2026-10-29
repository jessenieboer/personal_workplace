# Structure check for a glossary.org file; see the glossary-org skill.
# Prints "ok" and exits 0, or one problem per line and exits 1.

if [ "$#" -ne 1 ]; then
	echo "usage: glossary-check <glossary.org>" >&2
	exit 2
fi
file=$1
if [ ! -r "$file" ]; then
	echo "glossary-check: cannot read $file" >&2
	exit 2
fi

# C locale: the alphabetical check compares bytes, not locale collation.
export LC_ALL=C
awk '
# Check one top-level entry. Reads head and sec; fills ids and bad.
function entry(    s, id, links, v) {
	n++
	heads[n] = head
	secs[n] = sec
	s = sec
	if (!match(s, /:ID:[ \t]+[^ \t\r\n]+/)) {
		bad[++nbad] = head ": no ID"
		return
	}
	id = substr(s, RSTART, RLENGTH)
	sub(/^:ID:[ \t]+/, "", id)
	if (id in ids)
		bad[++nbad] = head ": duplicate ID"
	ids[id] = head
	nlinks = linkids(s, links)
	for (i = 1; i <= nlinks; i++)
		if (links[i] == id) {
			bad[++nbad] = head ": links itself"
			break
		}
	if (!match(s, /:ALIASES:/))
		bad[++nbad] = head ": no ALIASES"
	if (!match(s, /:CONTEXT:[ \t]+[^ \t\r\n]/))
		bad[++nbad] = head ": no CONTEXT"
	if (!match(s, /:PRIME:[ \t]+[^ \t\r\n]+/))
		bad[++nbad] = head ": no PRIME"
	else {
		v = substr(s, RSTART, RLENGTH)
		sub(/^:PRIME:[ \t]+/, "", v)
		if ((v == "true") == (nlinks > 0))
			bad[++nbad] = head ": PRIME mismatch"
	}
}
# Put every [[id:...] target of s into out; return how many.
function linkids(s, out,    k, m) {
	k = 0
	while (match(s, /\[\[id:[^]]+\]/)) {
		m = substr(s, RSTART + 5, RLENGTH - 6)
		out[++k] = m
		s = substr(s, RSTART + RLENGTH)
	}
	return k
}
/^\* ./ {
	if (inentry)
		entry()
	head = substr($0, 3)
	sec = ""
	inentry = 1
	next
}
inentry { sec = sec $0 "\n" }
END {
	if (inentry)
		entry()
	# Links resolve only after every ID is known.
	for (j = 1; j <= n; j++) {
		k = linkids(secs[j], tmp)
		for (i = 1; i <= k; i++)
			if (!(tmp[i] in ids))
				bad[++nbad] = heads[j] ": dangling link"
	}
	for (j = 2; j <= n; j++)
		if (heads[j] < heads[j - 1]) {
			bad[++nbad] = "not alphabetical"
			break
		}
	if (nbad == 0) {
		print "ok"
		exit 0
	}
	for (j = 1; j <= nbad; j++)
		print bad[j]
	exit 1
}
' "$file"
