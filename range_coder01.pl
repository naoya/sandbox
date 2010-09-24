#!/usr/bin/env perl
# ref: http://www2.starcat.ne.jp/~fussy/algo/algo8-10.htm
# 動作はしているが完全に理解できていない
# 入力が abaca$ などだと複合が正しく動作しない
use strict;
use warnings;

use integer;
use Perl6::Say;
use Data::Dumper;

use constant UCHAR_MAX => 0xff;

my $str = 'abacab';

my @count; # 出現回数
my @accum; # 累積出現回数
my $size = length $str;

for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $count[$i]  = 0;
}

for (split //, $str) {
    $count[ ord($_) ]++;
}

$accum[0] = 0;
for (my $i = 1; $i < UCHAR_MAX + 1; $i++) {
    $accum[$i] = $accum[ $i - 1] + $count[$i - 1];
}

my $low    = 0;
my $range  = 100;

my $code = range_encode( $str );
say;

say range_decode( $code );

## encode
sub range_encode {
    my $str = shift;
    my @chars = split //, $str;

    my $out;
    for (@chars) {
        say sprintf "[%u, %u) <= %s", $low, $range, $_;

        $low += ($range / $size) * $accum[ord($_)];

        ## BUG: 10 / 11 とかだと $range が 0 になって以降計算がおかしくなる
        $range = ($range / $size) * $count[ ord($_) ];
        if ($range == 0) {
            die "ERROR: range goes to 0!";
        }

        if ($range < 10) {
            $low   *= 10;
            $range *= 10;

            ## FIXME: $low の先頭1バイトを $out に
            $out .= substr($low, 0, 1);
            substr($low, 0, 1) = '';
        }
    }

    $out .= $low;
    return $out;
}

## decode
sub range_decode {
    my $bin = shift;
    my $out;
    my $len = length $bin;

    my $low    = substr($bin, 0, 2);
    my $range  = 100;
    my $offset = 2; # 既に先頭2バイト読み取ってるので

    ## 本来この length($str) はバイナリに保存しとく
    for (0.. length($str) - 1) {
        my $code = _decode($low, $range, $size);
        $out .= chr($code);

        say sprintf "[%u, %u) => %s", $low, $range, chr($code);

        ## 再計算
        $low   -= ($range / $size) * $accum[$code];
        $range = ($range / $size) * $count[$code];

        if ($range < 10) {
            $low   *= 10;
            $range *= 10;

            ## $bin から1バイト読み取る
            my $c = substr($bin, $offset++, 1);
            $low += $c;
        }
    }

    return $out;
}

sub _decode {
    my ($low, $range, $size) = @_;

    ## FIXME: ここで計算がおかしくなる?
    return search_code ( $low / ($range / $size) );
}

sub search_code {
    my $value = shift;
    my $i = 0;
    my $j = UCHAR_MAX;

    while ($i < $j) {
        my $k = ($i + $j) / 2;

        if ($accum[ $k + 1 ] <= $value) {
            $i = $k + 1;
        } else {
            $j = $k;
        }
    }

    return $i;
}
