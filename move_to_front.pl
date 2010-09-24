#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Array::Util qw/delete_at index_of/;

use constant UCHAR_MAX => 0x100;

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

package main;

my $str = shift or die "usage: $0 <string>";

my $enc = mtf_encode $str;

say join ' ', @$enc;

say "in : ", $str;
say "out: ", mtf_decode $enc;
