#!/usr/bin/env perl
# いきなり利用方法を教える
use strict;
use warnings;

package SuffixArray;
use base qw/Class::Accessor::Lvalue::Fast/;

use Algorithm::DivSufSort qw/divsufsort/;

__PACKAGE__->mk_accessors(qw/buf SA/);

sub build {
    my ($class, $text) = @_;

    my $self = $class->SUPER::new;

    $self->buf = [ unpack('C*', $text) ];
    $self->SA  = divsufsort($text);

    return $self;
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
use Perl6::Say;
use Path::Class qw/file/;

my $query = shift or die "usage: $0 <query>\n";

my $text = file('/etc', 'passwd')->slurp;
my $sa = SuffixArray->build($text);

my @indices = $sa->indices( $query );

for my $i (@indices) {
    say sprintf "%d: %s", $i, substr($text, $i, index($text, "\n", $i) - $i );
}

say sprintf "total term frequency: %d", scalar @indices;
