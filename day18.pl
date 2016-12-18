#!/usr/bin/perl
#
use strict;
use warnings;

  sub num_safe {
    my $row = shift;

    my $count = () = ($row =~ /\./g);

    return $count;
   }

  sub to_decimal {
    my $binary = shift;

    return unpack( 'N', pack( 'B32', substr( '0' x 32 . $binary, -32)));
   }

  sub build_row {
    my $prev = shift;
    my $len = length( $prev );
    my $row = '';

    $prev =~ tr/\./0/;
    $prev =~ tr/\^/1/;
    $prev = "0${prev}0";
    for (my $i = 0; $i < $len; $i++) {
      my $val = to_decimal( substr( $prev, $i, 3 ) );
      $row .= ($val == 1 || $val == 3 || $val == 4 || $val == 6) ? '^' : '.';
     }

    return $row;
   }
   
my $row = $ARGV[0] || '..^^.';
my $num_rows = $ARGV[1] || 3;
my $num_safe = num_safe( $row );

print "$row\n";
for (my $i = 1; $i < $num_rows; $i++) {
  $row = build_row( $row );
# print "$row\n";
  $num_safe += num_safe( $row );
 }

print "There are $num_safe safe tiles\n";
