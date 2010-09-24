#!/usr/local/bin/perl
use strict;
use warnings;

use Perl6::Say;
use Params::Validate qw/validate_pos SCALARREF/;
use Data::Dumper;

use constant UCHAR_MAX => 0x100;

sub bs_encode ($) {
    my $text = shift;
    my @block;
    my $len = length $text;

    for (my $i = 0; $i < $len; $i++) {
        $block[$i] = $text;

        ## 末尾に先頭一文字を移動
        $text .= substr($text, 0, 1);
        substr($text, 0, 1) = '';
    }

    ## ソート済みのブロックの各行から末尾一文字を返す
    return join '', map { substr($_, -1, 1) } sort @block;
}

sub bs_decode ($) {
    my $bwt = shift;

    my $len = length $bwt;
    my @data = split //, $bwt;

    ## 末尾のポジションを調べる
    my $pos = 0;
    for (; $pos < @data; $pos++) {
        if ($data[$pos] eq "\$") {
            last;
        }
    }

    my @LFMapping = sort { $data[$a] cmp $data[$b] } (0..$len - 1);

    my @buf;
    for (my $i = 0; $i < $len; $i++) {
        $pos = $LFMapping[ $pos ];
        push @buf, $data[ $pos ];
    }

    return join '', @buf;
}

# sub bs_decode ($) {
#     my ($data) = validate_pos(@_, { type => SCALARREF });

#     my $pos = - 1;
#     my @data = split //, $$data;
#     my $len  = length $$data;
#     my @count;

#     for (my $i = 0; $i < UCHAR_MAX; $i++) {
#         $count[$i] = 0;
#     }

#     for (my $i = 0; $i < $len; $i++) {
#         if ($data[$i] eq "\$") {
#             $pos = $i;
#         }
#         $count[ ord $data[$i] ]++;
#     }

#     for (my $i = 0; $i < UCHAR_MAX; $i++) {
#         $count[$i] += $count[$i - 1];
#     }

#     my @LFmapping;
#     for (my $i = $len - 1; $i >= 0; $i--) {
#         $LFmapping[ --$count[ ord $data[$i] ] ] = $i;
#     }

#     my @buff;
#     for (0..$len - 1) {
#         $pos = $LFmapping[ $pos ];
#         push @buff, $data[ $pos ];
#     }

#     return join '', @buff;
# }

my $text = shift or die "usage: $0 <text>";
my $bwt = bs_encode $text;
say $bwt;
say bs_decode $bwt;
