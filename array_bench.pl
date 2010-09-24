#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use Benchmark;
use Array::Util;

timethese (100000, {
    'splice' => sub {
        my @array = (0..1000);
        Array::Util::delete_at(@array, 100);
    },
    'for'    => sub {
        my @array = (0..1000);
        Array::Util::old_delete_at(@array, 100);
    },
});
