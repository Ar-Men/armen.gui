#######
##                                           _
##   ___ _______ _  ___ ___       ___ ___ __(_)
##  / _ `/ __/  ' \/ -_) _ \  _  / _ `/ // / /
##  \_,_/_/ /_/_/_/\__/_//_/ (_) \_, /\_,_/_/
##                              /___/
##
####### Ecosystème basé sur les microservices ##################### (c) 2018 losyme ####### @(°_°)@

package Utopie::API::Ajax::Services::Registered;

#md_# Utopie::API::Ajax::Services::Registered
#md_

use Exclus::Exclus;
use HTML::Entities qw(encode_entities);
use Moo::Role;

#md_## Les méthodes
#md_

#md_### _sort()
#md_
sub _sort {
    $a->{name} cmp $b->{name} || $a->{dc} cmp $b->{dc} || $a->{node} cmp $b->{node} || $a->{port} <=> $b->{port};
}

#md_### _id_name()
#md_
sub _id_name {
    my ($self, $id_name) = @_;
    return <<HTML; ##...................................................................................................
<td class="monospace">
    $id_name
    <span class="icon has-text-danger pointer" ic-delete-from="/ajax/services/$id_name" ic-replace-target="true">
        <i class="far fa-stop-circle"></i>
    </span>
</td>
HTML
}

#md_### _status()
#md_
sub _status {
    state $_status = {
        running  => 'is-success',
        starting => 'is-primary',
        stopping => 'is-info'
    };
    my ($self, $status) = @_;
    my $class = exists $_status->{$status} ? $_status->{$status} : 'is-dark';
    return <<HTML; ##...................................................................................................
<td>
    <span class="tag $class">$status</span>
</td>
HTML
}

#md_### _heartbeat()
#md_
sub _heartbeat {
    my ($self, $time) = @_;
    my $html;
    my $heartbeat = $self->config->get_int('heartbeat');
    my $elapsed = time - $time;
    if ($elapsed <= $heartbeat) {
        $html = <<HTML; ##..............................................................................................
<td>$elapsed</td>
HTML
    }
    else {
        my $class = $elapsed > $heartbeat * 2 ? 'is-danger' : 'is-warning';
        $html = <<HTML; ##..............................................................................................
<td>
    <span class="tag $class">$elapsed</span>
</td>
HTML
    }
    return $html;
}

#md_### _uptime()
#md_
sub _uptime {
    my ($self, $time) = @_;
    my $data;
    my $uptime = time - $time;
       if ($uptime >= 86400) { $data = sprintf("%dj", int($uptime/86400)) }
    elsif ($uptime >=  3600) { $data = sprintf("%dh", int($uptime/ 3600)) }
    elsif ($uptime >=    60) { $data = sprintf("%dm", int($uptime/   60)) }
    else                     { $data = sprintf("%ds",           $uptime ) }
    return <<HTML; ##...................................................................................................
<td>$data</td>
HTML
}

#md_### _registered()
#md_
sub _registered {
    my ($self, $count, $service) = @_;
    my $id        = $self->_id_name(   $service->{id}       );
    my $name      = $self->_id_name(   $service->{name}     );
    my $status    = $self->_status(    $service->{status}   );
    my $heartbeat = $self->_heartbeat( $service->{heartbeat});
    my $uptime    = $self->_uptime(    $service->{timestamp});
    return <<HTML; ##...................................................................................................
<tr>
    <th>$count</th>
    $id
    $name
    $status
    <td>$service->{dc}</td>
    <td>$service->{node}</td>
    <td>$service->{port}</td>
    $heartbeat
    $uptime
    <td>$service->{pid}</td>
</tr>
HTML
}

#md_### _services_registered()
#md_
sub _services_registered {
    my ($self, $rr) = @_;
    my $html;
    my @services = $self->discovery->get_services;
    if (@services) {
        my $count = 1;
        my $tbody = '';
        foreach (sort _sort @services) { $tbody .= $self->_registered($count++, $_) };
        $html = <<HTML; ##..............................................................................................
<table class="table is-bordered is-striped is-narrow is-hoverable is-fullwidth">
    <thead>
        <tr>
            <th></th>
            <th>ID</th>
            <th>Name</th>
            <th>Status</th>
            <th>DC</th>
            <th>Node</th>
            <th>Port</th>
            <th>Heartbeat [s]</th>
            <th>Uptime</th>
            <th>PID</th>
        </tr>
    </thead>
    <tbody>$tbody</tbody>
</table>
<button class="button is-danger" ic-delete-from="/ajax/services" ic-replace-target="true">
    <span class="icon">
        <i class="far fa-stop-circle"></i>
    </span>
    <span>Stop</span>
</button>
HTML
    }
    else {
        my $message = encode_entities("Aucun µs n'est enregistré.");
        $html = <<HTML; ##..............................................................................................
<div class="notification is-info">
    $message
</div>
HTML
    }
    $rr->render($html);
}

#md_### _stop_services()
#md_
sub _stop_services {
    my ($self, $rr, $params) = @_;
    my $id_name = exists $params->{id_name} ? $params->{id_name} : undef;
    foreach ($self->discovery->get_services) {
        if ($id_name) {
            next if $id_name ne $_->{id} && $id_name ne $_->{name};
        }
        if ($_->{node} eq $self->node_name) {
            kill 'TERM', $_->{pid};
        }
        else {
            #TODO
        }
    }
    $rr->render('');
}

#md_### API_services_registered()
#md_
sub API_services_registered {
    my ($self) = @_;
    my $server = $self->server;
    $server->get(   '/ajax/services/registered', sub { $self->_services_registered(@_) });
    $server->delete('/ajax/services',            sub { $self->_stop_services(      @_) });
    $server->delete('/ajax/services/:id_name',   sub { $self->_stop_services(      @_) });
}

1;
__END__
