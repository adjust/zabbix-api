package ZabbixApi::Request;

use strict;
use warnings;
use 5.012;

use Moo;
use LWP::UserAgent;
use JSON;

has url        => ( is => 'ro', required => 1 );
has payload    => ( is => 'ro', required => 1 );
has invalidssl => ( is => 'ro', required => 0 );
has ua         => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->ua( $self->_create_user_agent ) unless $self->ua;
}

sub process {
    my $self = shift;
    my $resp = $self->ua->request( $self->_create_request );
    if ( $resp->is_success ) {
        my $result = decode_json( $resp->decoded_content );
        die $resp->decoded_content if $$result{'error'};
        return $result->{'result'};
    } else {
        die $resp->status_line;
    }
}

sub _create_request {
    my $self = shift;
    my $req = HTTP::Request->new( POST => ( $self->{url} ) );
    $req->content( encode_json( $self->payload ) );
    $req->content_type('application/json-rpc');
    return $req;
}

sub _create_user_agent {
    my $self = shift;
    my $ua   = LWP::UserAgent->new;
    if ( $self->{invalidssl} ) {
        $ua->ssl_opts(verify_hostname => 0);
    }
    $ua->timeout(10);
    return $ua;
}

1;
