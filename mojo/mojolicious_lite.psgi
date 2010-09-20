#!/usr/bin/env perl
# http://wiki.livedoor.jp/mojolicious/d/Mojolicious::Lite
use Mojolicious::Lite;
use utf8;

app->log->level('error');
app->types->type(html => 'text/html; charset=utf-8');

get '/' => sub {
    shift->render_text('Hello, World');
};

get '/index' => 'index';

get '/foo' => 'foo';

get '/blog/:name' => sub {
    my $self = shift;

    $self->render(
        template => 'blog',
        foobar   => 'foobar',
    );
};

get '/agent' => (agent => qr/Firefox/) => sub {
    shift->render_text('yay!');
};

get '/login' => sub {
    my $self = shift;
    my $name = $self->param('name');
    my $pass = $self->param('password');
};

shagadelic;

__DATA__
@@ foo.html.ep
this is foo.
<p>url_for 'foo' = <%= url_for 'foo' =%></p>
<p>url_for 'index' = <%= url_for 'index' =%></p>

@@ blog.html.ep
<h1>blog</h1>
<p>welocome, <%= $name =%></p>
<p>template variables: <%= $foobar =%></p>

@@ blog.txt.ep
blog

welcome, <%= $name =%>
