#!/usr/local/bin/perl
use strict;
use warnings;
use Perl6::Say;
use Data::Dumper;

my @data = (9, 8, 6, 5, 10, 11, 5, 2, 8, 4, 1, 0, 15, 12, 6);

quick_sort(\@data, 0, $#data);

warn Data::Dumper::Dumper( \@data );

sub quick_sort {
    my ($data, $start, $end) = @_;

    my $i     = $start;
    my $j     = $end - 1;
    my $pivot = $data->[$end];

    if ($j - $i <= 1) {
        return;
    }

    while (1) {
        while ($data->[$i] < $pivot) {
            $i++;
        }

        while ($i < $j && $data->[$j] > $pivot) {
            $j--;
        }

        if ($i >= $j) {
            last;
        }

        swap(\$data->[$i], \$data->[$j]);
    }

    swap(\$data->[$i], \$data->[$end]);

    quick_sort($data, 0, $i - 1);
    quick_sort($data, $i + 1, $end);
}

sub swap {
    my ($x, $y) = @_;
    my $tmp = $$x;
    $$x = $$y;
    $$y = $tmp;
}
