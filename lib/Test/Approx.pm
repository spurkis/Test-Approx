=head1 NAME

Test::Approx - compare two things for approximate equality

=head1 SYNOPSIS

  use Test::Approx 'no_plan';

  is_approx( 'abcd', 'abcd', 'equal strings' );
  is_approx( 1234, 1234, 'equal integers' );
  is_approx( 1.234, 1.234, 'equal decimal numbers' );
  is_approx( '1.234000', '1.234', 'equal decimal numbers, extra zeros' );
  is_approx( 1.0, 1, 'equal decimal number & integer' );

  is_approx( 'abcdefgh', 'abcdefg', 'approx strings' );
  is_approx( 1, 1.001, 'approx given decimal number & integer' );
  is_approx( 51.60334, 51.603335, 'approx decimal numbers' );

  # default Levenshtein edit threshold is 5% of avg string length:
  is_approx( 'abcdefg', 'abcgfe', 'str threshold' ); # fail

  # default difference threshold is 5% of first number:
  is_approx( 1, 1.04, 'num threshold' ); # fail
  is_approx( 1, 1.05, 'num threshold' ); # fail

  # default difference threshold is 5% of first integer, or 1:
  is_approx( 1, 2, 'int threshold' ); # pass
  is_approx( 100, 105, 'int threshold' ); # pass
  is_approx( 100, 106, 'int threshold' ); # fail

  # you can set the threshold yourself:
  is_approx( 'abcdefg', 'abcgfe', 'diff strings', '50%' ); # pass

  # you can set threshold as a number too:
  is_approx( 'abcdefg', 'abcgfe', 'diff strings', 6 );

  # you can force compare as string, number, or integer:
  is_approx_str( '1.001', '1.901', 'pass as string' );
  is_approx_num( '1.001', '1.901', 'fail as num' );
  is_approx_int( '1.001', '1.901', 'pass as int' ); # not rounded!

=cut

package Test::Approx;

use strict;
use warnings;

use POSIX qw( strtod );
use Text::LevenshteinXS qw(distance);
use Test::Builder;

use base 'Exporter';
our @EXPORT = qw( is_approx is_approx_str is_approx_num is_approx_int );

our $VERSION = 0.03;
our %DEFAULT_THRESHOLD = (
			  # these are all given as percentages
			  str => 0.05,
			  num => 0.05,
			  int => 0.05,
			 );
our $Test = Test::Builder->new;

sub import {
    my $self = shift;
    my $pack = caller;

    $Test->exported_to($pack);
    $Test->plan(@_) if (@_);

    $self->export_to_level(1, $self, @EXPORT);
}

sub check_type {
    my $arg = shift;

    local $! = 0;
    my ($num, $unparsed) = strtod( $arg );
    return 'str' if (($arg eq '') || ($unparsed != 0) || $!);
    return 'num' if $num =~ /\.\d*\z/;

    return 'int';
}

sub is_approx {
    my ($arg1, $arg2, $msg, $threshold) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    # clean input & avoid warnings
    $arg1 = '' unless defined $arg1;
    $arg2 = '' unless defined $arg2;

    # check inputs types and call appropriate sub
    my $arg1_type = check_type( $arg1 );
    my $arg2_type = check_type( $arg2 );

    if ($arg1_type eq 'int') {
	return is_approx_int( @_ ) if $arg2_type eq 'int';
	return is_approx_num( @_ ) if $arg2_type eq 'num';
    } elsif ($arg1_type eq 'num') {
	return is_approx_num( @_ )
	  if ($arg2_type eq 'int') or ($arg2_type eq 'num');
    }

    # default behaviour, compare as strings:
    return is_approx_str( @_ );
}

sub is_approx_str {
    my ($str1, $str2, $msg, $threshold) = @_;

    # clean input & avoid warnings
    $str1 = '' unless defined $str1;
    $str2 = '' unless defined $str2;

    # build some diagnostics info
    my $short1 = length($str1) > 8 ? substr($str1, 0, 5) . '...' : $str1;
    my $short2 = length($str2) > 8 ? substr($str2, 0, 5) . '...' : $str2;
    my $msg2   = "'$short1' =~ '$short2'";

    # set default message
    $msg = $msg2 unless defined($msg);

    # figure out what to use as the threshold
    my $percent = $DEFAULT_THRESHOLD{str};
    if (defined($threshold) && $threshold =~ /^(.+)%$/) {
	# threshold was given as a percentage, so calculate it:
	$percent = $1 / 100;
	$threshold = undef;
    }

    # calculate threshold as a percentage?
    if (!defined $threshold) {
	# default: 5% of average string length, or 1
	$threshold = int(( (length($str1)+length($str2))/2 )*$percent) || 1;
    }

    # we've got a threshold, now do the test:
    my $dist = distance($str1, $str2);
    unless ($Test->ok($dist <= $threshold, $msg)) {
	$Test->diag("  test: $msg2") if ($msg ne $msg2);
	$Test->diag("  error: edit distance ($dist) was greater than threshold ($threshold)");
    }
}

sub is_approx_num {
    my ($num1, $num2, $msg, $threshold) = @_;

    # clean input & avoid warnings
    $num1 = '' unless defined $num1;
    $num2 = '' unless defined $num2;

    $num1 = strtod( $num1 ); # ignore any errors
    $num2 = strtod( $num2 ); # ignore any errors

    # build some diagnostics info
    my $short1 = length($num1) > 8 ? substr($num1, 0, 5) . '...' : $num1;
    my $short2 = length($num2) > 8 ? substr($num2, 0, 5) . '...' : $num2;
    my $msg2   = "'$short1' =~ '$short2'";

    # set default message
    $msg = $msg2 unless defined($msg);

    # figure out what to use as the threshold
    my $percent = $DEFAULT_THRESHOLD{num};
    if (defined($threshold) && $threshold =~ /^(.+)%$/) {
	# threshold was given as a percentage, so calculate it:
	$percent = $1 / 100;
	$threshold = undef;
    }

    # calculate threshold as a percentage?
    if (!defined $threshold) {
	# set threshold to x% of num1
	# strtod() to get around weird bug:
	# $dist = 0.05; $threshold = 0.05; $dist <= $threshold; # false ??!?
	$threshold = strtod( abs( $num1 * $percent ) );
    }

    # we've got a threshold, now do the test:
    # strtod() to get around weird bug:
    # $dist = 0.05; $threshold = 0.05; $dist <= $threshold; # false ??!?
    my $dist = strtod( abs($num2 - $num1) );
    unless ($Test->ok($dist <= $threshold, $msg)) {
	$Test->diag("  test: $msg2") if ($msg ne $msg2);
	$Test->diag("  error: distance ($dist) was greater than threshold ($threshold)");
    }
}

sub is_approx_int {
    my ($int1, $int2, $msg, $threshold) = @_;

    # clean input & avoid warnings
    $int1 = '' unless defined $int1;
    $int2 = '' unless defined $int2;

    ($int1) = ($int1 =~ /(\-?\d+)/);
    ($int2) = ($int2 =~ /(\-?\d+)/);

    $int1 = 0 unless defined( $int1 );
    $int2 = 0 unless defined( $int2 );

    # build some diagnostics info
    my $short1 = length($int1) > 8 ? substr($int1, 0, 5) . '...' : $int1;
    my $short2 = length($int2) > 8 ? substr($int2, 0, 5) . '...' : $int2;
    my $msg2   = "'$short1' =~ '$short2'";

    # set default message
    $msg = $msg2 unless defined($msg);

    # figure out what to use as the threshold
    my $percent = $DEFAULT_THRESHOLD{int};
    if (defined($threshold) && $threshold =~ /^(.+)%$/) {
	# threshold was given as a percentage, so calculate it:
	$percent = $1 / 100;
	$threshold = undef;
    }

    # calculate threshold as a percentage?
    if (!defined $threshold) {
	# set threshold to x% of int1
	# strtod() to get around weird bug:
	# $dist = 0.05; $threshold = 0.05; $dist <= $threshold; # false ??!?
	$threshold = strtod( abs( int( $int1 * $percent ) ) ) || 1;
    }

    # we've got a threshold, now do the test:
    # strtod() to get around weird bug:
    # $dist = 0.05; $threshold = 0.05; $dist <= $threshold; # false ??!?
    my $dist = strtod( abs($int2 - $int1) );
    unless ($Test->ok($dist <= $threshold, $msg)) {
	$Test->diag("  test: $msg2") if ($msg ne $msg2);
	$Test->diag("  error: distance ($dist) was greater than threshold ($threshold)");
    }
}


1;

__END__

=head1 DESCRIPTION

This module lets you test if two strings are I<approximately> equal.  Yes, that
sounds a bit wrong at first - surely you know if they should be equal or not?
But there are actually valid cases when you don't / can't know.  This module is
meant for those rare cases when close is good enough.

=head1 FUNCTIONS

=over 4

=item is_approx( $str1, $str2 [, $test_name, $edit_threshold ] )

Tests if C<$str1> is approximately equal to C<$str2> by using L<Text::LevenshteinXS>
to compute the edit distance between the two strings.

If you don't pass a C<$test_name>, it gets named for you.

If C<$edit_threshold> is set, it is used to determine how many edits are allowed
before a test failure.  Otherwise, the default value is set to C<5% the average
lengths of the two strings> or C<1> (whichever is larger).  You can pass 
C<$edit_threshold> as either an integer, or a percentage (in a string, ie: use
C<'6%'> not C<0.06>).

=head1 EXPORTS

C<is_approx>, C<is_approx_str>, C<is_approx_num>, C<is_approx_int>

=head1 AUTHOR

Steve Purkis <spurkis@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008-2010 Steve Purkis.
Released under the same terms as Perl itself.

=head1 SEE ALSO

L<Text::LevenshteinXS>,
L<Test::Builder>

=cut
