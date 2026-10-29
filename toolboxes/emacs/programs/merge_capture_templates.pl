# Merge dir-locals fragments into one ((MODE . VARS) ...) form.
# Usage: merge_capture_templates FRAGMENT...
#
# Every fragment is one form: ((MODE . ((VAR . VALUE) ...)) ...). The
# fragments are spliced into a single list, in the order given, so for any
# repeated variable the later fragment wins. org-capture-templates is the
# exception: its entries are pulled out of every fragment and gathered
# into one final entry per MODE, so each fragment adds templates instead of
# replacing the others. Within a MODE, a template whose key (its first
# element, such as "b") was already seen replaces the earlier one.
# Prints nothing when given no fragments.
use strict;
use warnings;

# Position after any whitespace and ;-comments at or after $p.
sub skip_ws {
    my ($s, $p) = @_;
    while ($p < length $s) {
        my $c = substr($s, $p, 1);
        if ($c =~ /\s/) {
            $p++;
        } elsif ($c eq ';') {
            my $nl = index($s, "\n", $p);
            $p = $nl < 0 ? length $s : $nl + 1;
        } else {
            last;
        }
    }
    return $p;
}

# End position of the Lisp form starting at or after $p.
sub read_form {
    my ($s, $p, $file) = @_;
    $p = skip_ws($s, $p);
    die "$file: unexpected end of input\n" if $p >= length $s;
    my $c = substr($s, $p, 1);
    if ($c eq '(' || $c eq '[') {
        $p++;
        while (1) {
            $p = skip_ws($s, $p);
            die "$file: unbalanced parentheses\n" if $p >= length $s;
            my $d = substr($s, $p, 1);
            return $p + 1 if $d eq ')' || $d eq ']';
            $p = read_form($s, $p, $file);
        }
    }
    die "$file: unexpected closing parenthesis\n" if $c eq ')' || $c eq ']';
    if ($c eq '"') {
        $p++;
        while ($p < length $s) {
            my $d = substr($s, $p, 1);
            return $p + 1 if $d eq '"';
            $p += $d eq '\\' ? 2 : 1;
        }
        die "$file: unterminated string\n";
    }
    if ($c =~ /['`,]/) {
        $p++;
        $p++ if substr($s, $p, 1) eq '@';
        return read_form($s, $p, $file);
    }
    return read_form($s, $p + 2, $file) if substr($s, $p, 2) eq "#'";
    if ($c eq '?') {
        $p++;
        $p += substr($s, $p, 1) eq '\\' ? 2 : 1;
    }
    $p++ while $p < length $s && substr($s, $p, 1) !~ /[\s()\[\]";]/;
    return $p;
}

# [start, end] of each form between $from and $to.
sub split_forms {
    my ($s, $from, $to, $file) = @_;
    my @spans;
    my $p = skip_ws($s, $from);
    while ($p < $to) {
        my $e = read_form($s, $p, $file);
        die "$file: form runs past its list\n" if $e > $to;
        push @spans, [$p, $e];
        $p = skip_ws($s, $e);
    }
    return @spans;
}

my @modes;       # MODE texts, in order first seen
my %keys;        # MODE => template keys, in order first seen
my %templates;   # MODE => key => template text

sub add_template {
    my ($mode, $key, $text) = @_;
    push @modes, $mode unless exists $keys{$mode};
    push @{ $keys{$mode} }, $key unless exists $templates{$mode}{$key};
    $templates{$mode}{$key} = $text;
}

# The fragment's inner text, minus every org-capture-templates variable.
sub process {
    my ($file) = @_;
    open my $fh, '<', $file or die "$file: $!\n";
    my $s = do { local $/; <$fh> };
    close $fh;

    my $start = skip_ws($s, 0);
    my $end = read_form($s, $start, $file);
    die "$file: not a list\n" unless substr($s, $start, 1) eq '(';
    die "$file: text after the form\n" if skip_ws($s, $end) < length $s;
    my ($from, $to) = ($start + 1, $end - 1);

    my @cuts;
    for my $entry (split_forms($s, $from, $to, $file)) {
        my ($eb, $ee) = @$entry;
        next unless substr($s, $eb, 1) eq '(';
        my $q = skip_ws($s, $eb + 1);
        my $mode_end = read_form($s, $q, $file);
        my $mode = substr($s, $q, $mode_end - $q);
        $q = skip_ws($s, $mode_end);
        my ($vf, $vt);
        if (substr($s, $q, 1) eq '.' && substr($s, $q + 1, 1) =~ /[\s(]/) {
            $q = skip_ws($s, $q + 1);
            next unless substr($s, $q, 1) eq '(';
            ($vf, $vt) = ($q + 1, read_form($s, $q, $file) - 1);
        } else {
            ($vf, $vt) = ($q, $ee - 1);
        }
        for my $var (split_forms($s, $vf, $vt, $file)) {
            my ($vb, $ve) = @$var;
            next unless substr($s, $vb, 1) eq '(';
            my $n = skip_ws($s, $vb + 1);
            my $name_end = read_form($s, $n, $file);
            next unless substr($s, $n, $name_end - $n) eq 'org-capture-templates';
            my $v = skip_ws($s, $name_end);
            $v = skip_ws($s, $v + 1) if substr($s, $v, 1) eq '.';
            next unless substr($s, $v, 1) eq '(';
            my $list_end = read_form($s, $v, $file);
            next if skip_ws($s, $list_end) != $ve - 1;
            for my $t (split_forms($s, $v + 1, $list_end - 1, $file)) {
                my ($tb, $te) = @$t;
                my $k;
                if (substr($s, $tb, 1) eq '(') {
                    my $ks = skip_ws($s, $tb + 1);
                    $k = substr($s, $ks, read_form($s, $ks, $file) - $ks);
                } else {
                    $k = substr($s, $tb, $te - $tb);
                }
                add_template($mode, $k, substr($s, $tb, $te - $tb));
            }
            push @cuts, [$vb, $ve];
        }
    }

    my $cut_len = 0;
    for my $c (reverse @cuts) {
        substr($s, $c->[0], $c->[1] - $c->[0], '');
        $cut_len += $c->[1] - $c->[0];
    }
    return substr($s, $from, $to - $from - $cut_len);
}

exit 0 unless @ARGV;
my @bodies = map { process($_) } @ARGV;

print "(\n";
print "$_\n" for @bodies;
for my $mode (@modes) {
    print "($mode . ((org-capture-templates . (\n";
    print "  $templates{$mode}{$_}\n" for @{ $keys{$mode} };
    print "))))\n";
}
print ")\n";
