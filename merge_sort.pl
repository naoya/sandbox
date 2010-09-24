#!/usr/local/bin/perl
use strict;
use warnings;
use Perl6::Say;
use Data::Dumper;

use constant INF => 100000;

my @data = (9, 8, 6, 5, 10, 11, 5, 2, 8, 4, 1, 0, 15, 12, 6);

my $res = merge_sort(\@data);

warn Data::Dumper::Dumper($res);

sub merge_sort {
    my $data = shift;

    if (@$data == 1) {
        return $data;
    }

    my $center = int( @$data / 2 ) - 1;

    ## 配列のマージソートでは配列をコピーせざるを得ない
    my $left  = merge_sort( [ @$data[0 .. $center] ] );
    my $right = merge_sort( [ @$data[$center + 1 .. @$data -1] ]);

    return merge($left, $right);
}

sub merge {
    my ($left, $right) = @_;
    my ($l, $r) = (0, 0);
    my @new;

    push @$left, INF;
    push @$right, INF;

    ## ループ終了条件がいまいち...
     while (1) {
         defined $left->[$l] or last;
         defined $right->[$r] or last;

         if ($left->[$l] < $right->[$r]) {
             push @new, $left->[$l];
             $l++;
         } else {
             push @new, $right->[$r];
             $r++;
         }
     }

    ## 番兵取り除く
    pop @new;

    return \@new;
}
