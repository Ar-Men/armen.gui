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
    $rr->render(
        $self->build_template('main', {
            menu    => 'S',
            title   => 'Les services',
            version => $self->version,
            content => $self->build_template('services')
        })
    );
}

#md_### _get_data_services()
#md_
sub _get_data_services {
    my ($self, $rr) = @_;
    my $html = <<END;
<form id="checked-contacts">
  <table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
    <thead>
    <tr>
      <th></th>
      <th>Name</th>
      <th>Email</th>
      <th>Status</th>
    </tr>
    </thead>
    <tbody id="contactTableBody">
    <tr>
      <td><input name="ids" value="0" type="checkbox"></td><td>Joe Smith</td><td>joe\@smith.org</td><td>Active</td>
    </tr>
    <tr>
      <td><input name="ids" value="1" type="checkbox"></td><td>Angie MacDowell</td><td>angie\@macdowell.org</td><td>Active</td>
    </tr>
    <tr>
      <td><input name="ids" value="2" type="checkbox"></td><td>Fuqua Tarkenton</td><td>fuqua\@tarkenton.org</td><td>Active</td>
    </tr>
    <tr>
      <td><input name="ids" value="3" type="checkbox"></td><td>Kim Yee</td><td>kim\@yee.org</td><td>Inactive</td>
    </tr>
    </tbody>
  </table>
</form>
END
    $rr->render($html);
}

#md_### API_services()
#md_
sub API_services {
    my ($self) = @_;
    my $server = $self->server;
    $server->get('/',              sub { $self->_get_services(     @_) });
    $server->get('/services',      sub { $self->_get_services(     @_) });
    $server->get('/data/services', sub { $self->_get_data_services(@_) });

}

1;
__END__
