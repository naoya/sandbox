#!/usr/local/bin/perl
use strict;
use warnings;
use Perl6::Say;

## 累積度数分布
my %count;
my @data = (7, 1, 4, 2, 7, 8, 2);

## キーの出現頻度
for (@data) {
    $count{$_}++ ;
}

## 10 までの累積度数分布
for (0..10) {
    $count{$_ + 1} += $count{$_} || 0;
}

my @sorted;

my $n = @data;
for (my $i = $n - 1; $i >= 0; $i--) {
    $sorted[--$count{ $data[$i] }] = $data[$i];
}

say for grep { defined $_ } @sorted;
