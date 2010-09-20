use Mojolicious::Lite;
use MojoX::Renderer::TT;
use utf8;

# app は Mojolicious::Lite extends Mojolicious
app->log->level('error');
app->types->type(html => 'text/html; charset=utf-8');
app->secret('My secret passhrase here!');

## MojoX::TT
my $tt = MojoX::Renderer::TT->build(
    mojo             => app,
    template_options => {
        UNICODE  => 1,
        ENCODING => 'UTF-8',

        ## plackup すると . が /usr/local/bin になってしまう => MOJO_HOME 設定しる
        ## MOJO_HOME=/Users/naoya/perl とか、だりー...

        # % MOJO_HOME=`pwd` plackup --reload --port 3000 ./mojo_tt.psgi
        # COMPILE_DIR  => "/Users/naoya/perl/tmp",
        # INCLUDE_PATH => "/Users/naoya/perl/templates",
    },
);

app->renderer->add_handler(tt => $tt);
# app->renderer->default_handler('tt');
# app->renderer->types->type('text/html');

get '/'    => 'index';
get '/foo' => sub { shift->render } => 'foo';

shagadelic;

__DATA__
@@ index.html.tt
<h1>Hello</h1>

<p>[%- h.url_for('index') %]</p>

@@ index.txt.tt
Hello, this is text file.
[%- template %]

@@ foo.txt.tt
oh my god!
