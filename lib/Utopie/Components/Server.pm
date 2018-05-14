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
        if (my $match = $self->route_match($env)) {
            $later = $self->_html_response($rr, @$match);
        }
        elsif (defined $match) {
            $rr->render_405;
        }
        else {
            $rr->render_404;
        }
    }
    catch {
        $self->logger->error("$_");
        $rr->render_500("$_");
    };
    return $later ? $later : $rr->finalize;
}

#md_### build()
#md_
sub build {
    my ($self, $builder) = @_;
    $builder->mount('/static' => Plack::App::File->new(root => $self->runner->dir->child('gui/static'))->to_app);
    $builder->mount('/'       => sub { $self->_psgi_html(@_) });
}

package _Utopie::RequestResponse; ######################################################################################

#md_# _RequestResponse
#md_

use Exclus::Exclus;
use Moo;
use Plack::Response;
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
    if ($self->_debug) {
        $self->logger->debug(
            'Request',
            [server => $self->env->{REMOTE_ADDR}, resource => $self->env->{PATH_INFO}]
        );
    }
}

#md_### render()
#md_
sub render {
    my ($self, $content, $status) = @_;
    my $response = $self->_response;
    $response->body($content);
    $response->content_length(length($content));
    $response->status($status)
        if $status;
}

#md_### render_404()
#md_
sub render_404 {
    my ($self) = @_;
    $self->render('404', 404); #TODO
}

#md_### render_405()
#md_
sub render_405 {
    my ($self) = @_;
    $self->render('405', 405); #TODO
}

#md_### render_500()
#md_
sub render_500 {
    my ($self) = @_;
    $self->render('500', 500); #TODO
}

#md_### finalize()
#md_
sub finalize {
    return $_[0]->_response->finalize;
}

1;
__END__
