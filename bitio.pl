#!/usr/bin/env perl
use strict;
use warnings;
use Perl6::Say;

package Bit::Stream;
use base qw/Class::Accessor::Lvalue::Fast/;

use POSIX qw/ceil/;
use Params::Validate qw/validate_pos/;

__PACKAGE__->mk_accessors(qw/stream count buff mode/);

## read とか write とか好きじゃないなあ...
## new に値がセットされてたら encoder, されてなかったら decoder になればいい
sub new {
    my ($class, $mode, $stream) = validate_pos(@_, 1, 1, { default => '' });

    my $self = $class->SUPER::new;

    if ($mode eq 'r') {
        $self->count = 0;
    } elsif ($mode eq 'w') {
        $self->count = 8;
    } else {
        die 'illegal mode';
    }

    $self->mode   = $mode;
    $self->stream = \$stream;
    $self->buff   = 0;

    bless $self, $class;
}

sub is_writable {
    return shift->mode eq 'w';
}

sub finish {
    my $self = shift;
    if ($self->is_writable) {
        $self->putc($self->buff);
    }
    return $self->stream;
}

sub putc {
    my ($self, $c) = @_;
    ${$self->stream} = join '', ${$self->stream}, chr( $c & 0xff );
}

sub getc {
    my $self = shift;
    my $c = unpack('C', ${$self->stream});
    substr(${$self->stream}, 0, 1) = '';
    return $c;
}

sub getbit {
    my $self = shift;
    $self->count--;

    if ($self->count < 0) {
        $self->buff = $self->getc;
        if (not defined $self->buff) {
            return;
        }
        $self->count = 7;
    }

    return ($self->buff >> $self->count) & 0x01;
}

sub getbits {
    my ($self, $n) = @_;

    my $v = 0;
    my $p = 1 << ($n - 1);

    while ($p > 0) {
        my $bit = $self->getbit;
        if (not defined $bit) {
            return $v;
        }

        if ($bit == 1) {
            $v |= $p;
        }

        $p >>= 1;
    }

    return $v;
}

sub putbit {
    my ($self, $bit) = @_;
    $self->count--;

    if ($bit > 0) {
        $self->buff |= (1 << $self->count);
    }

    if ($self->count == 0) {
        $self->putc($self->buff);
        $self->buff = 0;
        $self->count = 8;
    }

    return $bit;
}

sub putbits {
    my ($self, $n, $value) = @_;
    if ($n > 0) {
        my $p = 1 << ($n - 1);
        while ($p > 0) {
            $self->putbit( $value & $p );
            $p >>= 1;
        }
    }
}

## 0 を考慮した版
# 5 のときは 000001 ... 0 の数が 5
# 0 を考慮しない場合は 00001 です.
sub alpha_encode {
    my ($self, $value) = @_;
    for (my $i = 0; $i < $value; $i++) {
        $self->putbit(0);
    }
    $self->putbit(1);
}

sub alpha_decode {
    my $self = shift;

    my $n = 0;
    while (1) {
        my $bit = $self->getbit;

        if (not defined $bit) {
            return;
        } elsif ($bit == 0) {
            $n++;
        } else {
            last;
        }
    }

    return $n;
}

sub gamma_encode {
    my ($self, $n) = @_;

    ## 例: n == 3 のときは n + 1 = 4 を考える
    ## 0, 1, 2, 3, 4 の 5 種類 (n + 1) + 1 = n + 2 のエントロピー => lg 5
    my $nbits = ceil( log($n + 2) / log(2) );
    $self->alpha_encode($nbits - 1);
    $self->putbits($nbits - 1, $n + 1);
}

sub gamma_decode {
    my $self = shift;
    my $nbits = $self->alpha_decode;

    if (!$nbits) {
        return $nbits;
    }

    return ((1 << $nbits) + $self->getbits($nbits)) - 1;
}

sub delta_encode {
    my ($self, $n) = @_;
    my $nbits = ceil( log($n + 2) / log(2) );
    $self->gamma_encode($nbits - 1);
    $self->putbits($nbits - 1, $n + 1);
}

sub delta_decode {
    my $self = shift;
    my $nbits = $self->gamma_decode;

    if (!$nbits) {
        return $nbits;
    }

    return ((1 << $nbits) + $self->getbits($nbits)) - 1;
}

sub as_binary {
    ${shift->stream};
}

sub as_string {
    unpack('B*', shift->as_binary);
}

package main;

## test for alpha_encode
say "* alpha code\n";

my $enc = Bit::Stream->new('w');

$enc->alpha_encode(5);
$enc->alpha_encode(0);
$enc->alpha_encode(2);
$enc->alpha_encode(3);

$enc->finish;

say $enc->as_string;

my $dec = Bit::Stream->new('r', $enc->as_binary);
while ( defined(my $n = $dec->alpha_decode) ) {
    say $n;
}

## test for gamma code
say "\n* gamma code\n";

my $gamma_w = Bit::Stream->new('w');
$gamma_w->gamma_encode(4);
$gamma_w->gamma_encode(5);
$gamma_w->gamma_encode(1);
$gamma_w->gamma_encode(0);
$gamma_w->gamma_encode(3);
$gamma_w->gamma_encode(128);
$gamma_w->gamma_encode(31);
$gamma_w->finish;

say $gamma_w->as_string;

my $gamma_r = Bit::Stream->new('r', $gamma_w->as_binary);
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;
say $gamma_r->gamma_decode;

## test for delta code
say "\n* delta code\n";

my $delta_w = Bit::Stream->new('w');
$delta_w->delta_encode(4);
$delta_w->delta_encode(5);
$delta_w->delta_encode(0);
$delta_w->delta_encode(9);
$delta_w->delta_encode(28);
$delta_w->finish;

say $delta_w->as_string;

my $delta_r = Bit::Stream->new('r', $delta_w->as_binary);
say $delta_r->delta_decode;
say $delta_r->delta_decode;
say $delta_r->delta_decode;
say $delta_r->delta_decode;
say $delta_r->delta_decode;
