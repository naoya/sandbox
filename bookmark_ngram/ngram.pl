#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark::Timer;
use DBI;
use Encode;
use FindBin::libs;
use IO::Handle;
use Lux::IO;
use Lux::IO::Btree;
use Perl6::Say;
use Storable qw/thaw/;
use Term::Encoding qw/term_encoding/;
use Term::ReadLine;
use Text::Kgram;

sub intersect ($$) {
    my ($p1, $p2) = @_;
    my $answer = [];

    my $i = 0;
    my $j = 0;

    while (defined $p1->[$i] and defined $p2->[$j]) {
        if ($p1->[$i] == $p2->[$j]) {
            push @$answer, $p1->[$i];
            $i++;
            $j++;
        } else {
            $p1->[$i] < $p2->[$j] ? $i++ : $j++;
        }
    }

    return $answer;
}

sub search_index (@) {
    my ($index, $df, @terms) = @_;

    @terms = map { $_->[0] } sort { $a->[1] <=> $b->[1] } map { [ $_, $df->get($_) || 0 ] } @terms;

    my $result = get_postings($index, shift @terms);
    while (@terms > 0 and defined $result) {
        $result = intersect $result, get_postings($index, shift @terms);
    }

    return $result;
}

sub get_postings {
    my ($index, $token) = @_;
    my $p_bin = $index->get($token);
    if (not defined $p_bin) {
        return [];
    } else {
        return thaw($p_bin);
    }
}

my $dbh = DBI->connect('dbi:mysql:dbname=my_bookmark;host=127.0.0.1', 'nobody', 'nobody')
    or die DBI->errstr;
$dbh->{mysql_use_result} = 1;

my $enc    = find_encoding( term_encoding );
my $ngram  = Text::Kgram->new;
my $term   = Term::ReadLine->new;
my $prompt = '> ';

## FIME: index と df の持ち方が冗長
my $index  = Lux::IO::Btree->new(Lux::IO::NONCLUSTER);
$index->open('naoya', Lux::IO::DB_RDONLY);

my $df = Lux::IO::Btree->new(Lux::IO::CLUSTER);
$df->open('naoya_df', Lux::IO::DB_RDONLY);

while (my $q = $term->readline($prompt)) {
    my $timer  = Benchmark::Timer->new;
    $timer->start('search');

    my @querys = split /\s+/, $enc->decode($q);
    my @tokens = map { $ngram->tokenize(lc $_) } @querys;
    my $res = search_index($index, $df, @tokens);

    $timer->stop('search');

    my $i = 0;
    for (; $i < 5; $i++) {
        if ($i == @$res) {
            last;
        }

        my $sth = $dbh->prepare(sprintf 'select * from bookmark where id = %d', $res->[$i]);
        $sth->execute;

        my $bookmark = $sth->fetchrow_hashref;
        print $enc->encode(sprintf "%s\n%s\n", decode_utf8($bookmark->{title}), $bookmark->{url});
        if ($bookmark->{comment}) {
            print $enc->encode(sprintf "%s\n", decode_utf8($bookmark->{comment}));
        }
        print "\n";
    }

    printf "%d of %d results, %s", $i, scalar @$res, scalar $timer->reports;
    $term->addhistory($q);
}
