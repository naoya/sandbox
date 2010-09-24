#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper qw/Dumper/;
use Algorithm::NaiveBayes;

my $bayes = Algorithm::NaiveBayes->new;

$bayes->add_instance(attributes => { '京都' => 2, 'はてな' => 5 }, label => 'it'  );
$bayes->add_instance(attributes => { '引っ越し' => 1, '春' => 1 }, label => 'life');

$bayes->train;

my $res = $bayes->predict(attributes => { 'はてな' => 1, '京都' => 1, '引っ越し' => 1 });

warn Dumper( $res );




