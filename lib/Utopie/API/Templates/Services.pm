#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Templates::Services;

#md_# Utopie::API::Templates::Services
#md_

use Exclus::Exclus;
use Moo::Role;

with map { "Utopie::API::Ajax::Services::$_" } qw(Available Registered);

#md_## Les méthodes
#md_

requires qw(build_template);

#md_### _services()
#md_
sub _services {
    my ($self, $active, $rr) = @_;
    $rr->render(
        $self->build_template('main', {
            active  => 'S',
            title   => 'Les services',
            version => $self->version,
            content => $self->build_template('services', {
                active => $active,
                ajax   => $active eq 'A' ? 'available' : 'registered',
                poll   => $active eq 'A' ? '' : '1s'
            })
        })
    );
}

#md_### API_services()
#md_
sub API_services {
    my ($self) = @_;
    $self->$_ foreach map { "API_services_$_" } qw(available registered);
    my $server = $self->server;
    $server->get('/',                    sub { $self->_services('R', @_) });
    $server->get('/services',            sub { $self->_services('R', @_) });
    $server->get('/services/available',  sub { $self->_services('A', @_) });
    $server->get('/services/registered', sub { $self->_services('R', @_) });
}

1;
__END__
