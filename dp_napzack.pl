#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

package Item;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/id size value/);

package DP;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/size total_values last_choice/);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->init(@_);

    return $self;
}

sub init {
    my $self = shift;

    $self->total_values = [];
    $self->last_choice  = [];

    for (my $i = 0; $i < $self->size; $i++) {
        $self->total_values->[$i] = 0;
        $self->last_choice->[$i]  = -1;
    }
}

package main;

my @items = (
    Item->new({ id => 0, size => 2, value => 2  }),
    Item->new({ id => 1, size => 3, value => 4  }),
    Item->new({ id => 2, size => 5, value => 7  }),
    Item->new({ id => 3, size => 7, value => 11 }),
    Item->new({ id => 4, size => 9, value => 14 }),
);

my $dp = DP->new({ size => 16 });

## 小さい方から順に計算していって、DP 用に用意したメモリの中を
## 最大値に書き換えながら最後までループする
for (@items) {
    for (my $m = $_->size; $m <= $dp->size; $m++) {
        my $repack_total = $dp->total_values->[ $m - $_->size ] + $_->value;
        if ($repack_total > $dp->total_values->[$m]) {
            $dp->total_values->[$m] = $repack_total;
            $dp->last_choice->[$m] = $_->id;
        }
    }
}

require Data::Dumper;
warn Data::Dumper::Dumper( $dp );

for (my $i = $dp->size; $dp->last_choice->[$i] >= 0; $i -= $items[ $dp->last_choice->[$i] ]->size) {
    my $item = $items[ $dp->last_choice->[$i] ];
    say sprintf "id: %d, value: %d", $item->id, $item->size;
}
