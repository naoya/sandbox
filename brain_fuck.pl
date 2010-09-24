#!/usr/bin/env perl
# perl brain_fuck.pl '++++++ [> ++++++++++ < -] > +++++. => A
use strict;
use warnings;

package BrainFuck;
use base qw/Class::Accessor::Lvalue::Fast/;

use Params::Validate qw/validate_pos/;
use IO::Handle;

__PACKAGE__->mk_accessors(qw/tokens jumps/);

sub new {
    my ($class, $src) = validate_pos(@_, 1, 1);

    my $self = $class->SUPER::new;

    $self->tokens = [ unpack 'C*', $src ];
    $self->jumps  = {};
    $self->_analyze_jumps( $self->tokens );

    return $self;
}

sub _analyze_jumps {
    my ($self, $tokens) = validate_pos(@_, 1, 1);
    my @stack;

    for (my $i = 0; $i < @$tokens; $i++) {
        if ($tokens->[$i] == ord '[') {
            push @stack, $i;
        }

        if ($tokens->[$i] == ord ']') {
            if (@stack == 0) {
                die 'assert';
            }

            my $from = pop @stack;
            $self->jumps->{$from} = $i;
            $self->jumps->{$i}    = $from;
        }
    }

    if (@stack != 0) {
        die 'assert';
    }
}

sub run {
    my $self = shift;

    my $tape = [];
    my $pc   = 0;
    my $cur  = 0;

    while (@{$self->tokens} > $pc) {
        my $op = $self->tokens->[$pc];

        if ($op == ord '+') {
            $tape->[$cur] ||= 0;
            $tape->[$cur]++;
        }

        elsif ($op == ord '-') {
            $tape->[$cur] ||= 0;
            $tape->[$cur]--;
        }

        elsif ($op == ord '>') {
            $cur++;
        }

        elsif ($op == ord '<') {
            $cur--;
        }

        elsif ($op == ord '.') {
            STDOUT->print(chr $tape->[$cur]);
        }

        elsif ($op == ord ',') {
            $tape->[$cur] = STDIN->getc;
        }

        elsif ($op == ord '[') {
            if ($tape->[$cur] == 0) {
                $pc = $self->jumps->{$pc};
            }
        }

        elsif ($op == ord ']') {
            if ($tape->[$cur] != 0) {
                $pc = $self->jumps->{$pc};
            }
        }

        $pc++;
    }
}

package main;

my $src = shift or die "usage: $0 <text>";

my $bf = BrainFuck->new($src);
$bf->run;
