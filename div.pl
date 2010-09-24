#!/usr/local/bin/perl
use strict;
use warnings;

use Perl6::Say;
use Benchmark qw/:all/;
use POSIX qw/floor/;

sub perldiv($$) {
    floor($_[0] / $_[1]);
}

sub intdiv ($$) {
    use integer;
    my ($x, $y) = @_;

    my $mod = 0;

    for (my $i = 0; $i < 32; $i++) {
        $mod <<= 1;

        if ($x & (1 << (32 - 1))) {
            $mod |= 0x01;
        }
        $x <<= 1;

        if ($mod >= $y) {
            $mod -= $y;
            $x |= 0x01;
        }
    }

    return $x;
}

## ½Å¤¤¥Ã!
sub intdiv2 {
    my ($x, $y) = @_;
    my $ans;
    my $mod;

    for ($ans = 0 ; $x >= $y; $x -= $y) {
        $ans++;
    }
    $mod = $x;

    return $ans;
}

my $x = 0xFFFFFFFF;
my $y = 2;

say perldiv($x, $y);
say intdiv($x, $y);
# say intdiv2($x, $y);

# timethese(100000, {
#    perldiv => sub { perldiv($x, $y) },
#    intdiv  => sub { intdiv ($x, $y) },
#});
