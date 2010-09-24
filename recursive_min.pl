#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

## 区間を半分ずつ狭めながら最小値を再帰的に求める
## 分割統治法
sub min {
    my ($a, $i, $j) = @_;
    use integer;

    if ($i == $j) {
        return $a->[$i];
    }

    my $k = ($i + $j) / 2;
    my $x = min($a, $i, $k);
    my $y = min($a, $k + 1, $j);

    $x < $y ? return $x : return $y;

    die 'assert';
}

my $a = [5, 8, 9, 2, 3, 4, 2, 7, 8, 9, 100];

say min $a, 0, @$a - 1;
