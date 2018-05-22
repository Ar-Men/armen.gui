#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Ajax::Services::Available;

#md_# Utopie::API::Ajax::Services::Available
#md_

use Exclus::Exclus;
use HTML::Entities qw(encode_entities);
use Moo::Role;

#md_## Les méthodes
#md_

#md_### _disabled()
#md_
sub _disabled {
    my ($self, $service) = @_;
    my ($class, $data) = $service->get_bool({default => 0}, 'disabled')
        ? ('is-danger',   'true')
        : ('is-primary', 'false');
    return <<HTML; ##...................................................................................................
<td>
    <span class="tag $class">$data</span>
</td>
HTML
}

#md_### _port()
#md_
sub _port {
    my ($self, $service) = @_;
    my $port = $service->maybe_get_int('port');
    my ($class, $data) = $port ? ('is-info', $port) : ('is-primary', '#');
    return <<HTML; ##...................................................................................................
<td>
    <span class="tag $class">$data</span>
</td>
HTML
}

#md_### _deploy_value()
#md_
sub _deploy_value {
    my ($self, $deploy, $value) = @_;
    my $count = $deploy->maybe_get_int($value);
    my ($class, $data) = $count ? ('is-info', $count) : ('is-primary', '#');
    return <<HTML; ##...................................................................................................
<div class="control">
    <div class="tags has-addons">
        <span class="tag is-dark">$value</span>
        <span class="tag $class">$data</span>
    </div>
</div>
HTML
}

#md_### _deploy()
#md_
sub _deploy {
    my ($self, $service) = @_;
    my $deploy = $service->create({default => {}}, 'deploy');
    my $overall = $self->_deploy_value($deploy, 'overall');
    my $dc      = $self->_deploy_value($deploy,      'dc');
    my $node    = $self->_deploy_value($deploy,    'node');
    return <<HTML; ##...................................................................................................
<td>
    <div class="field is-grouped is-grouped-multiline">
        $overall$dc$node
    </div>
</td>
HTML
}

#md_### _available()
#md_
sub _available {
    my ($self, $count, $name, $service) = @_;
    my $disabled = $self->_disabled($service);
    my $port     = $self->_port(    $service);
    my $deploy   = $self->_deploy(  $service);
    return <<HTML; ##...................................................................................................
<tr>
    <th>$count</th>
    <td class="monospace">$name</td>
    $disabled
    $port
    $deploy
</tr>
HTML
}

#md_### _services_available()
#md_
sub _services_available {
    my ($self, $rr) = @_;
    my $html;
    my $services = $self->config->create({default => {}}, 'services');
    if ($services->count_keys) {
        my $count = 1;
        my $tbody = '';
        $services->foreach_key({create => 1, sort => 1}, sub { $tbody .= $self->_available($count++, @_) });
        $html = <<HTML; ##..............................................................................................
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
HTML
    }
    else {
        my $message = encode_entities("Aucun µs n'a été déclaré.");
        $html = <<HTML; ##..............................................................................................
<div class="notification is-warning">
    $message
</div>
HTML
    }
    $rr->render($html);
}

#md_### API_services_available()
#md_
sub API_services_available {
    my ($self) = @_;
    my $server = $self->server;
    $server->get('/ajax/services/available', sub { $self->_services_available( @_) });
}

1;
__END__
