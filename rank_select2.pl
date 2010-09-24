#!/usr/bin/env perl
use strict;
use warnings;

package Vector::SucBV;
use base qw/Class::Accessor::Lvalue::Fast/;
use integer;

use Params::Validate qw/validate_pos/;

__PACKAGE__->mk_accessors(qw/bv size block_size sb tb sb_size tb_size/);

use constant BSIZE    => (1 << 5); ## 32bit environment
use constant LEVEL_SB => (1 << 8);
use constant LEVEL_TB => (1 << 5);

sub popcount ($) {
    use integer;
    my $r = shift;

    $r = (($r & 0xAAAAAAAA) >> 1) + ($r & 0x55555555);
    $r = (($r & 0xCCCCCCCC) >> 2) + ($r & 0x33333333);
    $r = (($r >> 4) + $r) & 0x0F0F0F0F;
    $r = ($r >> 8) + $r;

    return (($r >> 16) + $r) & 0x3F;
}

sub new {
    my ($class, $vec) = validate_pos(@_, 1, 1);
    my $self = $class->SUPER::new;

    $self->bv   = $vec;
    $self->size = $vec->bit_length;

    $self->block_size = ($self->size + BSIZE - 1) / BSIZE;
    $self->sb_size = $self->size / LEVEL_SB + 1;
    $self->tb_size = $self->size / LEVEL_TB + 1;
    $self->sb      = [];
    $self->tb      = [];

    $self->build_table;

    bless $self, $class;
}

sub build_table {
    my $self = shift;

    my $r = 0;
    for (my $i = 0; $i <= $self->size; $i++) {
        if ($i % LEVEL_SB == 0) {
            $self->sb->[ $i / LEVEL_SB ] = $r;
        }

        if ($i % LEVEL_TB == 0) {
            $self->tb->[ $i / LEVEL_TB ] = $r - $self->sb->[ $i / LEVEL_SB ];
        }

        if ($i != $self->size and $i % BSIZE == 0) {
            $r += popcount( $self->bv->get_block( $i / BSIZE )->packed_int );
        }
    }
}

sub _rank1 {
    my ($self, $pos) = validate_pos(@_, 1, 1);

    my $remain  = $pos    % LEVEL_TB;
    my $remainp = $remain % BSIZE;

    my $r = $self->sb->[ $pos / LEVEL_SB ] + $self->tb->[ $pos / LEVEL_TB ];
    $r += popcount( $self->bv->get_block( $pos / BSIZE )->packed_int & ((1 << $remainp) - 1) );

    return $r;
}

sub rank {
    my ($self, $pos, $bit) = validate_pos(@_, 1, 1, { default => 1 });
    $pos++;

    $bit ? $self->_rank1($pos) : $pos - _rank1($pos);
}

package Bit::Vector;
use Carp qw/croak/;

use constant BSIZE       => (1 << 5);

use Params::Validate qw/validate_pos/;

sub new {
    my ($class, $vec) = validate_pos(@_, 1, { default => pack("V", 0) });
    bless \$vec, $class;
}

sub set {
    my ($self, $pos, $val) = validate_pos(@_, 1, 1, { default => 1 });
    vec($$self, $pos, 1) = $val;
}

sub get {
    my ($self, $pos) = @_;
    return vec($$self, $pos, 1);
}

sub get_block {
    my ($self, $pos) = @_;

    ## ulong で取り出すとエンディアンが反転してしまう
    ## perl の vec は BITS が 16 以上の場合入力を BITS/8 にグループ化して
    ## big endian format (pack の n/N) で数値に変換する∴ L ではなく N を使う
    return Bit::Vector->new( pack("N", vec($$self, $pos, BSIZE)) );
}

sub bit_length {
    length(${$_[0]}) * 8;
}

sub as_bitstring {
    unpack("b*", ${$_[0]});
}

sub packed_int {
    unpack("V", ${$_[0]});
}

sub as_binary {
    ${$_[0]};
}

sub length {
    CORE::length ${$_[0]};
}

package main;
use Perl6::Say;

my $vec = Bit::Vector->new;
$vec->set(1);
$vec->set(2);
$vec->set(3);
$vec->set(30 => 0);

say "length vec: ", $vec->length;
say sprintf "binary:  %s", $vec->as_bitstring;
say sprintf "integer: %d", $vec->packed_int;
say sprintf "block:   %s", $vec->get_block(0)->as_bitstring;
say sprintf "block:   %s", $vec->get_block(0)->packed_int;

my $bv = Vector::SucBV->new($vec);

say "rank(0):  ", $bv->rank(0, 1);  # 0
say "rank(1):  ", $bv->rank(1, 1);  # 1
say "rank(2):  ", $bv->rank(2, 1);  # 2
say "rank(8):  ", $bv->rank(8, 1);  # 3
say "rank(31): ", $bv->rank(31, 1); # 3

say;

my $lvec = Bit::Vector->new;
$lvec->set(1);
$lvec->set(23);
$lvec->set(35);
$lvec->set(128);

## 32 x 2 になるよう
say "length vec: ", $lvec->length;
say "binary: ", $lvec->as_bitstring;
say sprintf "integer: %d", $lvec->packed_int;

$bv = Vector::SucBV->new($lvec);

say "size: ",      $bv->size;
say "rank(1): ",   $bv->rank(1, 1);   # 1
say "rank(8): ",   $bv->rank(8, 1);   # 1
say "rank(32): ",  $bv->rank(32, 1);  # 2
say "rank(35): ",  $bv->rank(35, 1);  # 3
say "rank(150): ", $bv->rank(150, 1); # 4
