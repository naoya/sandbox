#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

package BinaryTree;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/root/);

sub insert {
    my ($self, $key) = @_;

    my $z = BinaryTree::Node->new;
    $z->key = $key;

    ## 挿入位置の節を探す
    my $y;
    my $x = $self->root;

    while (defined $x) {
        $y = $x;
        $x = $z->key < $x->key ? $x->left : $x->right;
    }

    ## 親にリンクする
    $z->parent = $y;

    ## 左か、右か
    if (not defined $y) {
        $self->root = $z;
    } else {
        # $z->key < $y->key ? $y->left = $z : $y->right = $z;
        if ($z->key < $y->key) {
            $y->left = $z;
        } else {
            $y->right = $z;
        }
    }

    return $z;
}

sub inorder_walk {
    my ($self, $code) = @_;
    if ($self->root) {
        $self->root->inorder_walk($code);
    }
}

sub search {
    my ($self, $k) = @_;
    if ($self->root) {
        return $self->root->search($k);
    }
}

sub minimum {
    my $self = shift;
    if ($self->root) {
        return $self->root->minimum;
    }
}

sub maximum {
    my $self = shift;
    if ($self->root) {
        return $self->root->maximum;
    }
}

sub dump {
    my $self = shift;

    require Data::Dumper;
    return Data::Dumper::Dumper( $self );
}

package BinaryTree::Node;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/parent left right key/);

sub inorder_walk {
    my ($self, $code) = @_;
    if ($self->left) {
        $self->left->inorder_walk($code);
    }

    $code->($self);

    if ($self->right) {
        $self->right->inorder_walk($code);
    }
}

sub search {
    my ($self, $key) = @_;
    my $x = $self;

    while (defined $x and $key != $x->key) {
        $x = $key < $x->key ? $x->left : $x->right;
    }

    return $x;
}

sub minimum {
    my $self = shift;

    my $x = $self;
    while (defined $x->left) {
        $x = $x->left;
    }

    return $x;
}

sub maximum {
    my $self = shift;

    my $x = $self;
    while (defined $x->right) {
        $x = $x->right;
    }

    return $x;
}

sub successor {
    my $self = shift;

    ## 自分よりもでかい(right)中で最小値
    my $x = $self;
    if (defined $x->right) {
        return $x->right->minimum;
    }

    ## 自分の先祖で自分のツリーを左に持つ
    ## あってる?
    my $y = $x->parent;
    while (defined $y and $x == $y->right) {
        $x = $y;
        $y = $y->parent;
    }

    return $y;
}

# あとで実装
sub delete {
}

package main;

my $tree = BinaryTree->new;
$tree->insert(5);
$tree->insert(2);
$tree->insert(8);
$tree->insert(10);
$tree->insert(3);

warn $tree->dump;

# warn $tree->dump;

$tree->inorder_walk(sub { say $_[0]->key });

warn $tree->search(2)->key;
warn $tree->search(5)->key;
warn $tree->search(8)->key;

say $tree->minimum->key;
say $tree->maximum->key;

warn $tree->minimum->successor->key;
warn $tree->search(8)->successor->key;

