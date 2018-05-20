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
use HTML::Entities qw(encode_entities);
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
                data   => $active eq 'A' ? 'available' : 'registered',
                poll   => $active eq 'A' ? '' : '2s'
            })
        })
    );
}

#md_### _disabled()
#md_
sub _disabled {
    my ($self, $service) = @_;
    return $service->get_bool({default => 0}, 'disabled')
        ? '<td><span class="tag is-danger">true</span></td>'
        : '<td><span class="tag is-primary">false</span></td>';
}

#md_### _port()
#md_
sub _port {
    my ($self, $service) = @_;
    my $port = $service->maybe_get_int('port');
    return $port
        ? "<td><span class=\"tag is-info\">$port</span></td>"
        : '<td><span class="tag is-primary">#</span></td>';
}

#md_### _deploy()
#md_
sub _deploy {
    my ($self, $service) = @_;
    my $deploy = $service->create({default => {}}, 'deploy');
    my $html = '<td><div class="field is-grouped is-grouped-multiline">';
    foreach (qw(overall dc node)) {
        $html .= "<div class=\"control\"><div class=\"tags has-addons\"><span class=\"tag is-dark\">$_</span>";
        my $count = $deploy->maybe_get_int($_);
        $html .= $count
            ? "<span class=\"tag is-info\">$count</span>"
            : '<span class="tag is-primary">#</span>';
        $html .= '</div></div>';
    }
    $html .= '</div></td>';
    return $html;
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
        $services->foreach_key(
            {create => 1, sort => 1},
            sub {
                my ($name, $service) = @_;
                $tbody .= '<tr>';
                $tbody .= "<th>$count</th><td class=\"monospace\">$name</td>";
                $tbody .= $self->_disabled($service);
                $tbody .= $self->_port($service);
                $tbody .= $self->_deploy($service);
                $tbody .= '</tr>';
                $count++;
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
        my $message = encode_entities("Aucun µs n'a été déclaré.");
        $html = <<END;
<div class="notification is-warning">
    $message
</div>
END
    }
    $rr->render($html);
}

#md_### _sort()
#md_
sub _sort {
    $a->{name} cmp $b->{name} || $a->{dc} cmp $b->{dc} || $a->{node} cmp $b->{node} || $a->{port} <=> $b->{port};
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
    my $color = exists $_status->{$status}
        ? $_status->{$status}
        : 'is-dark';
    return "<td><span class=\"tag $color\">$status</span></td>";
}

#md_### _heartbeat()
#md_
sub _heartbeat {
    my ($self, $time) = @_;
    my $heartbeat = $self->config->get_int('heartbeat');
    my $elapsed = time - $_->{heartbeat};
    return "<td>$elapsed</td>"
        if $elapsed <= $heartbeat;
    return "<td><span class=\"tag is-danger\">$elapsed</span></td>"
        if $elapsed >= 2*$heartbeat;
    return "<td><span class=\"tag is-warning\">$elapsed</span></td>";
}

#md_### _uptime()
#md_
sub _uptime {
    my ($self, $time) = @_;
    my $uptime = time - $time;
    return sprintf("<td>%3d (d)</td>", int($uptime/86400))
        if $uptime >= 86400;
    return sprintf("<td>%3d (h)</td>", int($uptime/3600))
        if $uptime >= 3600;
    return sprintf("<td>%3d (m)</td>", int($uptime/60))
        if $uptime >= 60;
    return sprintf("<td>%3d (s)</td>", $uptime);
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
        foreach (sort _sort @services) {
            $tbody .= '<tr>';
            $tbody .= "<th>$count</th><td class=\"monospace\">$_->{id}</td><td class=\"monospace\">$_->{name}</td>";
            $tbody .= $self->_status($_->{status});
            $tbody .= "<td>$_->{dc}</td><td>$_->{node}</td><td>$_->{port}</td>";
            $tbody .= $self->_heartbeat($_->{heartbeat});
            $tbody .= $self->_uptime($_->{timestamp});
            $tbody .= "<td>$_->{pid}</td>";
            $tbody .= '</tr>';
            $count++;
        }
        $html = <<END;
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
            <th>Heartbeat (s)</th>
            <th>Uptime</th>
            <th>PID</th>
        </tr>
    </thead>
    <tbody>$tbody</tbody>
</table>
END
    }
    else {
        my $message = encode_entities("Aucun µs n'est enregistré.");
        $html = <<END;
<div class="notification is-info">
    $message
</div>
END
    }
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
