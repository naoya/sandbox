#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Data::Dumper;
use Carp qw/croak/;
use Test::More qw/no_plan/;
use integer;

sub encode_vb {
    my $n = shift;
    my @bytes;
    while (1) {
        unshift @bytes, $n % 128;
        if ($n < 128) {
            last;
        }
        $n = $n / 128;
    }
    $bytes[-1] += 128;

    return pack('C*', @bytes);
}

sub decode_vb {
    my ($seq, $offset) = @_;
    $offset ||= 0;

    my $n      = 0;
    my $len    = length $seq;

    for (my $i = 0; $i < $len; $i++) {
        my $c = unpack('C', substr($$seq, $offset + $i, 1));
        if ($c < 128) {
            $n = 128 * $n + $c;
        } else {
            $n = 128 * $n + ($c - 128);
            return ($n, $i + 1);
        }
    }
    croak 'assert';
}

sub encode_fc {
    my ($cur, $prev) = @_;
    my @prev = unpack 'C*', $prev;
    my @cur  = unpack 'C*', $cur;
    my $nmatch = 0;
    while ( $nmatch < @prev and
            $nmatch < @cur  and
            $prev[ $nmatch ] == $cur[ $nmatch ] ) {
        $nmatch++;
    }
    substr($cur, 0, $nmatch) = '';
    return join '',encode_vb($nmatch), encode_vb(length $cur), $cur;
}

sub decode_fc {
    my ($seq, $prev, $offset) = @_;
    my ($nmatch, $nmatch_len) = decode_vb($seq, $offset);
    my ($nrest, $nrest_len)   = decode_vb($seq, $offset + $nmatch_len);
    my $term = join '',
        substr($prev, 0, $nmatch),
        substr($$seq, $offset + $nmatch_len + $nrest_len, $nrest);
    return wantarray ? ($term, $nmatch_len + $nrest_len + $nrest) : $term;
}

# sub get_term {
#     my ($dict, $tp, $k) = @_;
#     return decode_fc($dict, '', $tp->[$k]);
# }

# sub get_block {
#     use integer;
#     my ($dict, $tp, $k) = @_;
#     my @terms;
#     my $last = length $$dict;
#     my $cur  = $tp->[$k];
#     my $prev = '';
#     for (my $i = 0; $i < 4; $i++) {
#         my ($term, $fc_len) = decode_fc($dict, $prev, $cur);
#         push @terms, $term;
#         $cur += $fc_len;
#         if ($cur == $last) {
#             last;
#         }
#         $prev = $term;
#     }
#     return @terms;
# }

sub search_block {
    my ($dict, $dict_len, $tp, $k, $q, $cmp) = @_;
    my $cur  = $tp->[$k];
    my $prev = '';
    for (my $i = 0; $i < 4; $i++) {
        my ($term, $fc_len) = decode_fc($dict, $prev, $cur);
        $$cmp = $q cmp $term;
        if ($$cmp == 0) {
            return 4 * $k + $i;
        }
        $cur += $fc_len;
        if ($cur == $dict_len) {
            last;
        }
        $prev = $term;
    }
    return;
}

sub search {
    my ($dict, $tp, $q) = @_;

    my $dict_len = length $$dict;
    my $i = 0;
    my $j = @$tp - 1;

    while ($i <= $j) {
        my $cmp;
        my $k = ($i + $j) / 2;
        my $x = search_block($dict, $dict_len, $tp, $k, $q, \$cmp);
        if (defined $x) {
            return $x;
        }
        if ($cmp == 1) {
            $i = $k + 1;
        } else {
            $j = $k - 1;
        }
    }
    return;
}

my @terms = qw/jezebel jezer jezerit jeziah jeziel jezliah jezoar jezrahiah jezreel jezreelites jibsam jidlaph/;
@terms = sort @terms;

## build dictionary
my $dict = '';
my @term_ptr;
my $cur  = 0;
my $prev = '';

for (my $i = 0; $i < @terms; $i++) {
    if ($i % 4 == 0) {
        push @term_ptr, $cur;
        $prev = '';
    } else {
        $prev = $terms[$i - 1];
    }

    my $code = encode_fc($terms[$i], $prev);
    $dict .= $code;
    $cur += length $code;
}

## debug
for (my $i = 0; $i < @term_ptr; $i++) {
    say sprintf(
        "[%2d] => %2d: %s",
        $i,
        $term_ptr[$i],
        decode_fc(\$dict, '', $term_ptr[$i]),
    );
}

is_deeply [ decode_vb( \encode_vb(0) ) ], [0, 1];
is_deeply [ decode_vb( \encode_vb(1) ) ], [1, 1];
is_deeply [ decode_vb( \encode_vb(5) ) ], [5, 1];
is_deeply [ decode_vb( \encode_vb(127) ) ], [127, 1];
is_deeply [ decode_vb( \encode_vb(128) ) ], [128, 2];
is_deeply [ decode_vb( \encode_vb(255) ) ], [255, 2];
is_deeply [ decode_vb( \encode_vb(256) ) ], [256, 2];
is_deeply [ decode_vb( \encode_vb(300) ) ], [300, 2];
is_deeply [ decode_vb( \encode_vb(123456) ) ], [123456, 3];

# is get_term(\$dict, \@term_ptr, 0), 'jezebel';
# is get_term(\$dict, \@term_ptr, 1), 'jeziel';
# is get_term(\$dict, \@term_ptr, 2), 'jezreel';

# is_deeply [ get_block(\$dict, \@term_ptr, 0) ], [qw/jezebel jezer jezerit jeziah/];
# is_deeply [ get_block(\$dict, \@term_ptr, 1) ], [qw/jeziel jezliah jezoar jezrahiah/];
# is_deeply [ get_block(\$dict, \@term_ptr, 2) ], [qw/jezreel jezreelites jibsam jidlaph/];

is search(\$dict, \@term_ptr, 'jezebel'),   0;
is search(\$dict, \@term_ptr, 'jezer'),     1;
is search(\$dict, \@term_ptr, 'jezerit'),   2;
is search(\$dict, \@term_ptr, 'jeziah'),    3;

is search(\$dict, \@term_ptr, 'jeziel'),    4;
is search(\$dict, \@term_ptr, 'jezliah'),   5;
is search(\$dict, \@term_ptr, 'jezoar'),    6;
is search(\$dict, \@term_ptr, 'jezrahiah'), 7;

is search(\$dict, \@term_ptr, 'jezreel'),      8;
is search(\$dict, \@term_ptr, 'jezreelites'),  9;
is search(\$dict, \@term_ptr, 'jibsam'),      10;
is search(\$dict, \@term_ptr, 'jidlaph'),     11;

is search(\$dict, \@term_ptr, 'hoge'), undef;
