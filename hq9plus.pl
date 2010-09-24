#!/usr/bin/env perl
use strict;
use warnings;

package String;
use Params::Validate qw/validate_pos CODEREF/;

sub new {
    my ($class, $str) = @_;
    bless \$str, $class;
}

sub each_char {
    my ($self, $code) = validate_pos(@_, 1, { type => CODEREF });
    my @chars = unpack('C*', $$self);
    for (map { chr } @chars) {
        $code->($_);
    }
}

package HQ9Plus;
use base qw/Class::Accessor::Lvalue::Fast/;
use Params::Validate qw/validate_pos/;
use Perl6::Say;

__PACKAGE__->mk_accessors(qw/count src/);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->count = 0;

    return $self;
}

sub run {
    my ($self, $src) = validate_pos(@_, 1, 1);
    $self->src = $src;

    String->new($src)->each_char(sub {
        $self->execute_op($_);
    });
}

sub execute_op {
    my ($self, $op) = @_;

    if    ($op eq 'H') { $self->print_hello  }
    elsif ($op eq 'Q') { $self->print_source }
    elsif ($op eq '9') { $self->print_99_bottles_of_beer }
    elsif ($op eq '+') { $self->count++ }

    # else  { die sprintf 'assert (%s)', ord $op }
}

sub print_hello  {
    my $self = shift;
    print "Hello, world!\n"
}

sub print_source {
    my $self = shift;
    print $self->src;
}

sub print_99_bottles_of_beer {
    my $self = shift;
    for (my $i = 99; $i >= 0; $i--) {
        my ($before, $after, $action);
        if ($i == 0) {
            $before = "no more bottles";
            $after  = "99 bottles";
        }

        elsif ($i == 1) {
            $before = "1 bottle";
            $after  = "no more bottles";
        }

        elsif ($i == 2) {
            $before = "2 bottles";
            $after  = "1 bottle ";
        }

        else {
            $before = "$i bottles";
            $after  = sprintf "%d bottles", $i - 1;
        }

        if ($i == 0) {
            $action = "Go to the store and buy some more";
        } else {
            $action = "Take one donwn and pass it around";
        }

        say sprintf "%s of beer on the wall, %s of beer.", ucfirst $before, $before;
        say sprintf "%s, %s of beer on the wall.", $action, $after;
        say "" if $i;
    }
}

package HQ9Plus::Instrunction;
use base qw/Class::Accessor::Lvalue::Fast/;

package main;
use Perl6::Say;

local $/ = undef;

while (my $src = <>) {
    my $hq9plus = HQ9Plus->new;
    $hq9plus->run($src);
}
