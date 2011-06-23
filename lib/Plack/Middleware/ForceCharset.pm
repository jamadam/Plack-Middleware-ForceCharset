package Plack::Middleware::ForceCharset;

use strict;
use warnings;
use 5.008_001;

use parent qw(Plack::Middleware);
use Plack::Util;
use Plack::Util::Accessor qw(charset);
use Encode;

our $VERSION = '0.01';

sub call {
    my ($self, $env) = @_;
    $self->response_cb($self->app->($env), sub {
		my $res = shift;
        my $h = Plack::Util::headers($res->[1]);
		my $charset_from = 'UTF-8';
		my $charset_to = $self->charset;
        my $ct = $h->get('Content-Type');
		if ($ct =~ s{;?\s*charset=([^;\$]+)}{}) {
			$charset_from = $1;
		}
		if ($ct =~ qr{^text/(html|plain)}) {
			$h->set('Content-Type', $ct. ';charset='. $charset_to);
		}
		my $fixed_body = [];
		Plack::Util::foreach($res->[2], sub {
			Encode::from_to($_[0], $charset_from, $charset_to);
			push @$fixed_body, $_[0];
		});
		$res->[2] = $fixed_body;
		$h->set('Content-Length', length $fixed_body);
	});
}

1;
__END__

=head1 NAME

Plack::Middleware::ForceCharset

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 call

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
