#!/usr/local/bin/perl
# MSD radix sorting
# 先頭からソート
use strict;
use warnings;
use Perl6::Say;
use Params::Validate qw/validate_pos ARRAYREF/;

my $list = [ 3021, 58251, 34, 8, 1, 1322, 2, 780, 3, 1455 ];

radix_sort($list, 0, @$list - 1, 3);

say for @$list;

sub radix_sort {
    my ($buf, $low, $high, $n) = validate_pos(@_, { type => ARRAYREF }, 1, 1, 1);

    warn sprintf "low: %d, high: %d, n: %d\n", $low, $high, $n;

    my $shift = $n * 8;

    my @count;
    for (my $i = 0; $i < 0x100; $i++) {
        $count[$i] = 0;
    }

    for ($low .. $high) {
        $count[ ($buf->[$_] >> $shift) & 0xff ]++;
    }

    for (my $i = 0; $i < 0x100; $i++) {
        $count[$i + 1] += $count[$i];
    }

    my $work = [];
    for (my $i = $high; $i >= $low; $i--) {
        my $c = --$count[ ($buf->[$i] >> $shift) & 0xff ];

        ## + $low を加えるのは、その区間以外の桁をスキップしてるため
        $work->[ $c + $low ] = $buf->[$i];
    }

    ## LSD では $buf = $work で良かったが、MSD での work は
    ## 現在着目している区間以外の要素 が空。対象区間の要素だけを移す。
    for (my $i = $low; $i <= $high; $i++) {
        $buf->[$i] = $work->[$i];
    }

    warn sprintf "buffer: [ %s ]\n", join ', ', @$buf;

    ## 分布ソート後の count[] では low + count[i] ~ low * count[i + 1] - 1 が i の区間
    if ($n > 0) {
        for (my $i = 0; $i < 0x100; $i++) {
            my $l = $low + $count[$i];
            my $h = $low + $count[$i + 1] - 1;

            if ($l < $h) {
                radix_sort($buf, $l, $h, $n - 1);
            }
        }
    }
}
