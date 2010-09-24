#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Data::Dumper;

sub add_to_dict {
    my ($dict, $term) = @_;
    $$dict .= $term;
}

sub encode_vb {
    use integer;

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
    use integer;

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
    die 'assert';
}

# sub _decode_vb {
#     use integer;

#     my $vb = shift;

#     my $n   = 0;
#     my $len = length $vb;

#     for (my $i = 0; $i < $len; $i++) {
#         my $c = unpack('C', substr($vb, $i, 1));
#         if ($c < 128) {
#             $n = 128 * $n + $c;
#         } else {
#             $n = 128 * $n + ($c - 128);
#             return $n;
#         }
#     }

#     return $n;
# }

# sub decode_vbx {
#     my $ref = shift;
#     my $n = decode_vb $$ref;
#     substr($$ref, 0, length encode_vb($n)) = '';
#     return $n;
# }

use Test::More qw/no_plan/;

# is _decode_vb( encode_vb(0) ),           0;
# is _decode_vb( encode_vb(1) ),           1;
# is _decode_vb( encode_vb(5) ),           5;
# is _decode_vb( encode_vb(127) ),       127;
# is _decode_vb( encode_vb(128) ),       128;
# is _decode_vb( encode_vb(256) ),       256;
# is _decode_vb( encode_vb(300) ),       300;
# is _decode_vb( encode_vb(512) ),       512;
# is _decode_vb( encode_vb(123456) ), 123456;

is_deeply [ decode_vb( \encode_vb(0) ) ], [0, 1];
is_deeply [ decode_vb( \encode_vb(1) ) ], [1, 1];
is_deeply [ decode_vb( \encode_vb(5) ) ], [5, 1];
is_deeply [ decode_vb( \encode_vb(127) ) ], [127, 1];
is_deeply [ decode_vb( \encode_vb(128) ) ], [128, 2];
is_deeply [ decode_vb( \encode_vb(255) ) ], [255, 2];
is_deeply [ decode_vb( \encode_vb(256) ) ], [256, 2];
is_deeply [ decode_vb( \encode_vb(300) ) ], [300, 2];
is_deeply [ decode_vb( \encode_vb(123456) ) ], [123456, 3];


my @terms = qw/linux windows thinkpad perl ruby python php kernel network pop shift push unshift/;
@terms = sort @terms;

warn join ' ', @terms;

## build dictionary
my $dict = '';
my @term_ptr;
my $cur = 0;
for (my $i = 0; $i < @terms; $i++) {
    my $len = length $terms[$i];
    my $vb  = encode_vb($len);
    $dict .= $vb . $terms[$i];
    if (($i % 4) == 0) {
        push @term_ptr, $cur;
    }
    $cur += length($vb) + $len;
}

## debug
for (my $i = 0; $i < @term_ptr; $i++) {
    my ($len, $vb_len) = decode_vb(\$dict, $term_ptr[$i]);
    say sprintf(
        "[%2d] => %2d: %s",
        $i,
        $term_ptr[$i],
        substr($dict, $term_ptr[$i] + $vb_len, $len),
    );
}

sub get_term {
    my ($dict, $tp, $k) = @_;
    my ($len, $vb_len) = decode_vb($dict, $tp->[$k]);
    return substr($$dict, $tp->[$k] + $vb_len, $len);
    return;
}

sub get_block {
    use integer;
    my ($dict, $tp, $k) = @_;
    my @terms;
    my $last = length $$dict;
    my $cur = $tp->[$k];
    for (my $i = 0; $i < 4; $i++) {
        my ($len, $vb_len) = decode_vb($dict, $cur);
        push @terms, substr($$dict, $cur + $vb_len, $len);
        $cur += $len + $vb_len;
        if ($cur == $last) {
            last;
        }
    }
    return @terms;
}

sub search_block {
    use integer;
    my ($dict, $tp, $k, $q, $cmp) = @_;
    my $last = length $$dict; # これ毎回取るの非効率だよね
    my $cur = $tp->[$k];
    for (my $i = 0; $i < 4; $i++) {
        my ($len, $vb_len) = decode_vb($dict, $cur);
        $$cmp = $q cmp substr($$dict, $cur + $vb_len, $len);
        if ($$cmp == 0) {
            return 4 * $k + $i;
        }
        $cur += $len + $vb_len;
        if ($cur == $last) {
            last;
        }
    }
    return;
}

sub search {
    my ($dict, $tp, $q) = @_;
    use integer;

    my $i = 0;
    my $j = @$tp - 1;
    while ($i <= $j) {
        my $cmp;
        my $k = ($i + $j) / 2;
        my $x = search_block($dict, $tp, $k, $q, \$cmp);
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

is get_term(\$dict, \@term_ptr, 0), 'kernel';
is get_term(\$dict, \@term_ptr, 1), 'php';
is get_term(\$dict, \@term_ptr, 2), 'ruby';
is get_term(\$dict, \@term_ptr, 3), 'windows';

is_deeply [ get_block(\$dict, \@term_ptr, 0) ], [qw/kernel linux network perl/];
is_deeply [ get_block(\$dict, \@term_ptr, 1) ], [qw/php pop push python/];
is_deeply [ get_block(\$dict, \@term_ptr, 2) ], [qw/ruby shift thinkpad unshift/];

is search(\$dict, \@term_ptr, 'kernel'),    0;
is search(\$dict, \@term_ptr, 'linux'),     1;
is search(\$dict, \@term_ptr, 'push'),      6;
is search(\$dict, \@term_ptr, 'perl'),      3;
is search(\$dict, \@term_ptr, 'unshift'),  11;
is search(\$dict, \@term_ptr, 'windows'),  12;
is search(\$dict, \@term_ptr, 'ubuntsu'),  undef;
