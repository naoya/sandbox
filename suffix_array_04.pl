#!/usr/bin/env perl
# suffix_array_03.pl の build_sa() を番兵にしたもの
use strict;
use warnings;

use Test::More qw/no_plan/;

## FIXME: 2 インプレイスソートに変更
## FIXME: 3 クラス版
## FIXME: 4 マルチキークイックソート
## FIXME: 5 libdivsufsort
sub build_sa {
    my ($buf, $SA) = @_;
    push @$buf, 0;
    my $last = @$buf - 1;

    my $cmp = sub {
        my ($i, $j) = ($a, $b);

        while ($i < $last or $j < $last) {
            my $diff = $buf->[$i] - $buf->[$j];
            if ($diff == 0) {
                $i++;
                $j++;
            } else {
                return $diff;
            }
        }

        return 0;
    };

    @$SA = sort $cmp @$SA;
    pop @$buf;
}

sub sa_search {
    my ($q, $buf, $SA) = @_;
    my $buf_q = [ unpack('C*', $q) ];
    my $len_q = length $q;

    ## bsearch_first: ここちゃんと理解しないと
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

my $text = "abracadabra";
my $len  = length $text;
my $buf  = [ unpack('C*', $text) ];
my $SA   = [];

for (my $i = 0; $i < $len; $i++) {
    $SA->[$i] = $i;
}

build_sa($buf, $SA);

is sa_search("a",         $buf, $SA),  0;
is sa_search("ab",        $buf, $SA),  1;
is sa_search("abr",       $buf, $SA),  1;
is sa_search("abra",      $buf, $SA),  1;
is sa_search("abrac",     $buf, $SA),  2;
is sa_search("aca",       $buf, $SA),  3;
is sa_search("ada",       $buf, $SA),  4;
is sa_search("bra",       $buf, $SA),  5;
is sa_search("brac",      $buf, $SA),  6;
is sa_search("cada",      $buf, $SA),  7;
is sa_search("dabra",     $buf, $SA),  8;
is sa_search("r",         $buf, $SA),  9;
is sa_search("ra",        $buf, $SA),  9;
is sa_search("rac",       $buf, $SA), 10;
is sa_search("racadabra", $buf, $SA), 10;

ok not sa_search("hoge", $buf, $SA);
ok not sa_search("braz", $buf, $SA);
ok not sa_search("az",   $buf, $SA);
