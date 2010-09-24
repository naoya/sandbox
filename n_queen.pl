#!/usr/bin/env perl
use strict;
use warnings;

package Algorithm::NQueen;
use base qw/Class::Accessor::Lvalue::Fast/;

__PACKAGE__->mk_accessors(qw/pos col down up N/);

use Params::Validate qw/validate_pos/;

use constant FREE     => 1;
use constant NOT_FREE => 0;

sub new {
    my ($class, $N) = validate_pos(@_, 1, 1);
    my $self = $class->SUPER::new;

    $self->N = $N;

    $self->pos  = []; # 座標 (索引が行、値が列)
    $self->col  = []; # 列のチェッカ
    $self->down = []; # 斜め右下のチェッカ
    $self->up   = []; # 斜め右上のチェッカ

    for (my $i = 0; $i < $N; $i++) {
        $self->pos->[$i] = -1;
        $self->col->[$i] = FREE;
    }

    for (my $i = 0; $i < 2 * $N - 1; $i++) {
        $self->down->[$i] = FREE;
        $self->up->[$i]   = FREE;
    }

    return $self;
}

sub print_board {
    my $self = shift;
    my $out  = '';
    for (my $i = 0; $i < $self->N; $i++) {
        for (my $j = 0; $j < $self->N; $j++) {
            if ($self->pos->[$i] == $j) {
                $out .= "Q ";
            } else {
                $out .= ". ";
            }
        }
        $out .= "\n";
    }
    return $out;
}

sub try {
    my ($self, $row) = validate_pos(@_, 1, 1);

    for (my $col = 0; $col < $self->N; $col++) {

        ## 置く
        if ($self->can_put($row, $col)) {
            $self->put_queen($row, $col);

            ## 再帰終了条件: N個のクイーンを置けたら成功 => 最後の行が置けたらOK
            if ($row + 1 == $self->N) {
                return 1;
            }

            ## 次の行へ
            if ($self->try($row + 1)) {
                return 1;
            } else {
                ## バックトラック
                # warn "back track ($row, $col)\n";
                $self->remove_queen($row, $col);
            }
        }
    }

    # この行 ($row) には置けなかった
    return;
}

sub can_put {
    my ($self, $row, $col) = validate_pos(@_, 1, 1, 1);

    return $self->col->[$col]                          == FREE
        && $self->down->[$row - $col + ($self->N - 1)] == FREE
        && $self->up->[$row + $col]                    == FREE;
}

sub put_queen {
    my ($self, $row, $col) = validate_pos(@_, 1, 1, 1);

    $self->pos->[$row]                          = $col;
    $self->col->[$col]                          = NOT_FREE;
    $self->up->[$row + $col]                    = NOT_FREE;
    $self->down->[$row - $col + ($self->N - 1)] = NOT_FREE;
}

sub remove_queen {
    my ($self, $row, $col) = validate_pos(@_, 1, 1, 1);

    $self->pos->[$row]                          = -1;
    $self->col->[$col]                          = FREE;
    $self->up->[$row + $col]                    = FREE;
    $self->down->[$row - $col + ($self->N - 1)] = FREE;
}

package main;
use Perl6::Say;

my $n = shift or die "usage: $0 <num>";
my $board = Algorithm::NQueen->new($n);

if ($board->try(0)) {
    print $board->print_board;
}

