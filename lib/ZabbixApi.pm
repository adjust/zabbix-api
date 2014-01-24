package ZabbixApi;

use strict;
use warnings;
use 5.012;

use Moo;

use ZabbixApi::Request;
use ZabbixApi::Auth;

our $VERSION = '0.01';

has user => ( is => 'ro', required => 1 );
has pw   => ( is => 'ro', required => 1 );
has url  => ( is => 'ro', required => 1 );

has auth     => ( is => 'rw' );
has payload  => ( is => 'rw' );
has lastresp => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_auth;
}

sub set_method {
    my $self   = shift;
    my $method = shift;
    $self->payload( ZabbixApi::Payload->new(
            method => $method,
            auth   => $self->auth,
          )
    );
}

sub process {
    my $self = shift;
    my $r    = ZabbixApi::Request->new(
        url     => $self->{url},
        payload => $self->payload->payload,
    )->process;
    $self->lastresp($r);
}

sub clear {
    my $self = shift;
    $self->payload(undef);
}

sub find_by {
    my $self = shift;
    my $key  = shift;
    my $val  = shift;
    for my $entry ( @{ $self->lastresp } ) {
        if ( $$entry{$key} ~~ $val ) {
            return $entry;
        }
    }
}

sub find_like {
    my $self   = shift;
    my $key    = shift;
    my $val    = shift;
    my $result = [];
    for my $entry ( @{ $self->lastresp } ) {
        if ( $$entry{$key} =~ /$val/ ) {
            push( @$result, $entry );
        }
    }
    return $result;
}

sub _auth {
    my $self = shift;
    my $auth = ZabbixApi::Auth->new(
        user => $self->{user},
        pw   => $self->{pw},
        url  => $self->{url},
    );
    $self->auth($auth);
}

1;
