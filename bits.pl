#!/usr/bin/env perl
use strict;
use warnings;
use Perl6::Say;

say 'OR';
say 0|0;
say 1|0;
say 0|1;
say 1|1;

say 'AND';
say 0&0;
say 0&1;
say 1&0;
say 1&1;

## MASK (AND) => 立ってるビットを取り出す
my $mask = 0xff; ## 1byte mask => これと AND を取ると、bit が立ってるとこだけ残る

say 4   & 0xff;   # 4
say 256 & 0xff;   # 0
say 257 & 0xff;   # 1
say 258 & 0xff;   # 2
say 258 & 0xffff; # 258

say bitstr(256 & 0xff);            #  00000000
say bitstr(256 >> 1, 0xff);        #  10000000 = 128
say 256 >> 1;

say 2 << 3; # 2^3 倍する ... 16
say bitstr( 2 << 3 & 0xff);        #  00000010 -> 00010000

say bitstr((1024 + 259) & 0xff  ); #  00000011
say bitstr(259 & 0xffff);          # 100000011

## MASK (OR) => ビットを立てる
say bitstr( 0 | 0xf0 );            #  11110000
say bitstr( 1 | 0xf0 );            #  11110001
say bitstr( 160       );           #  10100000
say bitstr( 160 | 0xf0);           #  11110000

sub bitstr {
    my $n = shift;
    return unpack('B*', pack('N', $n));
}

