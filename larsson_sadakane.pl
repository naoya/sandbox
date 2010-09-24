#!/usr/bin/env perl
# うまく動かず。大枠としてやってることは分かるけど実装が難しい...
use strict;
use warnings;

package SuffixArray::LS;

use constant BUF      => 0;
use constant INDEX    => 1;
use constant SIZE     => 2;
use constant RANK     => 3;
use constant MSD_SIZE => 256 * 256;

use List::Util qw/min/;

sub new {
    my ($class, $buf, $index) = @_;
    my $self = bless [], $class;

    $self->[BUF]   = $buf;
    $self->[INDEX] = $index;
    $self->[SIZE]  = @$buf;

    return $self;
}

sub build_sa {
    my $self = shift;

    ## 最初に2文字で分布数え上げソート..., 初期ランクセット
    my @count;
    for (my $i = 0; $i < MSD_SIZE; $i++) {
        $count[$i] = 0;
    }

    for (my $i = 0; $i < $self->[SIZE]; $i++) {
        $count[ ($self->[BUF]->[$i] << 8) + $self->[BUF]->[$i + 1] ]++;
    }

    my @cum = (0);
    for (my $i = 0; $i < MSD_SIZE; $i++) {
        $cum[$i] = $cum[$i - 1] + $count[$i];
    }

    for (my $i = 1; $i < MSD_SIZE; $i++) {
        $count[$i] += $count[$i - 1];
    }

    for (my $i = $self->[SIZE] - 1; $i >= 0; $i--) {
        my $c = ($self->[BUF]->[$i] << 8) + $self->[BUF]->[$i + 1];
        $count[$c]--;
        $self->[ INDEX ]->[ $count[$c] ] = $i;
        $self->[RANK]->[$i] = $cum[ $c + 1 ] - 1;
    }

    my $n = 2;
    while ( $n < $self->[SIZE] ) {
        my $low  = 0;
        my $flag = 1;

        while ($low < $self->[SIZE]) {
            my $tmp = $low;

            while ($tmp < $self->[SIZE] and $self->[INDEX] < 0) {
                $tmp -= $self->[INDEX]->[$tmp];
            }

            if ($low < $tmp) {
                $self->[INDEX]->[$low] = -($tmp - $low);
                $low = $tmp;
            }

            if ($low < $self->[SIZE]) {
                my $high = $self->[RANK]->[ $self->[INDEX]->[$low] ];
                $self->mqsort($low, $high, $n);
                $low = $high + 1;
                $flag = undef;
            }
        }

        if ($flag) {
            last;
        }

        ## doubling
        $n *= 2;
    }

    for (my $i = 0; $i < $self->[SIZE]; $i++) {
        $self->[INDEX]->[ $self->[RANK]->[$i] ] = $i;
    }

    return $self->[INDEX];
}

sub mqsort {
    my ($self, $low, $high, $n) = @_;

    my $p = $self->select_pivot($low, $high, $n);

    my $i = my $m1 = $low;
    my $j = my $m2 = $high;

    while (1) {
        while ( $i <= $j ) {
            my $k = $self->rank( $self->[INDEX]->[$i] + $n );
            if ($k > $p) {
                last;
            }

            if ($k == $p) {
                swap($self->[INDEX], $i, $m1);
                $m1++;
            }
            $i++;
        }

        while ( $i <= $j ) {
            my $k = $self->rank( $self->[INDEX]->[$j] + $n);
            if ($k < $p) {
                last;
            }

            if ($k == $p) {
                swap($self->[INDEX], $j, $m2);
                $m2--;
            }
            $j--;
        }

        if ($i > $j) {
            last;
        }

        swap($self->[INDEX], $i, $j);
        $i++;
        $j--;
    }

    my $l_range = min($m1 - $low, $i - $m1);
    for (my $k = 0; $k < $l_range; $k++) {
        swap($self->[INDEX], $low + $k, $j - $k);
    }
    $m1 = $low + ($i - $m1);

    my $h_range = min($high - $m2, $m2 - $j);
    for (my $k = 0; $k < $h_range; $k++) {
        swap($self->[INDEX], $i + $k, $high - $k);
    }
    $m2 = $high - ($m2 - $j) + 1;

    if ($low < $m1) {
        $self->mqsort($low, $m1 - 1, $n);
    }

    if ($m2 > $m1) {
        if ($m2 - $m1 == 1) {
            $self->[RANK]->[ $self->[INDEX]->[$m1] ] = $m1;
            $self->[INDEX]->[$m1] = -1;
        } else {
            my $r = $m2 - $m1;
            for (my $i = $m1; $i < $m2; $i++) {
                $self->[RANK]->[ $self->[INDEX]->[$i] ] = $r;
            }
        }
    }

    if ($m2 <= $high) {
        $self->mqsort($m2, $high, $n);
    }
}

sub select_pivot {
    my ($self, $high, $low, $n) = @_;
    my $m = ($high - $low) / 4;

    my $a = $self->rank( $self->[INDEX]->[$low + $m]     + $n );
    my $b = $self->rank( $self->[INDEX]->[$low + $m * 2] + $n );
    my $c = $self->rank( $self->[INDEX]->[$low + $m * 3] + $n );

    ## 中間値
    if ($a > $b) {
        my $tmp = $a;
        $a = $b;
        $b = $tmp;
    }

    if ($b > $c) {
        $b = $c;
        if ($a > $b) {
            $b = $a;
        }
    }

    return $b;
}

sub rank {
    my ($self, $x) = @_;
    ($x < $self->[SIZE]) ? $self->[RANK]->[$x] : -1;
}

sub swap {
    my ($buf, $x, $y) = @_;
    my $tmp = $buf->[$x];
    $buf->[$x] = $buf->[$y];
    $buf->[$y] = $tmp;
}

package main;

my $str = "abracadabra\$";
my @buf = unpack('C*', $str);
my @index;
for (my $i = 0; $i < @buf; $i++) {
    $index[$i] = $i;
}

my $ls = SuffixArray::LS->new(\@buf, \@index);
my $sa = $ls->build_sa;

require Data::Dumper;
warn Data::Dumper::Dumper($sa);
