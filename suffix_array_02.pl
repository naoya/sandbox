#!/usr/bin/env perl
use strict;
use warnings;

## FIXME: 1 番兵に改造
## FIXME: 2 インプレイスソートに変更
## FIXME: 3 クラス版
## FIXME: 4 マルチキークイックソート
## FIXME: 5 libdivsufsort
sub build_sa {
    my ($buf, $SA) = @_;
    my $last = @$buf - 1;

    my $cmp = sub {
        my ($i, $j) = ($a, $b);

        while ($i < $last or $j < $last) {
            my $diff = $buf->[$i] - $buf->[$j];
            if ($diff == 0) {
                if ( $i < $last ) { $i++ }
                if ( $j < $last ) { $j++ }
            } else {
                return $diff;
            }
        }

        return 0;
    };

    @$SA = sort $cmp @$SA;
}

sub sa_search {
    my ($q, $buf, $SA) = @_;
    my $buf_q = [ unpack('C*', $q) ];
    my $len_q = length $q;

    use integer;
    my $l = -1;
    my $u = @$buf;

    while ($l + 1 != $u) {
        my $m = ($l + $u) / 2;
        if (strncmp($buf_q, 0, $buf, $SA->[$m], $len_q) > 0) {
            $l = $m;
        } else {
            $u = $m;
        }
    }

    if ($u >= @$buf || strncmp($buf_q, 0, $buf, $SA->[$u], $len_q) != 0) {
        return;
    }

    return $u;
}

sub strcmp {
    my ($s1, $n1, $s2, $n2) = @_;
    no warnings 'uninitialized';
    while ($s1->[$n1] == $s2->[$n2++]) {
        if (not defined $s1->[$n1++]) {
            return 0;
        }
    }
    return ($s1->[$n1] - $s2->[--$n2]) > 0 ? 1 : -1;
}

sub strncmp {
    my ($s1, $n1, $s2, $n2, $n) = @_;
    no warnings 'uninitialized';

    if ($n == 0) {
        return 0;
    }

    LOOP: {
        do {
            if ($s1->[$n1] != $s2->[$n2++]) {
                return ($s1->[$n1] - $s2->[--$n2]) > 0 ? 1 : -1;
            }
            if (not defined $s1->[$n1++]) {
                last;
            }
        } while (--$n != 0);
    }

    return 0;
}

sub show_sa {
    my ($text, $SA) = @_;
    my $len = @$SA;
    for (my $i = 0; $i < $len; $i++) {
        printf(
            "sa[%2d] = %2d, substr(\$text, %2d) = %s\n",
            $i,
            $SA->[$i],
            $SA->[$i],
            substr($text, $SA->[$i]),
        );
    }
    print "\n";
}

my $text  = shift;
my $q     = shift or die "$0 <text> <query>\n";

my $len = length $text;
my $buf = [ unpack('C*', $text) ];
my $SA  = [];

for (my $i = 0; $i < $len; $i++) {
    $SA->[$i] = $i;
}

show_sa($text, $SA);

build_sa($buf, $SA);

show_sa($text, $SA);

my $pos = sa_search($q, $buf, $SA);

if (not defined $pos) {
    exit(-1);
}

warn sprintf "pos: %d, SA[%d]: %d\n", $pos, $pos, $SA->[$pos];

while ($q eq substr($text, $SA->[$pos], length $q) ){
    printf "%2d => %s\n", $SA->[$pos], substr($text, $SA->[$pos]);
    $pos++;
    defined $SA->[$pos] or last;
}
