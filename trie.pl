#!/usr/local/bin/perl
use strict;
use warnings;

package TRIE;
use base qw/Class::Accessor::Lvalue::Fast/;
use Data::Dumper;
use Perl6::Say;
use Params::Validate qw/validate_pos/;

__PACKAGE__->mk_accessors(qw/root/);

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->root = {};
    $self;
}

sub add_string {
    my ($self, $str) = validate_pos(@_, 1, 1);
    my @chars = split //, $str;

    my $node = $self->root;
    for my $c (@chars) {
        $node = $node->{$c} ||= {};
    }
    $node->{stop} = 1;
}

sub find {
    my ($self, $str) = validate_pos(@_, 1, 1);
    my @chars = split //, $str;

    my $node = $self->root;

    for (@chars) {
        exists $node->{$_} ? $node = $node->{$_} : return;
    }
    return scalar keys %$node;
}

sub dump {
    my $self = shift;
    Data::Dumper::Dumper( $self->root );
}

package main;
use Perl6::Say;

my $trie = TRIE->new;

$trie->add_string("abcdefg");
$trie->add_string("abcdezz");
$trie->add_string("naoya");
$trie->add_string("naoto");
$trie->add_string("naoko");
$trie->add_string("nao");

print $trie->dump;

say $trie->find("nao");   #=> 4
say $trie->find("naoya"); #=> 1
