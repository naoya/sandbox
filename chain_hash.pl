#!/usr/bin/env perl
use strict;
use warnings;

package Hash::Chain;
use Params::Validate qw/validate_pos/;

use List::Util qw/sum/;
use List::Rubyish;

sub new {
    my $class = shift;
    bless [], $class;
}

sub hash ($) {
    return sum( unpack('C*', $_[0]) ) % 100;
}

sub insert {
    my ($self, $key, $value) = validate_pos(@_, 1, 1, 1);

    my $bucket = Hash::Chain::Bucket->new;
    $bucket->key= $key;
    $bucket->value = $value;

    my $h = hash $key;

    $self->[ $h ] ||= List::Rubyish->new;
    $self->[$h]->unshift($bucket);
}

sub search {
    my ($self, $key) = validate_pos(@_, 1, 1);
    my $list = $self->[ hash $key ] or return;
    return $list->find(sub { $_->key eq $key });
}

package Hash::Chain::Bucket;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/key value/);

package main;
use utf8;
use Perl6::Say;

my $hash = Hash::Chain->new;

$hash->insert( apple   => 'りんご' );
$hash->insert( orange  => 'みかん' );
$hash->insert( kiwi    => 'キウィ' );
$hash->insert( bananas => 'バナナ' );

say $hash->search('apple')->value;
say $hash->search('bananas')->value;
say $hash->search('orange')->value;
say $hash->search('kiwi')->value;
