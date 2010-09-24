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

sub intersect_terms (@) {
    my $index = shift;

    ## df 昇順に単語をソートする
    ## この例では postings に配列を使うので配列サイズで df を取得するが、
    ## 実践では df はインデクシング時に term 毎に別途記録する
    my @terms = sort {
        my $p1 = $index->{$a};
        my $p2 = $index->{$b};
        @$p1 <=> @$p2;
    } @_;

    my $result = $index->{shift @terms};
    while (@terms > 0 and defined $result) {
        $result = intersect $result, $index->{shift @terms};
    }

    return $result;
}

my $index = {
    brutus    => [ 1, 2, 4, 11, 31, 45, 173, 174 ],
    caesar    => [ 1, 2, 4,  5,  6, 16,  31, 57, 132, 255, 312, 385 ],
    calpurnia => [ 2, 31, 54, 101 ],
};

my $intersectioned = intersect_terms $index, 'brutus', 'caesar', 'calpurnia';

is_deeply $intersectioned, [ 2, 31 ];
