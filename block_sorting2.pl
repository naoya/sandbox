#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;

use constant UCHAR_MAX => 0x100;

sub bs_encode ($) {
    my $data = shift;

    my @data = split //, $data;
    my @index = sort {
        my $r;
        for (my $i = 0; $i < @data; $i++) {
            $r = ord $data[$a + $i] <=> ord $data[$b + $i];

            if ($r != 0) {
                return $r;
            }
        }
        return 0;
    } (0.. @data - 1);

    ## $data[$i] はソート済みブロックの先頭文字 (LF Mapping の F)
    ## $data[$i - 1] は LFMapping の L
    ## $i == 0 の時は $data[-1] で最後の文字 "$" が来るのを利用
    my @buf;
    for my $i (@index) {
        ## 添え字 -1 が使えないなら $i == 0 の時は "\$" 決めうち
        ## push @buf, $i == 0 ? "\$" : $data[$i - 1];
        push @buf, $data[$i - 1];
    }

    return join '', @buf;
}

sub bs_decode ($) {
    my $data = shift;

    my $pos = - 1;
    my @data = split //, $data;
    my $len  = @data;
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

    my @buff;
    my @LFmapping;
    for (my $i = $len - 1; $i >= 0; $i--) {
        $LFmapping[ --$count[ ord $data[$i] ] ] = $i;
    }

    for (0..$len - 1) {
        $pos = $LFmapping[ $pos ];
        push @buff, $data[ $pos ];
    }

    return join '', @buff;
}

my $string = shift or die "usage: $0 <string>";
# my $string = file(shift)->slurp;

my $bwt = bs_encode $string;

say $bwt;

say bs_decode $bwt;
