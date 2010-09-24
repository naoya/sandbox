#!/usr/bin/env perl
# べんちまーく
use strict;
use warnings;

package SuffixArray;
use base qw/Class::Accessor::Lvalue::Fast/;

use Algorithm::DivSufSort qw/divsufsort/;

__PACKAGE__->mk_accessors(qw/buf SA/);

sub build_by_builtin {
    my ($class, $text) = @_;

    my $self = $class->SUPER::new;

    $self->buf = [ unpack('C*', $text) ];

    my $i = 0;
    $self->SA  = [ map { $i++ } @{$self->buf} ];
    $self->_build_sa;

    return $self;
}

sub build_by_divsufsort {
    my ($class, $text) = @_;

    my $self = $class->SUPER::new;

    $self->buf = [ unpack('C*', $text) ];
    $self->SA  = divsufsort($text);

    return $self;
}

sub _build_sa {
    my $self = shift;
    push @{$self->buf}, 0;

    my $last = @{$self->buf} - 1;

    my $cmp = sub {
        my ($i, $j) = ($a, $b);

        while ($i < $last or $j < $last) {
            my $diff = $self->buf->[$i] - $self->buf->[$j];
            if ($diff == 0) {
                $i++;
                $j++;
            } else {
                return $diff;
            }
        }

        return 0;
    };

    @{$self->SA} = sort $cmp @{$self->SA};
    pop @{$self->buf};
}

sub search {
    my ($self, $q) = @_;
    my $buf_q = [ unpack('C*', $q) ];
    my $len_q = length $q;

    use integer;
    my $l = -1;
    my $u = @{$self->buf};

    while ($l + 1 != $u) {
        my $m = ($l + $u) / 2;
        if (strncmp($buf_q, 0, $self->buf, $self->SA->[$m], $len_q) > 0) {
            $l = $m;
        } else {
            $u = $m;
        }
    }

    if ($u >= @{$self->buf} || strncmp($buf_q, 0, $self->buf, $self->SA->[$u], $len_q) != 0) {
        return;
    }

    return $u;
}

sub indices {
    my ($self, $q) = @_;
    my $pos = $self->search($q);

    if (not defined $pos) {
        return;
    }

    my $buf_q = [ unpack('C*', $q) ];
    my $len   = @{$self->SA};
    my $len_q = length $q;
    my @res;

    while ( $pos < $len and strncmp($buf_q, 0, $self->buf, $self->SA->[$pos], $len_q) == 0 ) {
        push @res, $self->SA->[$pos];
        $pos++;
    }

    return sort { $a <=> $b } @res;
}

sub strncmp {
    my ($s1, $n1, $s2, $n2, $n) = @_;
    no warnings 'uninitialized';

    if ($n == 0) {
        return 0;
    }

    LOOP: {
        do {
            if ($s1->[$n1] != $s2->[$n2++]) {
                return ($s1->[$n1] - $s2->[--$n2]) > 0 ? 1 : -1;
            }
            if (not defined $s1->[$n1++]) {
                last;
            }
        } while (--$n != 0);
    }

    return 0;
}

package main;
use Path::Class qw/file/;
use Benchmark qw/:all/;

my $text = file('/etc/passwd')->slurp;

cmpthese( 100, {
    builtin    => sub { SuffixArray->build_by_builtin($text) },
    divsufsort => sub { SuffixArray->build_by_divsufsort($text) },
});

# Benchmark: timing 1000 iterations of builtin, divsufsort...
#  builtin: 59 wallclock secs (58.49 usr +  0.63 sys = 59.12 CPU) @ 16.91/s (n=1000)
#  divsufsort:  7 wallclock secs ( 1.89 usr +  4.45 sys =  6.34 CPU) @ 157.73/s (n=1000)

#              Rate    builtin divsufsort
# builtin    17.2/s         --       -89%
# divsufsort  156/s       811%         --
