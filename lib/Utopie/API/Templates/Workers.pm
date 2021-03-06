#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Templates::Workers;

#md_# Utopie::API::Templates::Workers
#md_

use Exclus::Exclus;
use Moo::Role;

with map { "Utopie::API::Ajax::Workers::$_" } qw(Default);

#md_## Les méthodes
#md_

requires qw(build_template);

#md_### _workers()
#md_
sub _workers {
    my ($self, $rr) = @_;
    $rr->render(
        $self->build_template('main', {
            active  => 'W',
            title   => 'Les workers',
            version => $self->version,
            content => $self->build_template('workers')
        })
    );
}

#md_### API_workers()
#md_
sub API_workers {
    my ($self) = @_;
    $self->$_ foreach map { "API_workers_$_" } qw(default);
    my $server = $self->server;
    $server->get('/workers', sub { $self->_workers(@_) });
}

1;
__END__
