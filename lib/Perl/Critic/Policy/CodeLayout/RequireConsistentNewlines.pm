##################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##################################################################

package Perl::Critic::Policy::CodeLayout::RequireConsistentNewlines;

use strict;
use warnings;
use Perl::Critic::Utils;
use English qw(-no_match_vars);
use base 'Perl::Critic::Policy';

our $VERSION = 0.21;

my $LINE_END = qr/\015{1,2}\012|\012|\015/mxs;

#----------------------------------------------------------------------------

my $desc = q{Use the same newline through the source};
my $expl = q{Change your newlines to be the same throughout};

#----------------------------------------------------------------------------

sub default_severity { return $SEVERITY_HIGH }
sub applies_to { return 'PPI::Document' }

#----------------------------------------------------------------------------

sub violates {
    my ( $self, undef, $doc ) = @_;

    my $filename = $doc->filename();
    return if !$filename;

    my $fh;
    return if !open $fh, '<', $filename;
    local $RS = undef;
    my $source = <$fh>;
    close $fh;

    my $newline; # undef until we find the first one
    my $line = 1;
    my @v;
    while ( $source =~ m/\G([^\012\015]*)($LINE_END)/cgmxs ) {
        my $code = $1;
        my $nl = $2;
        my $col = length $code;
        $newline ||= $nl;
        if ( $nl ne $newline ) {
            my $token = PPI::Token::Whitespace->new( $nl );
            $token->{_location} = [$line, $col, $col];
            push @v, $self->violation( $desc, $expl, $token );
        }
        $line++;
    }
    return @v;
}

1;

#----------------------------------------------------------------------------

__END__

=pod

=head1 NAME

Perl::Critic::Policy::CodeLayout::RequireConsistentNewlines

=head1 CAVEAT

This policy works outside of PPI because PPI automatically normalizes
source code to local newline conventions.  So, this will only work if
we know the filename of the source code.

=head1 DESCRIPTION

Source code files are divided into lines with line endings of C<\r>,
C<\n> or C<\r\n>.  Mixing these different line endings causes problems
in many text editors and, notably, Module::Signature and GnuPG.

=head1 AUTHOR

Chris Dolan <cdolan@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2006 Chris Dolan.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut