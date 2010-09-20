#!/usr/bin/env perl
# documents
# - http://wiki.livedoor.jp/mojolicious/d/Mojolicious::Lite
# - http://search.cpan.org/~kraih/Mojolicious-0.999929/lib/Mojo/Template.pm
# - http://search.cpan.org/~kraih/Mojolicious-0.999929/lib/Mojolicious/Controller.pm
# - MojoX::Renderer
use Mojolicious::Lite;
use MojoX::Renderer::TT;

use utf8;

app->log->level('error');
app->types->type(html => 'text/html; charset=utf-8');
app->secret('My secret passhrase here!');

## MojoX::TT
# my $tt = MojoX::Renderer::TT->build(
#     mojo             => app,
#     template_options => {
#         UNICODE  => 1,
#         ENCODING => 'UTF-8',
#     },
# );

# app->renderer->add_handler(tt => $tt);
# app->renderer->default_handler('tt');
# app->renderer->types->type('text/html');

ladder sub {
    my $self = shift;
    if ($self->param('name') eq 'espo') {
        $self->render('denied');
        return;
    } else {
        return 1;
    }
};

get '/' => sub {
    my $self = shift;
    if (not $self->session('name')) {
        return $self->redirect_to('login');
    }
    $self->render;
} => 'index';

get '/login' => sub {
    my $self = shift;
    my $name = $self->param('name');
    my $pass = $self->param('pass');

    if ($name eq 'naoya' and $pass eq '1234') {
        $self->session(name => $name);
        $self->flash(message => 'Thanks for logging in!');
        $self->redirect_to('index');
    } else {
        return $self->render;
    }
} => 'login';

get '/logout' => sub {
    my $self = shift;
    $self->session(expires => 1);
    $self->redirect_to('index');
} => 'logout';

# shagadelic;

my $app = shagadelic;
use Plack::Builder;

builder {
    enable 'Plack::Middleware::XFramework',
        framework => "Mojolicious::Lite";

    # static files are served from like './htdocs/css/mojo.css'
    enable 'Plack::Middleware::Static',
        path => qr{^/(images|js|css)/}, root => "./htdocs/";
    $app;
};

__DATA__
@@ layouts/default.html.ep
<!doctype html>
<html>
  <head><title>Mojolicious rocks!</title></head>
  <link rel="stylesheet" href="/css/mojo.css" type="text/css" />
  <!-- <link rel="stylesheet" href="mojo.css" type="text/css" /> -->
  <body>
    <%= content %>
  </body>
</html>

@@ index.html.ep
% layout 'default';
<% if (my $message = flash 'message') { %>
  <b><%= $message %></b><br />
<% } %>

<p>Welcome <%= session 'name' %>!<br /></p>

<ul>
  <li><a href="<%= url_for 'logout' %>">Logout</a></li>
</ul>

@@ login.html.ep
% layout 'default';
<form action="<%= url_for %>">
  <% if (param 'name') { %>
     <b>Wrong name or password, please try again.</b><br />
  <% } %>
  Name: <br />
  <input type="text" name="name" value="<%= param 'name' %>" /><br />
  <input type="password" name="pass" value="<%= param 'password' %>" /><br />
  <input type="submit" value="Login" />
</form>

@@ denied.html.ep
% layout 'default';
<h1>Permission denied...!</h1>
