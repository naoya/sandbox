#!/usr/bin/env perl
use strict;
use warnings;

my $text  = shift;
my $q = shift or die "usage: $0 <text> <query>";

my $len = length $text;
my $SA  = [];

for (my $i = 0; $i < $len; $i++) {
    $SA->[$i] = $i;
}

build_sa($text, $SA);

# show_sa($text, $SA);

my $pos = sa_search($q, $text, $SA);

if (not defined $pos) {
    exit -1;
}

while ( $q eq substr($text, $SA->[$pos], length $q) ){
    printf "%2d => %s\n", $SA->[$pos], substr($text, $SA->[$pos]);
    $pos++;
    defined $SA->[$pos] or last;
}

sub build_sa {
    my ($text, $SA) = @_;
    @$SA = sort { substr($text, $a) cmp substr($text, $b) } @$SA;
}

sub sa_search {
    my ($q, $text, $SA) = @_;
    use integer;

    my $l = -1;
    my $u = length $text;

    while ($l + 1 != $u) {
        my $m = ($l + $u) / 2;
        if ( ($q cmp substr($text, $SA->[$m], length $q)) > 0 ) {
            $l = $m;
        } else {
            $u = $m;
        }
    }

    if ($u >= length $text || $q ne substr($text, $SA->[$u], length $q) ) {
        return;
    }

    return $u;
}

sub show_sa {
    my ($text, $SA) = @_;

    my $len = @$SA;
    for (my $i = 0; $i < $len; $i++) {
        printf(
            "sa[%2d] = %2d, substr(\$text, %2d) = %s\n",
            $i,
            $SA->[$i],
            $SA->[$i],
            substr($text, $SA->[$i]),
        );
    }
    print "\n";
}
