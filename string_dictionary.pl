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

# 配列の添え字を返す
sub binary_search {
    my ($dict, $tp, $q) = @_;
    use integer;

    my $i = 0;
    my $j = @$tp - 2;

    while ($i <= $j) {
        my $k = ($i + $j) / 2;
        my $cmp = $q cmp get_term($dict, $tp, $k);
        if ($cmp == 0) {
            return $k;
        } elsif ($cmp == 1) {
            $i = $k + 1;
        } else {
            $j = $k - 1;
        }
    }
    return;
}

sub get_term {
    my ($dict, $tp, $k) = @_;
    return substr($$dict, $tp->[$k], $tp->[$k + 1] - $tp->[$k]);
}

my @terms = qw/linux windows thinkpad perl ruby python php kernel network pop shift push unshift/;
@terms = sort @terms;

my $dict = '';
my $i = 1; # i = 0 は番兵
my @term_ptr = (0);
my @first;
for my $term (@terms) {
    $term_ptr[$i]  = ($term_ptr[$i - 1] || 0) + length $term;
    $first[$i - 1] = substr($term, 0, 1); # debug
    add_to_dict(\$dict, $term);
    $i++;
}

## debug
my $j = 0;
while ($j < $#term_ptr) {
    say sprintf(
        "[%2d] => %2d: %s",
        $j,
        $term_ptr[$j],
        substr($dict, $term_ptr[$j], $term_ptr[$j + 1] - $term_ptr[$j]),
    );
    $j++;
}

use Test::More qw/no_plan/;

is get_term(\$dict, \@term_ptr, 0),  'kernel';
is get_term(\$dict, \@term_ptr, 5),  'pop';
is get_term(\$dict, \@term_ptr, 11), 'unshift';
is get_term(\$dict, \@term_ptr, 12), 'windows';

is binary_search(\$dict, \@term_ptr, 'thinkpad'), 10;
is binary_search(\$dict, \@term_ptr, 'kernel'),    0;
is binary_search(\$dict, \@term_ptr, 'linux'),     1;
is binary_search(\$dict, \@term_ptr, 'push'),      6;
is binary_search(\$dict, \@term_ptr, 'perl'),      3;
is binary_search(\$dict, \@term_ptr, 'unshift'),  11;
is binary_search(\$dict, \@term_ptr, 'windows'),  12;

is $first[ binary_search(\$dict, \@term_ptr, 'thinkpad') ], 't';
is $first[ binary_search(\$dict, \@term_ptr, 'unshift')  ], 'u';
