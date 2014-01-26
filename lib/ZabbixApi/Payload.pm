package ZabbixApi::Payload;

use strict;
use warnings;
use 5.012;

use Moo;
use JSON;

has method => ( is => 'ro', required => 1 );

has auth    => ( is => 'ro' );
has payload => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_create_skel;
}

sub add_params {
    my $self   = shift;
    my $params = shift;
    while ( my ( $key, $value ) = each %$params ) {
        $self->payload->{'params'}{$key} = $value;
    }
}

sub add_filter {
    my $self   = shift;
    my $params = shift;
    while ( my ( $key, $value ) = each %$params ) {
        $self->payload->{'params'}{'filter'}{$key} = $value;
    }
}

sub add_search {
    my $self   = shift;
    my $params = shift;
    while ( my ( $key, $value ) = each %$params ) {
        $self->payload->{'params'}{'search'}{$key} = $value;
    }
}

sub get_by_name {
    my $self    = shift;
    my $pattern = shift;
    $self->payload->{'params'}{'output'}         = 'extend';
    $self->payload->{'params'}{'select_hosts'}   = 'refer';
    $self->payload->{'params'}{'filter'}{'host'} = $pattern;
}

sub set_output {
    my $self   = shift;
    my $output = shift;
    if ( $output == 0 ) {
        $self->payload->{'params'}{'output'} = 'count';
    } elsif ( $output == 1 ) {
        $self->payload->{'params'}{'output'} = 'shorten';
    } elsif ( $output == 2 ) {
        $self->payload->{'params'}{'output'} = 'refer';
    } elsif ( $output == 3 ) {
        $self->payload->{'params'}{'output'} = 'extend';
    } else {
        die "wrong output level";
    }
}

sub _create_skel {
    my $self = shift;
    my $skel = {
        jsonrpc => '2.0',
        method  => $self->{method},
        params  => {},
        id      => '0',
    };
    if ( $self->auth ) {
        $$skel{'auth'} = $self->auth->{auth};
    }
    $self->payload($skel);
}

1;
