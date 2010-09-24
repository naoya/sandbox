#!/usr/bin/env perl
# libdivsufsort

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

# sub _build_sa {
#     my $self = shift;
#     push @{$self->buf}, 0;

#     my $last = @{$self->buf} - 1;

#     my $cmp = sub {
#         my ($i, $j) = ($a, $b);

#         while ($i < $last or $j < $last) {
#             my $diff = $self->buf->[$i] - $self->buf->[$j];
#             if ($diff == 0) {
#                 $i++;
#                 $j++;
#             } else {
#                 return $diff;
#             }
#         }

#         return 0;
#     };

#     @{$self->SA} = sort $cmp @{$self->SA};
#     pop @{$self->buf};
# }

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
use Test::More qw/no_plan/;

my $sa = SuffixArray->build("abracadabra");

is $sa->search('a'),          0;
is $sa->search('ab'),         1;
is $sa->search('abr'),        1;
is $sa->search('abra'),       1;
is $sa->search('abrac'),      2;
is $sa->search('aca'),        3;
is $sa->search('ada'),        4;
is $sa->search('bra'),        5;
is $sa->search('brac'),       6;
is $sa->search('cada'),       7;
is $sa->search('dabra'),      8;
is $sa->search("r"),          9;
is $sa->search("ra"),         9;
is $sa->search("rac"),       10;
is $sa->search("racadabra"), 10;

ok not $sa->search("hoge");
ok not $sa->search("braz");
ok not $sa->search("az");

is_deeply [ $sa->indices('a')    ], [ 0, 3, 5, 7, 10 ];
is_deeply [ $sa->indices('ab')   ], [ 0, 7 ];
is_deeply [ $sa->indices('abr')  ], [ 0, 7 ];
is_deeply [ $sa->indices('abra') ], [ 0, 7 ];
is_deeply [ $sa->indices('abrac')], [ 0 ];
is_deeply [ $sa->indices('bra')  ], [ 1, 8 ];
