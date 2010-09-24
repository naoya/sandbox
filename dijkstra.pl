#!/usr/bin/env perl
use strict;
use warnings;

package Node;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/id done cost edges_to prev/);

package Queue;
use base qw/Class::Accessor::Lvalue::Fast/;
__PACKAGE__->mk_accessors(qw/heap heap_contains/);

use Heap::Simple;
use Params::Validate qw/validate_pos/;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->heap          = Heap::Simple->new(elements => 'Any');
    $self->heap_contains = [];

    return $self;
}

sub push {
    my ($self, $node) = validate_pos(@_, 1, 1);
    $self->heap->key_insert( $node->cost => $node );
    $self->heap_contains->[$node->id] = 1;
}

sub pop {
    my $self = shift;
    my $node = $self->heap->extract_first or return;
    $self->heap_contains->[$node->id] = 0;
    return $node;
}

sub contains {
    my ($self, $node) = validate_pos(@_, 1, 1);
    return $self->heap_contains->[$node->id];
}

package main;
use Perl6::Say;
use Heap::Simple;

## edges_to は添字 0 が次のノード、添字1 がエッジのコスト
my $nodes = [
    Node->new({
        id => 0,
        edges_to => [
            [ 1, 5 ],
            [ 2, 4 ],
            [ 3, 2 ],
        ],
    }),

    Node->new({
        id => 1,
        edges_to => [
            [ 0, 5 ],
            [ 2, 2 ],
            [ 5, 6 ],
        ],
    }),

    Node->new({
        id => 2,
        edges_to => [
            [ 0, 4 ],
            [ 1, 2 ],
            [ 3, 3 ],
            [ 4, 2 ],
        ],
    }),

    Node->new({
        id => 3,
        edges_to => [
            [ 0, 2 ],
            [ 2, 3 ],
            [ 4, 6 ],
        ],
    }),

    Node->new({
        id => 4,
        edges_to => [
            [ 2, 6 ],
            [ 3, 2 ],
            [ 5, 4 ],
        ],
    }),

    Node->new({
        id => 5,
        edges_to => [
            [ 1, 6 ],
            [ 4, 4 ],
        ],
    }),
];

## start
$nodes->[0]->cost = 0;

my $q = Queue->new;
$q->push( $nodes->[0] );

## done が今着目中のノード。目の前にあるもののうち最小のもの (greedy)
while (my $done = $q->pop) {
    # $done->done = 1;

    ## done に隣接するノードのコストを計算
    for my $to (@{$done->edges_to}) {
        my $i    = $to->[0];
        my $cost = $done->cost + $to->[1]; ## コストは done のコスト + to までのエッジのコスト

        ## コストが今持ってるものよりも小さかったら更新
        if ( not defined $nodes->[$i]->cost or $cost < $nodes->[$i]->cost ) {
            $nodes->[$i]->cost = $cost;
            $nodes->[$i]->prev = $done->id;

            if (!$q->contains($nodes->[$i])) {
                $q->push( $nodes->[$i] );
            }
        }
    }
}

for (my $i = 1; $i < @$nodes; $i++) {
    local $_ = $nodes->[$i];
    say sprintf "id: %d, prev: %d, cost: %d", $_->id, $_->prev, $_->cost;
}


