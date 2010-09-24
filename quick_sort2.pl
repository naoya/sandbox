#!/usr/local/bin/perl
# 1. pivot を 3 つの値から選択する
# 2. 数が小さくなったら挿入ソートに切り替える
use strict;
use warnings;

use integer;
use Perl6::Say;
use Data::Dumper;

use constant LIMIT => 5;

my @data = (9, 8, 6, 5, 10, 11, 5, 2, 8, 4, 1, 0, 15, 12, 6);

quick_sort(\@data, 0, $#data);

warn Data::Dumper::Dumper( \@data );

sub quick_sort {
    my ($data, $low, $high) = @_;

    if ($high - $low <= LIMIT) {
        insert_sort($data);
    } else {
        my $pivot = select_pivot( $data, $low, $high );
        my $i     = $low;
        my $j     = $high;

        while (1) {
            while ($pivot > $data->[$i]) {
            $i++;
        }

            while ($pivot < $data->[$j]) {
                $j--;
            }

            if ($i >= $j) {
                last;
            }

            ($data->[$i], $data->[$j]) = ($data->[$j], $data->[$i]);

            $i++;
            $j--;
        }

        if ($low < $i - 1) {
            quick_sort($data, $low, $i - 1);
        }

        if ($high > $j + 1) {
            quick_sort($data, $j + 1, $high);
        }
    }
}

sub select_pivot {
    my ($array, $low, $high) = @_;

    my $a = $array->[$low];
    my $b = $array->[ ($low + $high) / 2 ];
    my $c = $array->[$high];

    if ($array->[$low] > $array->[$high]) {
        ($a, $b) = ($b, $a);
    }

    if ($b > $c) {
        $b = $c;

        if ($a > $b) {
            $b = $a;
        }
    }

    return $b;
}

sub insert_sort {
    my $array = shift;

    for (my $i = 1; $i < @$array; $i++) {
        my $n = $array->[$i];
        my $j = $i - 1;

        while ($j >= 0 and $n < $array->[$j]) {
            $array->[$j + 1] = $array->[$j];
            $j--;
        }

        $array->[$j + 1] = $n;
    }

    return $array;
}
