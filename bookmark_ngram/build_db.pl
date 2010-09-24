#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;
use XML::RSS::LibXML;
use DBI;
use Encode;

sub trim ($) {
    my $text = shift or return;
    $text =~ s!^\s+!!;
    $text =~ s!\s+$!!;
    $text =~ s!\n!!;
    return $text;
}

my $file = shift or die "usage: $0 <rssfile>\n";
my $dbh = DBI->connect('dbi:mysql:dbname=my_bookmark;host=127.0.0.1', 'nobody', 'nobody')
    or die DBI->errstr;

my $rss = XML::RSS::LibXML->new;
$rss->parsefile($file);

for ($rss->items) {
    my $tag = '';
    if (my $t = $_->{dc}->{subject}) {
        $tag = ref $t ? sprintf '[%s]', join '][', @$t : sprintf '[%s]', $t;
    }

    my $comment = sprintf "%s%s", $tag, trim $_->{description} || '';
    my $sql = sprintf(
        'INSERT INTO bookmark VALUES(NULL, %s, %s, %s)',
        $dbh->quote( $_->{link} ),
        $dbh->quote( trim $_->{title} ),
        $dbh->quote( $comment || '' ),
    );

    eval {
        my $sth = $dbh->prepare($sql) or die $dbh->errstr;
        $sth->execute or die $sth->errstr;
    };
    if (my $err = $@) {
        warn $err;
    }
}
