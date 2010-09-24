#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;

use constant UCHAR_MAX => 0x100;

my $str = "abracadabra\$";
my @chars = unpack('C*', $str);

my @freq;
for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $freq[$i] = 0;
}

for (@chars) {
    $freq[$_]++;
}

say @freq;

my @cum = (0);
for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $cum[$i] = $cum[$i - 1] + $freq[$i];
}

say @cum;

my @sorted;
my $n = @chars;
for (my $i = $n - 1; $i >= 0; $i--) {
    $sorted[ --$cum[ $chars[$i] ] ] = $i;
}

# say chr for @sorted;
say for @sorted;
