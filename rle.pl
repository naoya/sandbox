#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;
use Params::Validate qw/:all/;

sub encode_vb ($) {
    pack('w', shift)
}

sub decode_vb ($) {
    unpack('w', shift)
}

sub decode_vbx ($) {
    my ($binref) = validate_pos(@_, { type => SCALARREF });

    my $n = decode_vb $$binref;
    substr($$binref, 0, length encode_vb $n) = '';

    return $n;
}

sub rle ($) {
    my $in = shift;
    my @in = split //, $in;

    my $prev = shift @in; ## 処理中の文字
    my $run  = 0;         ## 繰り返し回数
    my $out;

    for (@in) {
        if ( $_ eq $prev ) {
            $run++;
        } else {
            $out .= encode_vb $run;
            $out .= $prev;

            $prev = $_;
            $run  = 0;
        }
    }

    ## 残りを出力
    $out .= encode_vb $run;
    $out .= $prev;

    return $out;
}

sub rld ($) {
    my $in  = shift;
    my $out;

    while (length $in > 0) {
        my $run = decode_vbx(\$in);
        my $c   = substr($in, 0, 1);

        $out .= $c for 0..$run;
        substr($in, 0, 1) = '';
    }

    $out;
}

my $str = "zaaaaaaabbbbbbbccccccddddddddddddddddddddddddddddddddd";
my $rle = rle $str;

say $rle;
say rld( $rle );
say rld($rle) eq $str;
