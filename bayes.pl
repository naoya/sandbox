#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper qw/Dumper/;
use Algorithm::NaiveBayes;

my $bayes = Algorithm::NaiveBayes->new;

$bayes->add_instance(attributes => { '����' => 2, '�ϤƤ�' => 5 }, label => 'it'  );
$bayes->add_instance(attributes => { '���ñۤ�' => 1, '��' => 1 }, label => 'life');

$bayes->train;

my $res = $bayes->predict(attributes => { '�ϤƤ�' => 1, '����' => 1, '���ñۤ�' => 1 });

warn Dumper( $res );




