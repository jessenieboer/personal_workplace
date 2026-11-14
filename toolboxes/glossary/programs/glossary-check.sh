# Structure check for a glossary.org file; see the capture-term and maintain-glossary skills.
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
# Check one top-level entry. Reads head and sec; records it as entry n.
function entry(    s, id, links, nlinks, v, L, nl, i, body, line, al) {
	n++
	heads[n] = head
	secs[n] = sec
	s = sec
	if (head != tolower(head))
		bad[++nbad] = head ": heading not lowercase"
	addname(head, n)
	nlinks = linkids(s, links)
	if (!match(s, /:ID:[ \t]+[^ \t\r\n]+/))
		bad[++nbad] = head ": no ID"
	else {
		id = substr(s, RSTART, RLENGTH)
		sub(/^:ID:[ \t]+/, "", id)
		if (id in ids)
			bad[++nbad] = head ": duplicate ID"
		ids[id] = head
		idx[id] = n
		for (i = 1; i <= nlinks; i++)
			if (links[i] == id) {
				bad[++nbad] = head ": links itself"
				break
			}
	}
	if (!match(s, /:ALIASES:[^\n]*/))
		bad[++nbad] = head ": no ALIASES"
	else {
		al = substr(s, RSTART, RLENGTH)
		sub(/^:ALIASES:[ \t]*/, "", al)
		aliases(al, n)
	}
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
	# Each Example: or See also: line after the drawer needs a blank line
	# before it, or the export merges it into the paragraph above.
	nl = split(s, L, "\n")
	body = 0
	for (i = 1; i <= nl; i++) {
		line = L[i]
		if (!body) {
			if (line ~ /^[ \t]*:END:[ \t]*$/) body = 1
			continue
		}
		if (line ~ /^(Example|See also):/ && L[i - 1] !~ /^[ \t]*$/)
			bad[++nbad] = head ": no blank line before \"" substr(line, 1, index(line, ":")) "\""
	}
}
# Split an ALIASES value (space-separated, multi-word ones in double quotes).
function aliases(s, j,    a) {
	while (s != "") {
		sub(/^[ \t]+/, "", s)
		if (s == "") break
		if (substr(s, 1, 1) == "\"") {
			s = substr(s, 2)
			if (index(s, "\"")) { a = substr(s, 1, index(s, "\"") - 1); s = substr(s, index(s, "\"") + 1) }
			else { bad[++nbad] = heads[j] ": unclosed quote in ALIASES"; a = s; s = "" }
		} else {
			match(s, /^[^ \t]+/)
			a = substr(s, 1, RLENGTH); s = substr(s, RLENGTH + 1)
		}
		if (a != "") addname(a, j)
	}
}
# Record a heading or alias; two entries may not share a name.
function addname(nm, j,    k) {
	k = tolower(nm)
	if ((k in owner) && owner[k] != j)
		bad[++nbad] = heads[j] ": name \"" k "\" also used by " heads[owner[k]]
	if (!(k in owner)) owner[k] = j
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
function dfs(u,    m, a, i, v, p, path) {
	color[u] = 1
	stk[++sp] = u
	m = split(edges[u], a, " ")
	for (i = 1; i <= m; i++) {
		v = a[i]
		if (v == u) continue
		if (color[v] == 1) {
			for (p = sp; stk[p] != v; p--) ;
			path = heads[v]
			for (p++; p <= sp; p++) path = path " -> " heads[stk[p]]
			bad[++nbad] = "circular: " path " -> " heads[v]
		} else if (!color[v])
			dfs(v)
	}
	sp--
	color[u] = 2
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
			else
				edges[j] = edges[j] " " idx[tmp[i]]
	}
	for (j = 1; j <= n; j++)
		if (!color[j])
			dfs(j)
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
' <"$file"
