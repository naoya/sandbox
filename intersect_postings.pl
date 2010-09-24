#!/usr/bin/env perl
# examples from IIR P.10 Fig 1.5
# an algorithm from IIR P.11 Fig 1.6
use strict;
use warnings;
use Test::More qw/no_plan/;

sub intersect ($$) {
    my ($p1, $p2) = @_;
    my $answer = [];

    my $i = 0;
    my $j = 0;

    while (defined $p1->[$i] and defined $p2->[$j]) {
        if ($p1->[$i] == $p2->[$j]) {
            push @$answer, $p1->[$i];
            $i++;
            $j++;
        } else {
            $p1->[$i] < $p2->[$j] ? $i++ : $j++;
        }
    }

    return $answer;
}

my $brutus    = [ 1, 2, 4, 11, 31, 45, 173, 174 ];
my $calpurnia = [ 2, 31, 54, 101 ];

my $intersectioned = intersect $brutus, $calpurnia;

is_deeply $intersectioned, [ 2, 31 ];

