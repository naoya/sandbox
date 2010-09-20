#!/usr/bin/env perl
use strict;
use warnings;
use Mojo::Client;

my $client = Mojo::Client->new;
print $client->get("mojolicious.org")->res->dom->at("title")->text;
# print $client->get("http://digg.com")->res->dom->find("h3 > a.offsite")->each(sub { print shift->text . "\n"});
