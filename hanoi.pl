#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

## say の行が円盤を移動したことになる
sub hanoi {
    my ($n, $t1, $t2, $t3) = @_;

    if ($n == 1) {
        say sprintf "move D1 from %s to %s", $t1, $t2;
    } else {
        ## まず n - 1 個すべてを合法的に t3 (右)に移動
        hanoi($n - 1, $t1, $t3, $t2);

        ## t1 (左)には円盤n だけが残ったので、円盤n は t2 に移動できる。ゆえに移動
        say sprintf "move D%d from %s to %s", $n, $t1, $t2;

        ## 合法的に n - 1 個を t2 に移動
        hanoi($n - 1, $t3, $t2, $t1);
    }
}

hanoi 3, 'A', 'B', 'C';
