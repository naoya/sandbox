#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Perl6::Say;

my @array = (8, 7, 9, 5, 5, 2, 3, 4, 8, 1);

for (my $i = 1; $i < @array; $i++) {
    my $n = $array[$i];
    my $j = $i - 1;

    while ($j >= 0 and $n < $array[$j]) {
        $array[$j + 1] = $array[$j];
        $j--;
    }

    $array[$j + 1] = $n;
}

say for @array;
