#!/usr/bin/env perl
use strict;
use warnings;

use Perl6::Say;
use List::Util qw/min/;

my @input = (
    "abracadabra",
    "bracadabra",
    "racadabra",
    "acadabra",
    "cadabra",
    "adabra",
    "dabra",
    "abra",
    "bra",
    "ra",
    "a",
);

my $buf = [ map { [ unpack('C*', $_), ord "\$" ] } @input ];

mqsort($buf, 0, scalar @$buf -1, 0);

debug($buf);

use constant LIMIT => 2;

sub debug {
    my $buf = shift;
    for (@$buf) {
        warn sprintf "[ %s ]\n", join(", ",  map { chr } @$_);
    }
}

sub mqsort {
    my ($buf, $low, $high, $n) = @_;

    my $pivot = select_pivot($buf, $low, $high, $n);
    my $i = my $m1 = $low;
    my $j = my $m2 = $high;

    ## 区間 (low, high) を 4分割する
    ## 左、右と言っているが実際には上下で考える方が良い
    ##
    ## 例) n = 0 のときは各文字の先頭が対象になる
    ## [ "a" b r a c a d a b r a ]
    ## [ "b" r a c a d a b r a ]
    ## [ "r" a c a d a b r a ]
    ## [ "a" c a d a b r a ]
    ## ...
    ## [ "a" ]
    ## (i)  low  = 0
    ## (ii) high = 最後の a の位置の添え字
    while (1) {
        ## 左端のポインタ (i) を右 (i++ の方向) へ移動
        ## (i) pivot より大きい値を見つけたらストップ
        ## (ii) pivot と同じ値を見つけたら、m1 の位置のものと交換
        ## この段階では m1 は最左を指している
        while ( $i <= $j ) {
            my $k = $buf->[$i]->[$n];
            if ($k > $pivot) {
                last;
            }

            ## pivot と同じ値は左に持って行く
            if ($k == $pivot) {
                swap($buf, $i, $m1);
                $m1++;
            }

            $i++;
        }

        ## 右端のポインタ(j) を左 (j-- の方向) へ移動。
        ## (i) pivot より大きい値を見つけたらストップ
        ## (ii) pivot と同じ値を見つけたら、m1 の位置のものと交換
        ## この段階では m2 は最右を指している
        while ( $i <= $j ) {
            my $k = $buf->[$j]->[$n];
            if ($k < $pivot) {
                last;
            }

            ## pivot と同じ値は右に持って行く
            if ($k == $pivot) {
                swap($buf, $j, $m2);
                $m2--;
            }

            $j--;
        }

        if ($i > $j) {
            last;
        }

        ## i, j ともに pivot よりも大きい、小さいところまで来たので swap
        ## (普通の Quick Sort)
        swap($buf, $i, $j);
        $i++;
        $j--;
    }

    ## 枢軸と等しいデータ (左端) を中央に集める
    ## low ~ m1 と m1 ~ i で狭い範囲の方を動かす
    my $l_range = min($m1 - $low, $i - $m1);
    for (my $k = 0; $k < $l_range; $k++) {
        swap($buf, $low + $k, $j - $k);
    }
    $m1 = $low + ($i - $m1);

    ## 枢軸と等しいデータ (右端) を中央に集める
    ## j ~ m2 と m2 ~ highで狭い範囲の方を動かす
    my $h_range = min($high - $m2, $m2 - $j);
    for (my $k = 0; $k < $h_range; $k++) {
        swap($buf, $i + $k, $high - $k);
    }
    $m2 = $high - ($m2 - $j) + 1;

    ## この時点で [ low ~ m1 - 1 ] [ m1 ~ m2 -1 ] [m2 ~ high] の 3区間になっている
    ## ([ m1 ~ m2 - 1 ] が pivot と等しかった区間)

    # say debug($buf);

    ## 枢軸より小さい区間 [ low ~ m1 - 1 ] を分割統治
    if ($low < $m1) {
        mqsort( $buf, $low, $m1 - 1, $n );
    }

    ## 枢軸と等しい区間 [ m1 ~ m2 - 1 ] を分割統治
    ## ただし n 文字目は全部等しいので n + 1 に移動
    if ($m1 < $m2 and $buf->[$m1]->[$n] != ord "\$") {
        mqsort( $buf, $m1, $m2 - 1 , $n + 1);
    }

    ## 枢軸より大きい [ m2 ~ high ] 区間を分割統治
    if ($m2 <= $high) {
        mqsort( $buf, $m2, $high, $n );
    }
}

sub select_pivot {
    my ($buf, $low, $high, $n) = @_;
    use integer;

    my $l = $buf->[$low]->[$n];
    my $m = $buf->[ ($low + $high) / 2 ]->[$n];
    my $h = $buf->[$high]->[$n];

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
    my ($buf, $x, $y) = @_;
    my $tmp = $buf->[$x];
    $buf->[$x] = $buf->[$y];
    $buf->[$y] = $tmp;
}

