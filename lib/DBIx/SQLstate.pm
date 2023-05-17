package DBIx::SQLstate;

use strict;
use warnings;

our $VERSION = 'v0.0.1';

use Exporter qw/import/;

our @EXPORT = qw/sqlstate_message/;

my %SQLstate = (
    # will be loaded below
);

use DBIx::SQLstate::wikipedia;

%SQLstate = (
	%SQLstate,
	%DBIx::SQLstate::wikipedia::SQLstate,
);

=head2 C<sqlstate_message>

Returns a human readable message for a given C<SQLSTATE>

=cut

sub sqlstate_message ($) { $SQLstate{$_[0]} }

1;

__END__
