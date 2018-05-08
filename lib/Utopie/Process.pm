#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::Process;

#md_# Utopie::Process
#md_

use Exclus::Exclus;
use EV;
use AnyEvent;
use Moo;
use Types::Standard qw(InstanceOf Int);
use Utopie::Components::Server;
use namespace::clean;

extends qw(Obscur::Runner::Process);

#md_## Les attributs
#md_

###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###
has '+name'        => (default => sub { 'Utopie' });
has '+description' => (default => sub { "L'interface graphique de type web" });
has '+server'      => (default => sub { Utopie::Components::Server->new(runner => $_[0], cfg => {}) });
###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###

#md_### port
#md_
has 'port' => (
    is => 'rw', isa => Int, lazy => 1, default => sub { 59998 }
);

#md_### _cv_stop
#md_
has '_cv_stop' => (
    is => 'ro', isa => InstanceOf['AnyEvent::CondVar'], default => sub { AE::cv }, init_arg => undef
);

#md_## Les méthodes
#md_

#md_### _stop_loop()
#md_
sub _stop_loop { $_[0]->_cv_stop->send }

#md_### _start_loop()
#md_
sub _start_loop {
    my ($self) = @_;
    my @watchers = (
        AE::signal('QUIT', sub { $self->_stop_loop }),
        AE::signal('TERM', sub { $self->_stop_loop })
    );
    $self->_cv_stop->recv;
}

#md_### _get_status()
#md_
sub _get_status {
    my ($self, $respond, $rr) = @_;
    $rr->payload({
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        node        => $self->node_name
    });
    $respond->($rr->auto_render->finalize);
}

#md_### _API()
#md_
sub _API {
    my ($self) = @_;
    $self->server->get('/v:version/status', sub { $self->_get_status(@_) });
}

#md_### run()
#md_
sub run {
    my ($self) = @_;
    $self->info('Location', [node => $self->node_name, port => $self->port]);
    $self->_API;
    $self->info('READY.process', [description => $self->description]);
    $self->_start_loop;
}

1;
__END__
