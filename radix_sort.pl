#!/usr/local/bin/perl
# LSD radix sorting

use strict;
use warnings;
use Perl6::Say;
use Data::Dumper;

use constant MASK => 0xff;

my $list = [35, 40, 1, 5, 10, 2, 32, 12, 3, 32, 8, 33, 1024, 52, 1231235, 3123, 4];

for (my $shift = 0; $shift < 4; $shift++) {

    my @count;
    for (my $i = 0; $i < 0x100; $i++) {
        $count[$i] = 0;
    }

    for (@$list) {
        $count[ $_ >> $shift * 8 & MASK ]++;
    }

    for (my $i = 0; $i < 0x100; $i++) {
        $count[$i + 1] += $count[$i];
    }

    my $sorted = [];
    for (my $i = @$list - 1; $i >= 0; $i--) {
        $sorted->[ --$count[ $list->[$i] >> $shift * 8 & MASK ] ] = $list->[$i];
    }

    $list = $sorted;
}

say for @$list;

