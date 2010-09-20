## See Also: Mojo::Client, Mojo::DOM
use Mojolicious::Lite;

app->log->level('error');

get '/' => sub {
    my $self = shift;
    my $url = $self->param('url') or die "missing URL";
    $self->render(
        text => $self->client->get($url)->res->dom->at('title')->text
    );
};

shagadelic;
