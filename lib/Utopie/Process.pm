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
use Text::Template;
use Types::Standard qw(InstanceOf Int Str);
use YAML::XS qw(LoadFile);
use Exclus::Exceptions;
use Exclus::Util qw(build_path root_path);
use Utopie::Components::Server;
use namespace::clean;

extends qw(Obscur::Runner::Process);
with map { "Utopie::API::Templates::$_" } qw(Services Workers);

#md_## Les attributs
#md_

###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###
has '+name'        => (default => sub { 'Utopie' });
has '+description' => (default => sub { "L'interface graphique de type web" });
has '+server'      => (default => sub {
    Utopie::Components::Server->new(runner => $_[0], cfg => {debug => $_[0]->config->get_bool('debug')})
});
###----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----###

#md_### port
#md_
has 'port' => (
    is => 'rw', isa => Int, lazy => 1, default => sub { 59997 }
);

#md_### _cv_stop
#md_
has '_cv_stop' => (
    is => 'ro', isa => InstanceOf['AnyEvent::CondVar'], default => sub { AE::cv }, init_arg => undef
);

#md_### _templates
#md_
has '_templates' => (
    is => 'ro',
    isa => Str,
    lazy => 1,
    default => sub { root_path(qw(armen.gui gui templates)) },
    init_arg => undef
);

#md_### version
#md_
has 'version' => (
    is => 'lazy', isa => Str, init_arg => undef
);

#md_## Les méthodes
#md_

#md_### _build_version()
#md_
sub _build_version {
    my $self = shift;
    my $data = LoadFile(root_path(qw(armen.gui Version.yaml)));
    return
        exists $data->{version} ? $data->{version} : '0.0.0';
}

#md_### set_config_default()
#md_
sub set_config_default {
    my ($self) = @_;
    my $config = $self->config;
    $config->set_default(heartbeat => 60); #TODO: une constante qqpart
}

#md_### _API()
#md_
sub _API { $_[0]->$_ foreach map { "API_$_" } qw(services workers) }

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

#md_### run()
#md_
sub run {
    my ($self) = @_;
    $self->info('Location', [node => $self->node_name, port => $self->port]);
    $self->_API;
    $self->info('READY.process', [description => $self->description]);
    $self->_start_loop;
}

#md_### get_template_path()
#md_
sub get_template_path { build_path($_[0]->_templates, $_[1].'.html') }

#md_### build_template()
#md_
sub build_template {
    state $_templates = {};
    my ($self, $template, $data) = @_;
    $data //= {};
    unless (exists $_templates->{$template}) {
        my $tt = Text::Template->new(
            DELIMITERS => ['[%', '%]'],
            SOURCE => $self->get_template_path($template)
        );
        unless ($tt) {
            EX->throw({ ##//////////////////////////////////////////////////////////////////////////////////////////////
                message => "Impossible de construire le template",
                params  => [template => $template, error => $Text::Template::ERROR]
            });
        }
        $_templates->{$template} = $tt;
    }
    my $html = $_templates->{$template}->fill_in(HASH => $data);
    return $html
        if $html;
    EX->throw({ ##//////////////////////////////////////////////////////////////////////////////////////////////////////
        message => "Impossible de remplir le template",
        params  => [template => $template, error => $Text::Template::ERROR, data => $data]
    });
}

1;
__END__
