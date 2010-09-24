#!/usr/bin/env perl
#
# Two Stage Sort では Type B の区間だけをソートしたり、Type A の区間の空いているところに
# 要素を差し込んだりと、特定の区間をピンポイントで操作することがよくある。そのとき
# 累積頻度表を使いまくる。ソートされている文字列なら同一文字列が続く区間は累積頻度表で O(1) で求められる
use strict;
use warnings;
use FindBin::libs;
use Perl6::Say;
use List::Util qw/min/;

use constant A => 0;
use constant B => 1;

my $str = "abracadabra\$";

my $buf = [ unpack('C*', $str) ];

my @count;
for (my $i = 0; $i < 0xff * 0xff; $i++) {
    $count[$i] = 0;
}

for (my $i = 0; $i < @$buf; $i++) {
    $count[ ($buf->[$i] << 8) + ($buf->[$i + 1] || 0)  ]++;
}

## こっちは Type B や Type A の区間を見つける用
my @cum = (0);
for (my $i = 1; $i < 0xff * 0xff + 1; $i++) {
    $cum[$i] = $cum[$i - 1] + $count[$i - 1];
}

## 累積カウントテーブルが二つ必要になる
## こっちは最初の先頭2文字での分布数え上げソート用
for (my $i = 1; $i < 0xff * 0xff; $i++) {
    $count[$i] += $count[$i - 1];
}

## 先頭二文字で分布数え上げソート
my $SA = [];
for (my $x = @$buf - 1; $x >= 0; $x--) {
    my $c = ($buf->[$x] << 8) + ($buf->[$x + 1] || 0);
    $count[$c] -= 1;
    $SA->[ $count[$c] ] = $x;
}

dump_SA($buf, $SA);

## Type B区間でソートの必要がある箇所をソート
## Type B区間は先頭二文字の累積頻度表で調べる
## ここがマジカルすぎる...
for (my $x = 0; $x < 0xff; $x++) {
    for (my $y = $x; $y < 0xff; $y++) {
        my $low  = $cum[ ($x << 8) + $y] or next;
        my $high = $cum[ ($x << 8) + $y + 1 ] - 1; # ここで -1 するのは累積頻度表的にソートしなくていい区間を定めるため

        ## high > low なら Type B 且つ要ソート
        ## マルチキークイックソートなら指定区間だけをソートできる
        if ($high > $low) {
            warn sprintf "%d - %d", $low, $high;
            mqsort($SA, $buf, $low, $high, 2);
        }
    }
}

dump_SA($buf, $SA);

## Type A 区間をセットしていく
# set_type_a(scalar @$buf);

## SA の上(先頭)から舐めて行って、S(i - 1) と S(i) が Type A の関係になっていたら
## i - 1 をその bucket の一番小さい空いてるインデックスに入れる
for (my $x = 0; $x < @$buf; $x++) {
    my $i = $SA->[$x];
    if ($i > 0 and $buf->[$i - 1] > $buf->[$i]) { ## Type A は S(i - 1) > S(i)
        set_type_a($i - 1);
    }
}

sub set_type_a {
    my $i = shift;
    my $c = ($buf->[$i] << 8) + $buf->[$i + 1];
    $SA->[ $cum[$c] ] = $i;
    $cum[$c]++; # 一個スロットが埋まったので ++ する
}

say;
dump_SA($buf, $SA);

sub dump_SA {
    my ($buf, $SA) = @_;
    my $offset = 0;
    for my $i (@$SA) {
        my $suffix = join '', map { chr } @$buf[$i..@$buf - 1];
        my $type = (defined $buf->[$i + 1] and $buf->[$i] > $buf->[$i + 1]) ? A : B;
        printf(
            "%2d %s: %2d %s\n",
            $offset++,
            $type == A ? 'A' : 'B',
            $i,
            $suffix
        );
    }
}

sub mqsort {
    my ($SA, $buf, $low, $high, $n) = @_;

    my $p = select_pivot($SA, $buf, $low, $high, $n);

    my $i = my $m1 = $low;
    my $j = my $m2 = $high;

    while (1) {
        while ( $i <= $j ) {
            my $k = get_code($buf, $SA->[$i] + $n) - $p;
            if ($k > 0) {
                last;
            }
            if ($k == 0) {
                swap($SA, $i, $m1);
                $m1++;
            }
            $i++;
        }

        while ( $i <= $j ) {
            my $k = get_code($buf, $SA->[$j] + $n) - $p;
            if ($k < 0) {
                last;
            }
            if ($k == 0) {
                swap($SA, $j, $m2);
                $m2--;
            }
            $j--;
        }

        if ($i > $j) {
            last;
        }

        swap($SA, $i, $j);
        $i++;
        $j--;
    }

    my $l_range = min($m1 - $low, $i - $m1);
    for (my $k = 0; $k < $l_range; $k++) {
        swap($SA, $low + $k, $j - $k);
    }
    $m1 = $low + ($i - $m1);

    my $h_range = min($high - $m2, $m2 - $j);
    for (my $k = 0; $k < $h_range; $k++) {
        swap($SA, $i + $k, $high - $k);
    }
    $m2 = $high - ($m2 - $j) + 1;

    if ($low < $m1) {
        mqsort( $SA, $buf, $low, $m1 - 1, $n );
    }

    if ($m2 < $high) {
        mqsort( $SA, $buf, $m2, $high, $n );
    }

    if ($m1 < $m2 and get_code($buf, $SA->[$m1] + $n) != ord "\$") {
        mqsort( $SA, $buf, $m1, $m2 - 1, $n + 1);
    }
}

sub get_code ($$) {
    my ($buf, $n) = @_;
    if ($n < @$buf) {
        return $buf->[$n];
    }
    return -1;
}

sub select_pivot {
    my ($SA, $buf, $low, $high, $n) = @_;
    use integer;

    my $i = ($high - $low) / 4;

    my $l = get_code($buf, $SA->[$low + $i]     + $n);
    my $m = get_code($buf, $SA->[$low + $i * 2] + $n);
    my $h = get_code($buf, $SA->[$low + $i * 3] + $n);

    if ($l > $m) {
        my $tmp = $l;
        $l = $m;
        $m = $tmp;
    }

    if ($m > $h) {
        $m = $h;
        if ($l > $m) {
            $m = $l;
        }
    }

    return $m;
}

sub swap {
    my ($SA, $x, $y) = @_;
    my $tmp = $SA->[$x];
    $SA->[$x] = $SA->[$y];
    $SA->[$y] = $tmp;
}
