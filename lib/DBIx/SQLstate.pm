package DBIx::SQLstate;

use strict;
use warnings;

our $VERSION = 'v0.0.1';

use Exporter qw/import/;

our @EXPORT = (
    'sqlstate_message',
    'sqlstate_class_message',
);

my %SQLstate = sqlstate_known_codes();
my %SQLclass = sqlstate_class_codes();

=head2 C<sqlstate_message>

Returns a human readable message for a given C<SQLSTATE>

=cut

sub sqlstate_message ($) { $SQLstate{$_[0]} }

sub sqlstate_class { substr($_[0],0,2) }

sub sqlstate_class_message ($) { $SQLclass{sqlstate_class($_[0])} }



sub sqlstate_known_codes {
    use DBIx::SQLstate::wikipedia;
    
    my %sqlstate_codes = (
        %SQLstate,
        %DBIx::SQLstate::wikipedia::SQLstate,
    );
    
    return %sqlstate_codes;
}



sub sqlstate_class_codes {
    my %sqlclass_codes = map {
        sqlstate_class($_) => sqlstate_message($_)
    } grep { /..000/ } keys %SQLstate;
    
    return %sqlclass_codes;
}



1;

__END__
