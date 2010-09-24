#!/usr/bin/env perl
use strict;
use warnings;

use Perl6::Say;

sub bs_encode ($) {
    my $data = shift;

    my $size = length $data;
    my @datadata = split //, $data x 2;

    ## ここのソートが O(n^2 log n), 要改善
    my @index = sort {
        my $r;
        for (my $i = 0; $i < $size; $i++) {
            $r = $datadata[$a + $i] cmp $datadata[$b + $i];
            if ($r != 0) {
                return $r;
            }
        }
        return 0;
    } (0..$size -1);

    my @buf;
    for (@index) {
        push @buf, $datadata[$_ + $size - 1];
    }

    return join '', @buf;
}

use constant UCHAR_MAX => 0x100;

sub bs_decode ($) {
    my $bwt = shift;

    my $len  = length $bwt;
    my @data = split //, $bwt;
    my $pos = - 1;

    my @count;
    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $count[$i] = 0;
    }

    for (my $i = 0; $i < $len; $i++) {
        if ($data[$i] eq "\$") {
            $pos = $i;
        }
        $count[ ord $data[$i] ]++;
    }

    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $count[$i] += $count[$i - 1];
    }

    my @LFmapping;
    for (my $i = $len - 1; $i >= 0; $i--) {
        $LFmapping[ --$count[ ord $data[$i] ] ] = $i;
    }

    my @buf;
    for (0..$len - 1) {
        $pos = $LFmapping[ $pos ];
        push @buf, $data[ $pos ];
    }

    return join '', @buf;
}

my $string = shift or die "usage $0 <text>";
my $bwt = bs_encode $string;

say $bwt;

say bs_decode $bwt;
