#!/usr/bin/env perl
# Longest common subsequence
use strict;
use warnings;
use Perl6::Say;
use List::Util qw/max/;

sub show_lcs_table {
    my ($a, $b, $lcs) = @_;
    say sprintf "    %s", join ' ', map { chr } @$b;

    for (my $i = 0; $i < @$lcs; $i++) {
        printf
            "%s %s\n",
            $i > 0 ? chr $a->[$i - 1] : ' ',
            join ' ', @{$lcs->[$i]};
    }
}

sub print_lcs {
    my ($a, $b, $lcs, $i, $j) = @_;
    if ($i == 0 or $j == 0) {
        return;
    }

    if ($a->[$i - 1] == $b->[$j - 1]) {
        print_lcs($a, $b, $lcs, $i - 1, $j - 1);
        print chr $a->[$i - 1];
    } else {
        if ($lcs->[$i - 1]->[$j] >= $lcs->[$i]->[$j - 1]) {
            print_lcs($a, $b, $lcs, $i - 1, $j);
        } else {
            print_lcs($a, $b, $lcs, $i, $j - 1);
        }
    }
}

my $s1 = shift;
my $s2 = shift or die "usage: $0 <string1> <string2>";

my $a = [ unpack('C*', $s1) ];
my $b = [ unpack('C*', $s2) ];

my $lcs = [];
for my $i (0..@$a) {
    $lcs->[$i]->[0] = 0;
}

for my $j (0..@$b) {
    $lcs->[0]->[$j] = 0;
}

for my $i (1..@$a) {
    for my $j (1..@$b) {
        my $match = ($a->[$i - 1] == $b->[$j - 1]) ? 1 : 0;

        $lcs->[$i]->[$j] = max(
            $lcs->[$i - 1]->[$j - 1] + $match,
            $lcs->[$i]->[$j - 1],
            $lcs->[$i - 1]->[$j],
        );
    }
}

show_lcs_table($a, $b, $lcs);
say;

print_lcs($a, $b, $lcs, scalar @$a, scalar @$b);
say;
