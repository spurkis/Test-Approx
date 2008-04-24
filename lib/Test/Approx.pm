=head1 NAME

Geo::Google::PolylineEncoder - encode lat/lngs to Google Maps Polylines

=head1 SYNOPSIS

  use Test::Approx 'no_plan';

  is_approx( 'abcd', 'abcd', 'equal strings' );
  is_approx( 1234, 1234, 'equal numbers' );

  # fails as the default edit tolerance is 5% of avg string length:
  is_approx( 'abcdefg', 'abcgfe', 'diff strings' );

  # passes if you set the tolerance yourself:
  is_approx( 'abcdefg', 'abcgfe', 'diff strings', '50%' );

  # you can set tolerance as a number too:
  is_approx( 'abcdefg', 'abcgfe', 'diff strings', 5 );

=cut

package Test::Approx;

use strict;
use warnings;

use Text::LevenshteinXS qw(distance);
use Test::Builder;

use base 'Exporter';
our @EXPORT = qw( is_approx );

our $VERSION = 0.01;

our $Test = Test::Builder->new;

sub import {
    my $self = shift;
    my $pack = caller;

    $Test->exported_to($pack);
    $Test->plan(@_) if (@_);

    $self->export_to_level(1, $self, 'is_approx');
}

sub is_approx {
    my ($str1, $str2, $msg, $threshold) = @_;
    my $short1 = substr($str1, 0, 5) . '...';
    my $short2 = substr($str2, 0, 5) . '...';
    my $msg2   = "'$short1' approximately equal to '$short2'";

    # set defaults:
    $msg = $msg2 unless defined($msg);

    # calculate threshold as a percentage?
    my $percent = 0.05;
    if (defined($threshold) && $threshold =~ /^(.+)%$/) {
	# threshold was given as a percentage, so calculate it:
	$percent = $1 / 100;
	$threshold = undef;
    }
    if (!defined $threshold) {
	# default: 5% of average string length, or 1
	$threshold = int(( (length($str1)+length($str2))/2 )*$percent) || 1;
    }

    # do the test:
    my $dist = distance($str1, $str2);
    unless ($Test->ok($dist <= $threshold, $msg)) {
	$Test->diag("  test: $msg2") if ($msg ne $msg2);
	$Test->diag("  error: edit distance ($dist) was greater than threshold ($threshold)");
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

C<is_approx>

=head1 AUTHOR

Steve Purkis <spurkis@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008 Steve Purkis.
Released under the same terms as Perl itself.

=head1 SEE ALSO

L<Text::LevenshteinXS>,
L<Test::Builder>

=cut
