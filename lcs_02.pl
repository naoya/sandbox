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
    my ($a, $trace, $i, $j) = @_;
    if ($i == 0 or $j == 0) {
        return;
    }

    if ($trace->[$i]->[$j] eq '*') {
        print_lcs($a, $trace, $i - 1, $j - 1);
        print chr $a->[$i - 1];
    } elsif ($trace->[$i]->[$j] eq '^') {
        print_lcs($a, $trace, $i - 1, $j);
    } else {
        print_lcs($a, $trace, $i, $j - 1);
    }
}

my $s1 = shift;
my $s2 = shift or die "usage: $0 <string1> <string2>";

my $a = [ unpack('C*', $s1) ];
my $b = [ unpack('C*', $s2) ];

my $count = [];
my $trace = [];
for my $i (0..@$a) {
    $count->[$i]->[0] = 0;
    $trace->[$i]->[0] = '-';
}

for my $j (0..@$b) {
    $count->[0]->[$j] = 0;
    $trace->[0]->[$j] = '-';
}

for my $i (1..@$a) {
    for my $j (1..@$b) {
        if ($a->[$i - 1] == $b->[$j - 1]) {
            $count->[$i]->[$j] = $count->[$i - 1]->[$j - 1] + 1;
            $trace->[$i]->[$j] = '*';
        } else {
            if ($count->[$i - 1]->[$j] >= $count->[$i]->[$j - 1]) {
                $count->[$i]->[$j] = $count->[$i - 1]->[$j];
                $trace->[$i]->[$j] = '^';
            } else {
                $count->[$i]->[$j] = $count->[$i]->[$j - 1];
                $trace->[$i]->[$j] = '<';
            }
        }
    }
}

show_lcs_table($a, $b, $count);
say;
show_lcs_table($a, $b, $trace);
say;

print_lcs($a, $trace, scalar @$a, scalar @$b);
say;
