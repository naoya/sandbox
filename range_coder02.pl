#!/usr/bin/env perl
# ref: http://www.geocities.jp/m_hiroi/light/pyalgo36.html
# 今のところうまく動作せず
use strict;
use warnings;

use integer;
use Perl6::Say;
use Math::BigInt only => 'GMP';
use List::Util qw/max/;
use Data::Dumper;

my $out;

sub putc ($) {
    my $x = shift;
    $out .= chr($x & 0xff);
}

sub getch {
    my $c = substr($out, 0, 1);
    substr($out, 0, 1) = '';
    return ord($c);
}

my $str  = "abacab";

my $RANGE_MAX = Math::BigInt->new('0x100000000');
my $RANGE_MIN = 0x1000000;
my $mask      = 0xffffffff;
my $shift     = 24;

my @str = split //, $str;

my @count;     # 頻度表
my @count_sum; # 累積頻度表

for (my $i = 0; $i < 255 + 1; $i++) {
    $count[$i] = 0;
}

for (@str) {
    $count[ ord($_) ]++;
}

my $size = @count;

$count_sum[0] = 0;
for (my $i = 0; $i < $size; $i++) {
    $count_sum[$i + 1] = $count_sum[ $i ] + $count[ $i ];
}

my $range = $RANGE_MAX;
my $low = 0;
my $buf = 0;
my $cnt = 0;

for (@str) {
    say sprintf "[%s, %s)", $low, $range;

    ## encode()
    my $unit = $range / $count_sum[$size];

    $low  += $count_sum[ord($_)] * $unit;
    $range = $count[ord($_)]     * $unit;

    ## 符号化の正規化
    ## encode_normalize()
    if ($low >= $RANGE_MAX) {
        # 桁上がり
        $buf += 1;
        $low &= $mask;

        if ($cnt > 0) {
            putc $buf;
            for (0 .. $cnt - 1) {
                putc(0);
            }
            $buf = 0;
            $cnt = 0;
        }
    }

    while ($range < $RANGE_MIN) {
        if ($low < (0xff << $shift)) {
            putc $buf;
            for (0..$cnt) {
                putc 0xff;
            }
            $buf = ($low >> $shift) & 0xff;
            $cnt = 0;
        } else {
            $cnt += 1;
        }

        $low = ($low << 8) & $mask;
        $range <<= 8;
    }
}

## finish()
my $c = 0xff;
if ($low >= $RANGE_MAX) {
    # 桁上がり
    $buf += 1;
    $c   = 0;
}

putc $buf;
for (0..$cnt) {
    putc $c;
}

# $low を出力
putc( (($low >> 24) & 0xff) );
putc( (($low >> 16) & 0xff) );
putc( (($low >> 8)  & 0xff) );
putc( ($low & 0xff) );

## decode 開始 -----------------------------------------------------------------------
say "decoding ...";

getch; ## buf の初期値 (0) 読み捨て
# 4 byte read
$low = getch;
$low = ($low << 8) + getch;
$low = ($low << 8) + getch;
$low = ($low << 8) + getch;
$buf = 0;
$cnt = 0;
$range = $RANGE_MAX;
my $res;

## decode()
my $sz = scalar @str;
for (0..$sz - 1) {
    say sprintf "[%s, %s)", $low, $range;

    my $unit = $range / $count_sum[$size];
    my $code = search_code( $low / $unit );
    $res .= chr($code);

    $low   -= $unit * $count_sum[ $code ];
    $range  = $unit * $count[ $code ];

    ## decode_normalize()
    while ($range < $RANGE_MIN) {
        $range <<= 8;
        $low = (($low << 8) + getch) & $mask;
    }
}

say $res;

sub search_code {
    my $value = shift;

    my $i = 0;
    my $j = $size - 1;

    while ($i < $j) {
        my $k = ($i + $j) / 2;
        if ($count_sum[ $k + 1 ] <= $value) {
            $i = $k + 1;
        } else {
            $j = $k;
        }
    }
    return $i;
}
