#!/usr/bin/env perl
# Fenwick Tree a.k.a. Binary indexed tree
# (1) Fenwick tree is able to compute cumulative sum of any range of consecutive elements in O(lg n)
# (2) Changing value of any single element needs O(lg n) time as well
use strict;
use warnings;
use Perl6::Say;

package Tree::Fenwick;

use Params::Validate qw/validate_pos/;

sub new {
    my ($class, $n) = validate_pos(@_, 1, 1);
    my $self = bless [], $class;

    for (my $i = 0; $i < $n; $i++) {
        $self->[$i] = 0;
    }

    return $self;
}

sub query {
    my ($self, $low, $high) = validate_pos(@_, 1, 1, 1);

    if ($low == 0) {
        my $sum = 0;
        for (; $high >= 0; $high = ($high & ($high + 1)) - 1) {
            $sum += $self->[$high];
        }
        return $sum;
    } else {
        return $self->query(0, $high) - $self->query(0, $low - 1);
    }


sub increase {
    my ($self, $k, $inc) = validate_pos(@_, 1, 1, 1);
    my $size = @$self;
    for (; $k < $size; $k |= $k + 1) {
        $self->[$k] += $inc;
    }
}

package main;

my $text = "abracadabra\$";
my @char = unpack('C*', $text);

my $tree = Tree::Fenwick->new(0x100);

for my $c (@char) {
    $tree->increase($c, 1);
}

# say "\n## Fenwick Tree";

require Data::Dumper;
warn join ' ', @$tree;

say $tree->query(0, ord 'a');
say $tree->query(0, ord 'b');
say $tree->query(0, ord 'c');
say $tree->query(ord 'b', ord 'b');
say $tree->query(ord 'b', ord 'c');

$tree->increase(ord 'a', 5);
say $tree->query(0, ord 'a'); # 11

my @count;
for (my $i = 0; $i < 0x100; $i++) {
    $count[$i] = 0;
}

for my $c (@char) {
    $count[$c]++;
}

for (my $i = 1; $i < 0x100; $i++) {
    $count[$i + 1] += $count[$i];
}

say "\n## O(n)";

say join ' ', @count;
say $count[ord 'a'];
say $count[ord 'b'];
say $count[ord 'c'];
