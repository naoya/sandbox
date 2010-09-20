#!/usr/bin/env perl
# http://gihyo.jp/dev/serial/01/modern-perl/0022
use Mojolicious::Lite;
use utf8;

app->log->level('error');
app->types->type(html => 'text/html; charset=utf-8');

get '/' => sub {
    shift->render(text => 'Hello, World!');
};

get '/foo' => '*';

get '/baz' => sub {
    my $self = shift;
    $self->render('baz', layout => 'green');
};

# app->start;
shagadelic;

__DATA__

@@ index.html.ep
Hello?

@@ foo.html.ep
hmm...

@@ baz.html.ep
こんにちは

@@ layouts/green.html.ep
<!doctype html>
<html lang="ja">
  <head>
    <title>Green!</title>
    <meta charset="utf-8" />
  </head>
  <body>
    <%= content %>
  </body>
</html>
