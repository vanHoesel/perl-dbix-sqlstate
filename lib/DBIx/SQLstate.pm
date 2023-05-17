package DBIx::SQLstate;



=head1 NAME

DBIx::SQLstate - message lookup and tokenization of errors

=head1 SYNOPSIS

    use DBI;
    use DBIx::SQLstate;
    
    my $dbh = DBI->connect($data_source, $username, $password,
        {
            HandleError => sub {
                my $msg = shift;
                my $h   = shift;
                
                my $state = $h->state;
                
                my $message = sprintf("%s - %s",
                    $state,
                    sqlstate_token($state)
                    ||
                    sqlstate_class_token($state)
                    ||
                    sqlstate_default_token()
                );
                
                die $message;
            }
        }
        
    );

=cut



use strict;
use warnings;

our $VERSION = 'v0.0.1';

our $DEFAULT_MESSAGE = 'Unkown SQL-state';

use Exporter qw/import/;

our @EXPORT = (
    'sqlstate_message',
    'sqlstate_token',
    'sqlstate_class_message',
    'sqlstate_class_token',
    'sqlstate_default_message',
    'sqlstate_default_token',
);

our @EXPORT_OK = (
    'sqlstate_codes',
    'sqlstate_class_codes',
);


my %SQLstate = ();
my %SQLclass = ();


sub sqlstate_message ($) { $SQLstate{$_[0]} }

sub sqlstate_token ($) { tokenize( sqlstate_message(shift) ) }

sub sqlstate_class ($) { substr($_[0],0,2) }

sub sqlstate_class_message ($) { $SQLclass{sqlstate_class($_[0])} }

sub sqlstate_class_token ($) { tokenize( sqlstate_class_message(shift) ) }

sub sqlstate_default_message () { $DEFAULT_MESSAGE }

sub sqlstate_default_token () { tokenize( sqlstate_default_message ) }

sub sqlstate_codes () { %SQLstate }

sub sqlstate_known_codes () {
    use DBIx::SQLstate::wikipedia;
    
    my %sqlstate_codes = (
        %SQLstate,
        %DBIx::SQLstate::wikipedia::SQLstate,
    );
    
    return %sqlstate_codes;
}

sub sqlstate_class_codes () {
    my %sqlstate_class_codes = map {
        sqlstate_class($_) => sqlstate_message($_)
    } grep { /..000/ } keys %{{ sqlstate_codes() }};
    
    return %sqlstate_class_codes;
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
	$text =~ s/fdw /fdw_/ig;
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



%SQLstate = sqlstate_known_codes();
%SQLclass = sqlstate_class_codes();



1;

__END__
