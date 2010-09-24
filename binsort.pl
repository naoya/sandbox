#!/usr/local/bin/perl
use strict;
use warnings;
use Perl6::Say;

my @bin = ();
my @data = (7, 4, 2, 8, 1);

for (@data) {
    $bin[$_] = $_;
}

say for grep { defined $_ } @bin;


