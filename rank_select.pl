#!/usr/bin/env perl
use strict;
use warnings;

## O(n) �� rank() / select() ����
package RankSelect;

sub new {
    my ($class, $array) = @_;
    bless $array || [], $class;
}

# self[0..n] ��� index ���ܤޤǤ˴ޤޤ�� c �ο�
sub rank {
    my ($self, $index, $c) = @_;
    my $cnt = 0;

    for (my $i = 0; $i < $index; $i++) {
        if ($self->[$i] eq $c) {
            $cnt++;
        }
    }

    return $cnt;
}

# self[0..n] ��� count ���ܤ� c �ΰ���
sub select {
    my ($self, $count, $c) = @_;
    my $found = 0;

    my $len = @$self;
    for (my $i = 0; $i < $len; $i++) {
        if ($self->[$i] eq $c) {
            if (++$found == $count) {
                return $i;
            }
        }
    }

    return;
}

package main;
use Perl6::Say;

my $text = "d#rcaaaabb";
my @text = split //, $text;

my $list = RankSelect->new(\@text);

say $list->rank(6, 'a');
say $list->select(4, 'a');
say $list->select(2, 'b');
