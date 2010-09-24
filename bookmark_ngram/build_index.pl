#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use DBI;
use Encode;
use Text::Kgram;
use Lux::IO;
use Lux::IO::Btree;
use Storable qw/nfreeze thaw/;

sub build_index {
    my $dbh = shift;
    my $index = {};

    my $sth = $dbh->prepare('select * from bookmark order by id')
        or die $dbh->errstr;
    $sth->execute or die $sth->errstr;

    my $ngram = Text::Kgram->new;
    while (my $bookmark = $sth->fetchrow_hashref) {
        my @tokens;
        for ($bookmark->{title}, $bookmark->{url}, $bookmark->{comment}) {
            $_ or next;
            if ( my @res = $ngram->tokenize(decode_utf8($_)) ) {
                push @tokens, @res;
            }
        }

        my %seen;
        for (@tokens) {
            ## unique check
            if ($seen{$_}) {
                next;
            }
            add_to_index($index, lc $_, $bookmark->{id});
            $seen{$_}++;
        }
        warn sprintf "indexed: %s\n", $bookmark->{id};
    }
    $sth->finish;

    return $index;
}

sub add_to_index {
    my ($index, $token, $id) = @_;
    $index->{$token} ||= [];
    push @{$index->{$token}}, $id;
}

my $dbh = DBI->connect('dbi:mysql:dbname=my_bookmark;host=127.0.0.1', 'nobody', 'nobody')
    or die DBI->errstr;
$dbh->{mysql_use_result} = 1;

my $index = build_index($dbh);

my $postings = Lux::IO::Btree->new(Lux::IO::NONCLUSTER); ## CLUSTER だとバグる
$postings->open('naoya', Lux::IO::DB_CREAT);

my $df = Lux::IO::Btree->new(Lux::IO::CLUSTER);
$df->open('naoya_df', Lux::IO::DB_CREAT);

while (my ($k, $v) = each %$index) {
    warn sprintf "save to BTree: %s (%d)\n", $k, scalar @$v;
    $postings->put(encode_utf8($k), nfreeze($v), Lux::IO::OVERWRITE);
    $df->put(encode_utf8($k) => scalar @$v);
}
$postings->close;
$df->close;
