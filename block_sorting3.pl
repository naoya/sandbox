#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Params::Validate qw/validate_pos SCALARREF/;
use Path::Class qw/file/;

use Array::Util qw/delete_at index_of/;
use Algorithm::DivSufSort qw/divsufsort/;

use constant UCHAR_MAX => 0x100;

use List::Rubyish;

sub bs_encode ($) {
    my $text = shift;
    my @text = split //, $text;
    return join '', map { $text[$_ - 1] } @{ divsufsort($text) };
}

sub bs_decode ($) {
    my $data = shift;

    my $pos = - 1;
    my @data = split //, $data;
    my $len  = length $data;
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

    my @buff;
    for (0..$len - 1) {
        $pos = $LFmapping[ $pos ];
        push @buff, $data[ $pos ];
    }

    return join '', @buff;
}

sub mtf_encode ($) {
    my $str = shift;
    my @in = unpack('C*', $str);

    my @table;
    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $table[$i] = $i;
    }

    my @buf;
    for my $c (@in) {
        my $i = index_of @table, $c;
        push @buf, $i;
        if ($i > 0) {
            delete_at @table, $i;
            unshift @table, $c;
        }
    }
    return \@buf;
}

sub mtf_decode ($) {
    my $in = shift;

    my @table;
    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $table[$i] = $i;
    }

    my @buf;
    for my $i (@$in) {
        my $c = $table[$i];
        push @buf, $c;

        if ($i > 0) {
            delete_at @table, $i;
            unshift @table, $c;
        }
    }

    return join '', map { chr } @buf;
}

# my $file = shift or die "usage: $0 <file>";
# my $text = file($file)->slurp;
my $text = shift;
my $bwt = bs_encode( $text );

say $bwt;

# my $mtf = mtf_encode($bwt);
# say join ' ', @$mtf;
# say mtf_decode( $mtf );
# say bs_decode( \$bwt );
