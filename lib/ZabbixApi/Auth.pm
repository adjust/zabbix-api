package ZabbixApi::Auth;

use strict;
use warnings;
use 5.012;

use Moo;

use ZabbixApi::Request;
use ZabbixApi::Payload;

has auth => ( is => 'rw' );

has user => ( is => 'ro', required => 1 );
has pw   => ( is => 'ro', required => 1 );
has url  => ( is => 'ro', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_login;
}

sub auth {
    my $self = shift;
    return $self->{auth};
}

sub _create_payload {
    my $self    = shift;
    my $payload = ZabbixApi::Payload->new(
        method => "user.authenticate",
    );
    $payload->add_params(
        {
            user     => $self->{user},
            password => $self->{pw},
        }
    );
    return $payload->payload;
}

sub _login {
    my $self     = shift;
    my $response = ZabbixApi::Request->new(
        url     => $self->url,
        payload => $self->_create_payload,
    );
    $self->auth( $response->process() );
}

1;
