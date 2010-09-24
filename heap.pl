#!/usr/bin/env perl
use strict;
use warnings;
use Perl6::Say;
use Data::Dumper;

my $heap = [ undef, 5, 9, 15, 12, 13 , 21, 18, 17, 15, 20 ];

warn Data::Dumper::Dumper( $heap );

say insert( $heap, 7 );
say insert( $heap, 10 );

warn Data::Dumper::Dumper( $heap );

say delete_min( $heap );
say delete_min( $heap );
say delete_min( $heap );
say delete_min( $heap );
say delete_min( $heap );
say delete_min( $heap );

warn Data::Dumper::Dumper( $heap );

say insert( $heap, 10 );
say insert( $heap, 9 );
say insert( $heap, 5 );

warn Data::Dumper::Dumper( $heap );

sub insert {
    my ($heap, $value) = @_;
    push @$heap, $value;

    up_heap( $heap, @$heap - 1);

    $value;
}

sub up_heap {
    my ($heap, $node) = @_;

    my $parent = int($node / 2);

    if ($parent < 1) {
        return;
    }

    if ($heap->[$node] < $heap->[$parent]) {
        swap(\$heap->[$node], \$heap->[$parent]);
        up_heap($heap, $parent);
    } else {
        return;
    }
}

sub delete_min {
    my $heap = shift;
    my $min  = $heap->[1];
    $heap->[1] = pop @$heap;

    down_heap( $heap, 1 );

    $min;
}

sub down_heap {
    my ($heap, $node) = @_;

    my $left  = 2 * $node;
    my $right = 2 * $node + 1;

    if (not defined $heap->[$left] and not defined $heap->[$right]) {
        return;
    }

    if ((defined $heap->[$left] and not defined $heap->[$right]) || $heap->[$left] < $heap->[$right]) {
        if ($heap->[$left] < $heap->[$node]) {
            swap(\$heap->[$left], \$heap->[$node]);
            down_heap( $heap, $left );
        } else {
            return;
        }
    } else {
        if ($heap->[$right] < $heap->[$node]) {
            swap(\$heap->[$right], \$heap->[$node]);
            down_heap( $heap, $right );
        } else {
            return;
        }
    }
}

sub swap {
    my ($x, $y) = @_;
    my $tmp = $$x;
    $$x = $$y;
    $$y = $tmp;
}
