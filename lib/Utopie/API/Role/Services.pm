#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Role::Services;

#md_# Utopie::API::Role::Services
#md_

use Exclus::Exclus;
use Moo::Role;

#md_## Les méthodes
#md_

requires qw(build_template);

#md_### _get_services()
#md_
sub _get_services {
    my ($self, $rr) = @_;
    state $_template = $self->build_template('root');
    $rr->render(
        $_template->fill_in(
            HASH => {
                title   => 'Les services',
                menu    => 'S',
                version => $self->version
            }
        )
    );
}

#md_### API_services()
#md_
sub API_services {
    my ($self) = @_;
    my $server = $self->server;
    $server->get('/',         sub { $self->_get_services(@_) });
    $server->get('/services', sub { $self->_get_services(@_) });
}

1;
__END__
