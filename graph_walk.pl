#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

use constant A => 0;
use constant B => 1;
use constant C => 2;
use constant D => 3;
use constant E => 4;
use constant F => 5;
use constant G => 6;

sub dump_adjacent ($) {
    my $adj = shift;
    for (@$adj) {
        say sprintf "[ %s ]", join ", ", @$_;
    }
}

sub contains ($$) {
    my ($path, $x) = @_;
    for (@$path) { return 1 if $x == $_ }
    return;
}

## 深さ優先探索は再帰を使うのがポイント
## path に search に入る前に次のノードを追加し, search から出る時にノードを path から除く
## search から出てきた == ゴールじゃなかった == バックトラック、なので
sub depth_first ($$$) {
    my ($adj, $start, $goal) = @_;
    df_search($adj, $goal, [ $start ]);
}

sub df_search {
    my ($adj, $goal, $path) = @_;
    my $cur = $path->[-1];

    if ($cur == $goal) {
        printf "[ %s ]\n", join ', ', @$path;
    } else {
        for (@{$adj->[$cur]}) {
            if (not contains $path, $_) {
                push @$path, $_;
                df_search($adj, $goal, $path);
                pop @$path;
            }
        }
    }
}

## 幅優先は queue を使う、path を都度コピーするのがポイント
## queue に入れるのは path
## なぜコピーするか? : 次の一手で分岐が発生するがそれを総当たりするため
sub breadth_first {
    my ($adj, $start, $goal) = @_;
    my $path = [ $start ];
    my @q = ($path) ;

    while (@q > 0) {
        my $path = shift @q;
        my $cur = $path->[-1];
        if ($cur == $goal) {
            printf "[ %s ]\n", join ', ', @$path;
        } else {
            for (@{$adj->[$cur]}) {
                if (not contains $path, $_) {
                    my @new_path = @$path;
                    push @new_path, $_;
                    push @q, \@new_path;
                }
            }
        }
    }
}

my $adj = [];

$adj->[A] = [ B, C ];
$adj->[B] = [ A, C, D ];
$adj->[C] = [ A, B, E ];
$adj->[D] = [ B, E, F ];
$adj->[E] = [ C, D, G ];
$adj->[F] = [ D ];
$adj->[G] = [ E ];

say dump_adjacent $adj;

depth_first $adj, A, G;

say;

breadth_first $adj, A, G;
