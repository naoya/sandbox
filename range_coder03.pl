#!/usr/bin/env perl
use strict;
use warnings;
use Perl6::Say;
use Params::Validate qw/validate_pos SCALARREF/;

sub put ($$) {
    my ($c, $r_buf) = validate_pos(@_, 1, { type => SCALARREF });
    $$r_buf = join '', $$r_buf, chr( $c & 0xff );
}

sub get ($) {
    my ($r_buf) = validate_pos(@_, { type => SCALARREF });
    my $c = unpack('C', $$r_buf);
    substr($$r_buf, 0, 1) = '';
    return $c;
}

use POSIX qw/floor/;
use List::Util qw/min/;

use constant UCHAR_MAX => 0x100;
use constant TOP       => 1 << 24;
use constant MASK      => 0xFFFFFFFF;

my $L       = 0;
my $R       = 0xFFFFFFFF;
my $D       = 0;
my $buffer  = 0;
my $carryN  = 0;
my $start   = 1;
my $counter = 0;
my $out     = '';

my $str = shift or die "usage: $0 <string>";

# say "MASK: ", bit_string(MASK);
# say "R: ", bit_string($R);

my @chars = unpack('C*', $str);
my @count;
my @Cum;

for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $count[$i] = 0;
}

for (@chars) {
    $count[$_]++;
}

$Cum[0] = 0;
for (my $i = 0; $i < UCHAR_MAX; $i++) {
    $Cum[$i + 1] = $Cum[$i] + $count[$i];
}

my $total = $Cum[UCHAR_MAX];

for my $c (@chars) {
    range_encode($Cum[$c], $Cum[$c + 1], $total);
}

# say @count;
# say @Cum;

say "L($counter): ", bit_string($L);
say "R($counter): ", bit_string($R);

finish();

$R = 0xFFFFFFFF;
$D = 0;

# get(\$out); # ゴミ?
for (my $i = 0; $i < 4; $i++) {
    $D = ($D << 8) | get(\$out);
    say "D: ", bit_string($D);
}

my $res;
for (my $i = 0; $i < $total; $i++) {
    $res .= pack('C*', range_decode($total, $out));
}

say "origin : ", $str;
say "decoded: ", $res;

sub range_encode {
    my ($low, $high, $total) = validate_pos(@_, 1, 1, 1);

    say sprintf "%c => low: $low, high: $high, total: $total", search_code($low);
    say "L($counter): ", bit_string($L);
    say "R($counter): ", bit_string($R);

    my $r = floor( $R / $total );
    say "r($counter): ", bit_string($r);
    if ($high < $total) {
        $R = $r * ($high - $low);
    } else {
        $R -= $r * $low;
    }

    my $newL = $L + ($r * $low) & MASK;
    $newL &= MASK;

    if ($newL < $L) {
        $buffer++;
        for (; $carryN > 0; $carryN--) {
            put($buffer, \$out);
            $buffer = 0;
        }
    }
    $L = $newL;

    while ($R < TOP) {
        my $newBuffer = ($L >> 24) & 0xFF;
        say "newBuffer: ", bit_string($newBuffer);
        if ($start) {
            $buffer = $newBuffer;
            $start  = undef;
        }
        elsif ($newBuffer == 0xFF) {
            $carryN++;
        }
        else {
            put($buffer, \$out);
            for (; $carryN != 0; $carryN--) {
                put(0xff, \$out);
            }
            $buffer = $newBuffer;
        }

        $L = ($L << 8) & MASK;
        $R <<= 8;
    }

    $counter++;
}

sub finish {
    put($buffer, \$out);

    for (; $carryN != 0; $carryN--) {
        put(0xff, \$out);
        say "finish: ", bit_string(0xFF);
    }

    for (my $i = 0; $i < 4; $i++) {
        say "finish() => L: ", bit_string($L);
        put($L >> 24, \$out);
        $L = ($L << 8) & MASK;
    }
}

sub range_decode {
    my ($total, $in) = @_;
    my $r   = floor($R / $total);
    my $pos = min( $total - 1, floor($D / $r) );

    my $code = search_code( $pos );
    my $low  = $Cum[ $code ];
    my $high = $Cum[ $code + 1];

    $D -= $r * $low;
    if ($high != $total) {
        $R = $r * ($high - $low);
    }
    else {
        $R -= $r * $low;
    }

    while ($R < TOP) {
        $R <<= 8;
        $D = ($D << 8) | get(\$in);
    }

    return $code;
}

sub search_code {
    my ($value) = validate_pos(@_, 1);
    use integer;

    my $i = 0;
    my $j = UCHAR_MAX;

    while ($i < $j) {
        my $k = ($i + $j) / 2;
        if ($Cum[ $k + 1 ] <= $value) {
            $i = $k + 1;
        } else {
            $j = $k;
        }
    }

    return $i;
}

## デバッグ用
sub bit_string {
    my $n = shift;
    unpack('B*', pack('N', $n));
}
