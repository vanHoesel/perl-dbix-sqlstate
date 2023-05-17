package DBIx::SQLstate;

use strict;
use warnings;

our $VERSION = 'v0.0.1';

use Exporter qw/import/;

our @EXPORT = (
    'sqlstate_message',
    'sqlstate_token',
    'sqlstate_class_message',
    'sqlstate_class_token',
);

my %SQLstate = sqlstate_known_codes();
my %SQLclass = sqlstate_class_codes();

=head2 C<sqlstate_message>

Returns a human readable message for a given C<SQLSTATE>

=cut

sub sqlstate_message ($) { $SQLstate{$_[0]} }

sub sqlstate_token ($) { tokenize( sqlstate_message(shift) ) }

sub sqlstate_class { substr($_[0],0,2) }

sub sqlstate_class_message ($) { $SQLclass{sqlstate_class($_[0])} }

sub sqlstate_class_token ($) { tokenize( sqlstate_class_message(shift) ) }



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



sub tokenize ($) {
	my $text = shift;

	# remove rubish first
	$text =~ s/,/ /ig;
	$text =~ s/-/ /ig;
	$text =~ s/_/ /ig;
	$text =~ s/\//_/ig;
	
	# create special cases
	$text =~ s/sql /sql_/ig;
	$text =~ s/xml /xml_/ig;
	$text =~ s/cli /cli_/ig;
	$text =~ s/fdw /cli_/ig;
	$text =~ s/null /null_/ig;
	
	
	$text = join qq(_), map { lc } split /_/, $text;
	$text = join qq(), map { ucfirst(lc($_)) } grep { $_ ne 'a' and $_ ne 'an' and $_ ne 'the' } split /\s+/, $text;
	
	# fix special cases
	$text =~ s/sql_/SQL/ig;
	$text =~ s/xml_/XML/ig;
	$text =~ s/cli_/CLI/ig;
	$text =~ s/fdw_/FDW/ig;
	$text =~ s/null_/NULL/ig;
	$text =~ s/xquery/XQuery/ig;

	return $text;
}



1;

__END__
