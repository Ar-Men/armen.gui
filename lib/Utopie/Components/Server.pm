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
use namespace::clean;

extends qw(Obscur::Components::Server::Plugin::Twiggy);

#md_## Les méthodes
#md_

#md_### build()
#md_
sub build {
    my ($self, $builder) = @_;
    $builder->mount('/' => Plack::App::File->new(root => $self->runner->dir->child('gui')->stringify)->to_app);
}

1;
__END__
