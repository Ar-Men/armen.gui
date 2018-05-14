#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Role::Workers;

#md_# Utopie::API::Role::Workers
#md_

use Exclus::Exclus;
use Moo::Role;

#md_## Les méthodes
#md_

requires qw(build_template);

#md_### _get_workers()
#md_
sub _get_workers {
    my ($self, $rr) = @_;
    state $_template = $self->build_template('root');
    $rr->render(
        $_template->fill_in(
            HASH => {
                title   => 'Les workers',
                menu    => 'W',
                version => $self->version
            }
        )
    );
}

#md_### API_workers()
#md_
sub API_workers {
    my ($self) = @_;
    my $server = $self->server;
    $server->get('/workers', sub { $self->_get_workers(@_) });
}

1;
__END__
