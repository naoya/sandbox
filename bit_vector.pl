#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

my $bin = pack("b*", "10110111011");

for (0..10) {
    print vec($bin, $_, 1 );
}

print "\n";
