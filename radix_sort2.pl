#!/usr/local/bin/perl
# LSD radix sorting
# 先頭二文字で文字列をソート
use strict;
use warnings;
use Perl6::Say;

sub ch2index ($) {
    my $str = shift;
    my @c = unpack('C2', $str);
    return ($c[0] << 8) + $c[1];
}

my $list = [qw/naoya ito algorithm aibo ruby python perl php linux/];

my @count;
for (my $i = 0; $i < 0xff * 0xff; $i++) {
    $count[$i] = 0;
}

for (@$list) {
    my @c = unpack('C*', $_);
    $count[ ch2index $_ ]++;
}

for (my $i = 0; $i < 0xff * 0xff; $i++) {
    $count[$i + 1] += $count[$i];
}

my $sorted = [];
for (my $i = @$list - 1; $i >= 0; $i--) {
    my @c = unpack('C*', $list->[$i] );
    $sorted->[ --$count[ ch2index $list->[$i] ] ] = $list->[$i];
}

$list = $sorted;

say for @$list;
