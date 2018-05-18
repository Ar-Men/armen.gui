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
                data   => $active eq 'A' ? 'available' : 'registered'
            })
        })
    );
}

#md_### _deploy()
#md_
sub _deploy {
    my ($self, $service) = @_;
    my $deploy = $service->create({default => {}}, 'deploy');
    my @deploy;
    foreach (qw(overall dc node)) {
        my $value = $deploy->maybe_get_int($_);
        push @deploy, sprintf("%s: %s", $_, defined $value ? $value : '#');
    }
    return join(', ', @deploy);
}

#md_### _services_available()
#md_
sub _services_available {
    my ($self, $rr) = @_;
    my $services = $self->config->create({default => {}}, 'services');
    my $html;
    if ($services->count_keys) {
        my $count = 0;
        my $tbody = '';
        $services->foreach_key(
            {create => 1, sort => 1},
            sub {
                my ($name, $service) = @_;
                $tbody .= sprintf(
                    "<tr><th>%d</th><td>$name</td><td>%s</td><td>%d</td><td>%s</td></tr>",
                    ++$count,
                    $service->get_bool({default => 0}, 'disabled') ? 'true' : 'false',
                    $service->maybe_get_int('port'),
                    $self->_deploy($service)
                );
            }
        );
    $html = <<END;
<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
    <thead>
        <tr>
            <th></th>
            <th>Name</th>
            <th>Disabled</th>
            <th>Port</th>
            <th>Deploy</th>
        </tr>
    </thead>
    <tbody>$tbody</tbody>
</table>
END
    }
    else {
        $html = "<p>Aucun µs n'a été déclaré.</p>";
    }
    $rr->render($html);
}

#md_### _services_registered()
#md_
sub _services_registered {
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
    $server->get('/',                         sub { $self->_services(      'R', @_) });
    $server->get('/services',                 sub { $self->_services(      'R', @_) });
    $server->get('/services/available',       sub { $self->_services(      'A', @_) });
    $server->get('/services/registered',      sub { $self->_services(      'R', @_) });
    $server->get('/data/services/available',  sub { $self->_services_available( @_) });
    $server->get('/data/services/registered', sub { $self->_services_registered(@_) });
}

1;
__END__
