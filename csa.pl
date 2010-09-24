#!/usr/bin/env perl
use strict;
use warnings;

use FindBin::libs;
use Perl6::Say;
use Data::Dumper qw/Dumper/;
use Algorithm::DivSufSort;

my $text = shift or die "usage: $0 <text>";
my @text = split //, $text;
my $len = length $text;

say "        ", join '  ', map { sprintf "%2d", $_ } (0..$len - 1);
say "------------------------------------------------------";

## Suffix Array
my $sa = divsufsort $text;

say sprintf " SA[] = %s", join ', ', map { sprintf "%2d", $_ } @$sa;

## BWT (参考までに)
my @bwt = map { $_ - 1 } @$sa;

say sprintf "BWT[] = %s", join ', ', map { sprintf "%2d", $_ } @bwt;
# say join '', map { $text[$_] } @bwt;

## Inverted Suffix Array
my $isa;
for (my $i = 0; $i < $len; $i++) {
    $isa->[ $sa->[$i] ] = $i;
}

say sprintf "iSA[] = %s", join ', ', map { sprintf "%2d", $_ } @$isa;

my $psi;
for (my $i = 0; $i < $len; $i++) {
    my $pos = $sa->[$i] + 1;
    if ($pos == $len) {
        $pos = 0;
    }
    $psi->[$i] = $isa->[ $pos ];
}

say sprintf "psi[] = %s", join ', ', map { sprintf "%2d", $_ } @$psi;

use constant UCHAR_MAX => 0x100;

my @freq;
for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $freq[$i] = 0;
}

for my $c ( unpack('C*', $text) ) {
    $freq[$c]++;
}

my @cum = (0);
for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $cum[ $i + 1 ] = $cum[$i] + $freq[$i];
}

## "abracadabra$";
## substr(2, 4) => raca
say sa_substr($isa, $psi, \@cum, 6, 8);
say substr($text, 6, 8);

## text を必要としてない点に着目
## なんでこれでいけるのかなあ
## あと、最初の $isa->[$i] を得るには iSA が必要だけど...
sub sa_substr {
    my ($isa, $psi, $cum, $offset, $length) = @_;
    my $out = '';

    my $i = $offset;
    my $j = $offset + $length;

    for (my $p = $isa->[$i]; $i < $j; $i++) {
        my $c = search_code($p, $cum);
        $out = join '', $out, chr $c;

        if (chr $c eq "\$") {
            last;
        }

        $p = $psi->[$p];
    }

    return $out;
}

# say search_code( 5 , \@cum );

sub search_code {
    my ($value, $cum) = @_;
    use integer;

    my $i = 0;
    my $j = UCHAR_MAX;

    while ($i < $j) {
        my $k = ($i + $j) / 2;
        if ($cum->[ $k + 1 ] <= $value) {
            $i = $k + 1;
        } else {
            $j = $k;
        }
    }

    return $i;
}

