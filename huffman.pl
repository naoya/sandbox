#!/usr/bin/env perl
use strict;
use warnings;

package Node;
use base qw/Class::Accessor::Lvalue::Fast/;
__PACKAGE__->mk_accessors(qw/left right ascii/);

sub is_leaf {
    my $self = shift;
    !$self->left and !$self->right;
}

package main;
use Perl6::Say;
use Heap::Simple;

sub build_huffman_tree {
    my $text = shift;

    my $count = [];
    for (my $i = 0; $i < 0xff; $i++) {
        $count->[$i] = 0;
    }

    for (unpack("C*", $text)) {
        $count->[$_]++;
    }

    my $heap = Heap::Simple->new(elements => 'Array', order => '<');

    for (my $i = 0; $i < 0xff; $i++) {
        if ($count->[$i] > 0) {
            $heap->insert([ $count->[$i], Node->new({ ascii => $i }) ]);
        }
    }

    while (1) {
        my $x = $heap->extract_first;
        my $y = $heap->extract_first;

        if (not defined $y) {
            return $x->[1];
        }

        my $z = Node->new;
        $z->left  = $x->[1];
        $z->right = $y->[1];

        $heap->insert([ $x->[0] + $y->[0], $z ]);
    }
}

sub traverse {
    my ($node, $path) = @_;

    if ($node->left) {
        my @p = @$path; # copy
        push @p, 0;
        traverse($node->left, \@p);
    }

    if ($node->right) {
        my @p = @$path; # copy
        push @p, 1;
        traverse($node->right, \@p);
    }

    if ($node->is_leaf) {
        say sprintf "%s => %s", chr $node->ascii, join('', @$path);
    }
}

my $text = shift or die "usage: %0 <text>";

my $root = build_huffman_tree $text;
traverse $root, [];
