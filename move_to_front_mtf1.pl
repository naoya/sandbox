#!/usr/bin/env perl
# MTF-1
use strict;
use warnings;
use Perl6::Say;

use constant UCHAR_MAX => 0x100;

sub del (\@$) {
    my ($array, $i) = @_;
    if ($i > @$array - 1) {
        return;
    }

    my $value = $array->[$i];

    my $len = @$array;
    for (my $j = $i; $j < $len; $j++) {
        $array->[$j] = $array->[$j + 1];
    }
    pop @$array;

    return $value;
}

sub index_of (\@$) {
    my ($array, $c) = @_;
    for (my $i = 0; $i < @$array; $i++) {
        if ($array->[$i] == $c) {
            return $i;
        }
    }
}

sub insert_to_2nd (\@$) {
    my ($array, $c) = @_;
    my $first = pop @$array;
    unshift @$array, $first, $c;
}

sub mtf_encode ($) {
    my $str = shift;
    my @in = unpack('C*', $str);

    my @table;
    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $table[$i] = $i;
    }

    for (my $x = 0; $x < @in; $x++) {
        my $c = $in[$x];
        my $i = index_of @table, $c;

        if ($i == 1) {
            $table[1] = $table[0];
            $table[0] = $c;
        } elsif ($i > 1) {
            del @table, $i;
            insert_to_2nd @table, $c;
        }

        $in[$x] = $i;
    }
    return \@in;
}

sub mtf_decode ($) {
    my $in = shift;

    my @table;
    for (my $i = 0; $i < UCHAR_MAX; $i++) {
        $table[$i] = $i;
    }

    for (my $x = 0; $x < @$in; $x++) {
        my $i = $in->[$x];
        my $c = $table[$i];

        if ($i == 1) {
            $table[1] = $table[0];
            $table[0] = $c;
        } elsif ($i > 1) {
            del @table, $i;
            insert_to_2nd @table, $c;
        }

        $in->[$x] = $c;
    }

    return join '', map { chr } @$in;
}

package main;

my $str = shift or die "usage: $0 <string>";
my $enc = mtf_encode $str;

say join ' ', @$enc;

say "in : ", $str;
say "out: ", mtf_decode $enc;
