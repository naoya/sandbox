#!/usr/local/bin/perl
use strict;
use warnings;
use Perl6::Say;

sub encode_vb ($) {
    pack('w', shift);
}

sub decode_vb ($) {
    unpack('w', shift);
}

sub decode_vbx ($) {
    my $binref = shift;

    my $n = decode_vb $$binref;
    substr($$binref, 0, length encode_vb $n) = '';

    $n;
}

sub front_encode (@) {
    my @in = @_;
    my @prev = ();
    my $out;

    for (@_) {
        my $n_match = 0;

        my @cur = split //;

        while ( $n_match < @prev and
                $n_match < @cur  and
                $prev[ $n_match ] eq $cur[ $n_match ]) {
            $n_match++;
        }

        ## 前の要素との一致部分を削除
        substr($_, 0, $n_match) = '';

        $out .= encode_vb $n_match; ## 一致長
        $out .= encode_vb length;   ## 残りの長さ
        $out .= $_;

        @prev = @cur;
    }

    return $out;
}

sub front_decode ($) {
    my $in = shift;
    my @out = ();
    my $prev = '';

    while (length $in > 0) {
        my $n_match = decode_vbx(\$in);
        my $n_rest  = decode_vbx(\$in);

        ## 前要素との一致部分、残り部分を接続して復元
        my $cur = sprintf "%s%s", substr($prev, 0, $n_match), substr($in, 0, $n_rest);

        push @out, $cur;
        $prev = $cur;

        ## 読み出した分を削る
        substr($in, 0, $n_rest) = '';
    }

    return @out;
}

my @input = (
    'http://www.hoge.jp',
    'http://www.hoge.jp/a.htm',
    'http://www.hoge.jp/index.htm',
    'http://www.fuga.com/',
    'http://www.fugafuga.com/',
);

my $bin = front_encode @input;
say for front_decode $bin;
