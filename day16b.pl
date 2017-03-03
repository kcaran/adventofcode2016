#!/usr/bin/perl
#
#
use strict;
use warnings;

my $initial = $ARGV[0] || '10000';
my $length = $ARGV[1] || 20;

# Reverse initial data - we will work from right to left
$initial = join( '', reverse split( '', $initial ) );

sub calc_data
 {
  my ($initial, $length) = @_;

  while (length( $initial ) < $length) {
    $initial = join( '', map { !$_ || 0 } reverse split( '', $initial ) ) . '0' . $initial;
print "Length of data is ", length($initial), "\n";
print "The data is ", join( '', reverse split '', $initial ), "\n";
   }

  return substr( $initial, -$length );
 }

sub calc_checksum
 {
  my ($data) = @_;
  my $checksum = $data;

  do {
   my $char = 2;
   while ($char <= length( $checksum )) {
     my $val = (substr( $checksum, -$char, 2 ) =~ /^(.)\1/) ? 1 : 0;
     substr( $checksum, -$char, 2 ) = $val;
     $char++;
    }
print "Length of checksum is ", length($checksum), "\n";
print "The checksum is ", join( '', reverse split '', $checksum ), "\n";
  } until (length($checksum) % 2);

  return $checksum;
 }

my $data = calc_data( $initial, $length );
print "The data is ", join( '', reverse split '', $data ), "\n";

my $checksum = calc_checksum( $data );
print "The checksum is ", join( '', reverse split '', $checksum ), "\n";
