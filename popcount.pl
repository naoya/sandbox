#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Test::More qw/no_plan/;

sub popcount ($) {
    use integer;

    my $r = shift;

    $r = (($r & 0xAAAAAAAA) >> 1) + ($r & 0x55555555);
    $r = (($r & 0xCCCCCCCC) >> 2) + ($r & 0x33333333);
    $r = (($r >> 4) + $r) & 0x0F0F0F0F;
    $r = ($r >> 8) + $r;

    return (($r >> 16) + $r) & 0x3F;
}

is popcount 8, 1;
is popcount 25, 3;
is popcount 255, 8;

popcount 256, 1;

say unpack('b*', pack('N', 360));

is popcount 257, 2;
is popcount 360, 4;


