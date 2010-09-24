#!/usr/bin/env perl
use strict;
use warnings;

use Test::More qw/no_plan/;

# sub strcmp ($$) {
#     my ($s1, $s2) = @_;
#     no warnings 'uninitialized';

#     my ($i, $j) = (0, 0);
#     while ($s1->[$i] == $s2->[$j++]) {
#         if (not defined $s1->[$i++]) {
#             return 0;
#         }
#     }

#     return ($s1->[$i] - $s2->[--$j]) > 0 ? 1 : -1;
# }

## Yet another implementation
sub _strcmp {
    my ($s1, $s2) = @_;
    my ($i, $j) = (0, 0);
    while ($s1->[$i] == $s2->[$j++]) {
        if ($s1->[$i++] == 0) {
            return 0;
        }
    }
    return ($s1->[$i] - $s2->[--$j]) > 0 ? 1 : -1;
}

sub strcmp {
    my ($s1, $s2) = @_;
    push @$s1, 0;
    push @$s2, 0;

    my $cmp = _strcmp($s1, $s2);

    pop @$s1;
    pop @$s2;

    return $cmp;
}

# sub strncmp {
#     my ($s1, $s2, $n) = @_;
#     push @$s1, 0;
#     push @$s2, 0;

#     my $cmp = _strncmp($s1, $s2, $n);

#     pop @$s1;
#     pop @$s2;

#     return $cmp;
# }

# sub _strncmp {
#     my ($s1, $s2, $n) = @_;
#     my ($i, $j) = (0, 0);

#     if ($n == 0) {
#         return 0;
#     }

#     LOOP: {
#         do {
#             if ($s1->[$i] != $s2->[$j++]) {
#                 return ($s1->[$i] - $s2->[--$j]) > 0 ? 1 : -1;
#             }
#             if ($s1->[$i++] == 0) {
#                 last;
#             }
#         } while (--$n != 0);
#     }

#     return 0;
# }

sub strncmp {
    my ($s1, $s2, $n) = @_;
    no warnings 'uninitialized';
    my ($i, $j) = (0, 0);

    if ($n == 0) {
        return 0;
    }

    LOOP: {
        do {
            if ($s1->[$i] != $s2->[$j++]) {
                return ($s1->[$i] - $s2->[--$j]) > 0 ? 1 : -1;
            }
            if (not defined $s1->[$i++]) {
                last;
            }
        } while (--$n != 0);
    }

    return 0;
}

## strcmp
my $a = [ unpack('C*', "hello") ];
my $b = [ unpack('C*', "hello") ];

is strcmp($a, $b), 0;

my $c = [ unpack('C*', "aaa") ];

is strcmp($a, $c), 1;

my $d = [ unpack('C*', "zzz") ];

is strcmp($a, $d), -1;

my $e = [ unpack('C*', "hell") ];

is strcmp($a, $e), 1;

my $f = [ unpack('C*', "helloo") ];

is strcmp($a, $f), -1;

# strncmp()
## my $a = [ unpack('C*', "hello") ];
## my $b = [ unpack('C*', "hello") ];

is strncmp($a, $b, 1), 0;
is strncmp($a, $b, 2), 0;
is strncmp($a, $b, 3), 0;
is strncmp($a, $b, 4), 0;
is strncmp($a, $b, 5), 0;

## my $c = [ unpack('C*', "aaa") ];

is strncmp($a, $c, 1), 1;
is strncmp($a, $c, 2), 1;
is strncmp($a, $c, 3), 1;

## my $d = [ unpack('C*', "zzz") ];

is strncmp($a, $d, 1), -1;
is strncmp($a, $d, 2), -1;
is strncmp($a, $d, 3), -1;

## my $e = [ unpack('C*', "hell") ];

is strncmp($a, $e, 1), 0;
is strncmp($a, $e, 2), 0;
is strncmp($a, $e, 3), 0;
is strncmp($a, $e, 4), 0;
is strncmp($a, $e, 5), 1;

## my $f = [ unpack('C*', "helloo") ];

is strncmp($a, $f, 1), 0;
is strncmp($a, $f, 2), 0;
is strncmp($a, $f, 3), 0;
is strncmp($a, $f, 4), 0;
is strncmp($a, $f, 5), 0;
is strncmp($a, $f, 6), -1;
