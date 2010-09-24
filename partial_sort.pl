#!/usr/local/bin/perl
# quick-sort based nth_element()

use strict;
use warnings;
use Perl6::Say;
use Data::Dumper;

my @data = (9, 8, 6, 5, 10, 20, 11, 5, 2, 8, 4, 1, 0, 15, 12, 6, 0);
my $loop = 0;

partial_sort(\@data, 0, $#data, 5); ## 0 0 1 2 4

say $loop;

warn Data::Dumper::Dumper( \@data );


sub partial_sort {
    my ($data, $start, $end, $k) = @_;

    $loop++;

    my $i     = $start;
    my $j     = $end - 1;
    my $pivot = $data->[$end];

    if ($j - $i <= 1) {
        return;
    }

    while (1) {
        while ($data->[$i] < $pivot) {
            $i++;
        }

        while ($i < $j && $data->[$j] > $pivot) {
            $j--;
        }

        if ($i >= $j) {
            last;
        }

        swap(\$data->[$i], \$data->[$j]);
    }

    swap(\$data->[$i], \$data->[$end]);

    ## k 個の要素群(の一部) を含まないパーティションをソートしない
    ## pivot 値が k 番目かそれ以降なら、左側だけ再起を施す
    ## O(n + klogk)

    ## left
    partial_sort($data,      0, $i - 1, $k);

    ## right
    if ($i < $k) {
        partial_sort($data, $i + 1, $end, $k);
    }
}

sub swap {
    my ($x, $y) = @_;
    my $tmp = $$x;
    $$x = $$y;
    $$y = $tmp;
}
