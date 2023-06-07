package Web::Request::Role::AbsoluteUriFor;

# ABSTRACT: Construct an absolute URI honoring script_name

# VERSION

use 5.010;
use Moose::Role;
use Plack::Response;

sub absolute_uri_for {
    my ( $self, $uri_for, $base_uri ) = @_;

    my $url;
    if ( ref($uri_for) eq 'HASH' ) {
        $url = $self->uri_for($uri_for);
    }
    else {
        $url = $uri_for;
    }

    my $script_name = $self->script_name || '';
    $base_uri ||= $self->base_uri;

    $base_uri=~s{/+$}{};
    $script_name=~s{/+$}{};
    $script_name=~s{^/+}{};
    $base_uri=~s{/*$script_name/*$}{}g;
    $url=~s{^/}{};
    $url=~s{^/*$script_name/*}{};

    return join( '/', grep {$_ } $base_uri, $script_name, $url );
}

1;

=head1 SYNOPSIS

  # Create a request handler
  package My::App::Request;
  use Moose;
  extends 'Web::Request';
  with 'Web::Request::Role::AbsoluteUriFor';

  # Make sure your app uses your request handler, e.g. using OX:
  package My::App::OX;
  sub request_class {'My::App::Request'}

  # in some controller action:

  # redirect
  $req->absolute_uri_for({ controller=>'foo', action=>'bar' });
  # https://yoursite.com/mountpoint/foo/bar

  # don't use the base-uri from $req by passing an explit additional value
  $req->absolute_uri_for({ controller=>'foo', action=>'bar' }, 'https://example.com');
  # https://example.com/mountpoint/foo/bar


=head1 DESCRIPTION

C<Web::Request::Role::AbsoluteUriFor> provides a method to calculate the absolute URI of a given controller/action, including the host name and handling various issues with C<SCRIPTNAME> and reverse proxies.

=head2 METHODS

=head3 absolute_uri_for

    $req->absolute_uri_for( '/some/path' );
    $req->absolute_uri_for( $ref_uri_for );
    $req->absolute_uri_for( '/some/path', $base-url );

Construct an absolute URI out of C<base_uri>, C<script_name> and the
passed in string. You can also pass a ref, which will be resolved by
calling C<uri_for> on the request object.

If you pass a second argument, this value will be used as the base-uri
instead of extracting it from the request. This can make sense when
you for exampel host a white lable service and need to generate
different links based on some value inside your app.

=head1 THANKS

Thanks to

=over

=item *

L<validad.com|https://www.validad.com/> for supporting Open Source.

=back

