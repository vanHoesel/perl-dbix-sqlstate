package DBIx::SQLstate;



=head1 NAME

DBIx::SQLstate - message lookup and tokenization of SQL-State codes

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
                    $state, DBIx::SQLstate->token($state)
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
);

our @EXPORT_OK = (
    'sqlstate_codes',
    'sqlstate_message',
    'sqlstate_token',
    'sqlstate_class_codes',
    'sqlstate_class_message',
    'sqlstate_class_token',
    'sqlstate_default_message',
    'sqlstate_default_token',
    'sqlstate_class_codes',
);

our %EXPORT_TAGS = (
    message => [
        'sqlstate_message',
        'sqlstate_class_message',
        'sqlstate_default_message',
    ],
    token => [
        'sqlstate_token',
        'sqlstate_class_token',
        'sqlstate_default_token',
    ],
);



my %SQLstate = ();



sub sqlstate_message ($) {
    return unless defined $_[0];
    return $SQLstate{$_[0]};
}

sub sqlstate_token ($) {
    return tokenize( sqlstate_message(shift) );
}

sub sqlstate_class ($) {
    return unless defined $_[0];
    return substr($_[0],0,2);
}

sub sqlstate_class_message ($) {
    return unless defined $_[0]; 
    return +{ sqlstate_class_codes() }->{sqlstate_class($_[0])};
}

sub sqlstate_class_token ($) {
    return tokenize( sqlstate_class_message(shift) );
}

sub sqlstate_default_message () {
    return $DEFAULT_MESSAGE;
}

sub sqlstate_default_token () {
    return tokenize( sqlstate_default_message );
}

sub sqlstate_codes () {
    return %SQLstate;
}

sub sqlstate_known_codes () {
    use DBIx::SQLstate::wikipedia;
    
    return (
        %DBIx::SQLstate::wikipedia::SQLstate,
    );
}

sub sqlstate_class_codes () {
    my %sqlstate_class_codes = map {
        sqlstate_class($_) => sqlstate_message($_)
    } grep { /..000/ } keys %{{ sqlstate_codes() }};
    
    return %sqlstate_class_codes;
}



sub tokenize ($) {
    return if !defined $_[0];
    
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



=head1 DESCRIPTION

Database Management Systems, and L<DBI> have their own way of reporting errors.
Very often, errors are quit expressive in what happened. Many SQL based systems
do also include a SQL-State with each request. This module turns the SQL-State 5
byte code into human readable strings.

=head1 SQLSTATE Classes and Sub-Classes

Programs calling a database which accords to the SQL standard receive an
indication about the success or failure of the call. This return code - which is
called SQLSTATE - consists of 5 bytes. They are divided into two parts: the
first and second bytes contain a class and the following three a subclass. Each
class belongs to one of four categories: "S" denotes "Success" (class 00), "W"
denotes "Warning" (class 01), "N" denotes "No data" (class 02) and "X" denotes
"Exception" (all other classes).

=cut



=head1 CLASS METHODS

The following two class methods have been added for the programmer convenience:

=head2 C<message($sqlstate)>

Returns a subclass-message or class-message for a given and exisitng SQLstate,
or the default C<'Unkown SQL-state'>.

    my $message = DBIx::SQLstate->message("25006");
    #
    # "read-only SQL-transaction"

=head2 C<token($sqlstate)>

Returns the tokenized (See L<tokenize>) version of the message from above.

    $sqlstate = "22XXX"; # non existing code
    $LOG->error(DBIx::SQLstate->token $sqlstate)
    #
    # logs an error with "DataException"

=cut



=head1 EXPORT_OK SUBROUTINES

=head2 C<sqlstate_message($sqlstate)>

Returns the human readable message defined for the given SQL-State code.

    my $sqlstate = '25006';
    say sqlstate_message();
    #
    # prints "read-only SQL-transaction"

=head2 C<sqlstate_token($sqlstate)>

Returns a tokenized string (See L<DBIx::SQLstate::tokenize>).

    my $sqlstate = '01007';
    $LOG->warn sqlstate_token($sqlstate);
    #
    # logs a warning message with "PrivilegeNotGranted"

=head2 C<sqlstate_class($sqlstate)>

Returns the 2-byte SQL-state class code.

=head2 C<sqlstate_class_message($sqlstate)>

Returns the human readable message for the SQL-state class. This might be useful
reduce the amount of variations of log-messages. But since not all SQLstate
codes might be present in the current table, this will provide a decent fallback
message.

    my $sqlstate = '22X00'; # a madeup code
    my $m = sqlstate_message($sqlstate) // sqlstate_class_message($sqlstate);
    say $m;
    #
    # prints "data exception"

=head2 C<sqlstate_class_token($sqlstate)>

Returns the tokenized string for the above L<sqlstate_class_message>. See
L<tokenize>.

=head2 C<sqlstate_default_message()>

Returns a default message. The value can be set with
C<our $DBIx::SQLstate::$DEFAULT_MESSAGE>, and defaults to C<'Unkown SQL-state'>.

=head2 C<sqlstate_default_token()>

Returns the tokenized version of the default message.

=head1 Tokenization

The tokenized strings can be useful in logging, or for L<Throwable> ( or 
L<Exception::Class>) object creations etc. These are mostly camel-case. However,
for some common abreviations, like 'SQL', 'XML' or 'XQuery' this module tries to
correct the charactercase-folding.

For now, do not rely on the consitent case-folding, it may change in the future.

=cut



sub message ($) {
    my $class = shift;
    my $sqlstate = shift;
    
    return
        sqlstate_message($sqlstate)
        //
        sqlstate_class_message($sqlstate)
        //
        sqlstate_default_message()
    ;
}

sub token ($) {
    my $class = shift;
    my $sqlstate = shift;
    
    my $message =
        sqlstate_message($sqlstate)
        //
        sqlstate_class_message($sqlstate)
        //
        sqlstate_default_message()
    ;
    
    return tokenize($message);
}



1;



=head1 AUTHOR

Theo van Hoesel <tvanhoesel@perceptyx.com>



=head1 COPYRIGHT AND LICENSE

'DBIx::SQLstate'
is Copyright (C) 2023, Perceptyx Inc

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0.

This package is distributed in the hope that it will be useful, but it is
provided "as is" and without any express or implied warranties.

For details, see the full text of the license in the file LICENSE.


=cut




__END__
