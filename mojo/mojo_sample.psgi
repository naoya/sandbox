#!perl
use Mojolicious::Lite;
use MojoX::Renderer::TT;
use utf8;

app->log->level('error');
app->types->type(html => 'text/html; charset=utf-8');

my $tt = MojoX::Renderer::TT->build(
    mojo             => app,
    template_options => {
        UNICODE  => 1,
        ENCODING => 'UTF-8',
    },
);
app->renderer->add_handler(tt => $tt);

get '/' => sub {
    my $self = shift;
    $self->render;
} => 'index';

get '/config' => 'config';

post '/config' => sub {
    my $self = shift;
    $self->flash(message => '保存しました');
    $self->redirect_to('config');
} => 'config';

shagadelic;

__DATA__
@@ wrapper.html.tt
<html>
<head><title>[% title | html %]</title>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" ></script>
<body>
[% content %]
</body>
</html>

@@ index.html.tt
[% WRAPPER wrapper.html.tt title="こんにちは" %]
<h1>Hello, Mojolicious</h1>
<p>こんにちは[% IF c.param('q') %][% c.param('q') | html %]さん[% END %]</p>

<form method="get" action="[% h.url_for %]">
  <input type="text" name="q" value="[% c.param('q') | html %]" />
  <input type="submit" value="送信" />
</form>

<h2>Helper and Controller</h2>
<ul>
  <li>h.url_for('index') : [% h.url_for('index') %]</li>
  <li>c.client...: [% c.client.get('http://www.yahoo.co.jp/').res.dom.at('title').text %]</li>
</ul>

<h2>See ALSO</h2>
<ul>
  <li>Mojolicious::Plugin::DefaultHelpers</li>
</ul>

<form method="post" action="[% h.url_for('config') %]">
  <input type="submit" value="設定" />
</form>
[% END %]

@@ config.html.tt
[% WRAPPER wrapper.html.tt title="設定ページ" %]
<h1>設定ですよ</h1>

[%- IF h.flash('message') %]
<p class="flash">[% h.flash('message') | html %]</p>
[%- END %]

<p>ここは設定</p>

[% END %]
