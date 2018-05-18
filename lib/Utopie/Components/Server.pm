#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::Components::Server;

#md_# Utopie::Components::Server
#md_

use Exclus::Exclus;
use Moo;
use Plack::App::File;
use Plack::Builder;
use Try::Tiny;
use namespace::clean;

extends qw(Obscur::Components::Server::Plugin::Twiggy);

#md_## Les méthodes
#md_

#md_### _html_response()
#md_
sub _html_response {
    my ($self, $rr, $cb, $params) = @_;
    $cb->($rr);
return;
}

#md_### _psgi_html()
#md_
sub _psgi_html {
    my ($self, $env) = @_;
    my $runner = $self->runner;
    my $rr = _Utopie::RequestResponse->new(runner => $runner, env => $env, debug => $self->debug);
    my $later;
    try {
        my ($cb, $params, $is_method_not_allowed, $allowed_methods) = $self->route_match($env);
        if ($cb) {
            $later = $self->_html_response($rr, $cb, $params);
        }
        elsif ($is_method_not_allowed || $allowed_methods) {
            $rr->render_405($allowed_methods);
        }
        else {
            $rr->render_404;
        }
    }
    catch {
        my $error = "$_";
        $self->logger->error($error);
        $rr->render_500(     $error);
    };
    return $later ? $later : $rr->finalize;
}

#md_### build()
#md_
sub build {
    my ($self, $builder) = @_;
    $builder->mount('/static' => Plack::App::File->new(root => $self->runner->dir->child('gui/static'))->to_app);
    my $builder_middleware = Plack::Builder->new;
    $builder_middleware->add_middleware('Plack::Middleware::ContentLength');
    $builder->mount('/' => $builder_middleware->wrap(sub { $self->_psgi_html(@_) }));
}


package _Utopie::RequestResponse; ######################################################################################

#md_# _RequestResponse
#md_

use Exclus::Exclus;
use HTML::Entities qw(encode_entities);
use Moo;
use Plack::Response;
use Try::Tiny;
use Types::Standard qw(Bool HashRef InstanceOf);
use namespace::clean;

extends qw(Obscur::Context);

#md_## Les attributs
#md_

#md_### env
#md_
has 'env' => (
    is => 'ro', isa => HashRef, required => 1
);

#md_### _response
#md_
has '_response' => (
    is => 'ro',
    isa => InstanceOf['Plack::Response'],
    lazy => 1,
    default => sub { Plack::Response->new(200, {'Content-Type' => 'text/html; charset=UTF-8'}) },
    init_arg => undef
);

#md_### _debug
#md_
has '_debug' => (
    is => 'ro', isa => Bool, required => 1, init_arg => 'debug'
);

#md_## Les méthodes
#md_

#md_### BUILD()
#md_
sub BUILD {
    my $self = shift;
    $self->logger->debug('Request', [%{$self->env}]) if $self->_debug;
}

#md_### render()
#md_
sub render {
    my ($self, $content, $status) = @_;
    my $response = $self->_response;
    $response->body($content);
    $response->status($status)
        if $status;
}

#md_### render_error()
#md_
sub render_error {
    my ($self, $status, $message) = @_;
    my $html;
    try {
        $html = $self->runner->get_template_path($status)->slurp;
        $html =~ s/\$message/$message/g;
    }
    catch {
        $html = "error $status ==>> $message";
    };
    $self->render($html, $status);
}

#md_### render_404()
#md_
sub render_404 {
    my ($self) = @_;
    $self->render_error(404, encode_entities(sprintf('Ressource non trouvée> %s', $self->env->{PATH_INFO})));
}

#md_### render_405()
#md_
sub render_405 {
    my ($self, $allowed_methods) = @_;
    my $message = sprintf(
        "Cette méthode n'est pas autorisée pour cette ressource> resource: %s, method: %s, allowed methods: [%s]",
        $self->env->{PATH_INFO},
        $self->env->{REQUEST_METHOD},
        join(',', @{$allowed_methods // []})
    );
    $self->render_error(405, encode_entities($message));
}

#md_### render_500()
#md_
sub render_500 { shift->render_error(500, encode_entities($_[0])) }

#md_### finalize()
#md_
sub finalize {
    return $_[0]->_response->finalize;
}

1;
__END__
