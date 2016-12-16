#!/usr/bin/perl
#
#
use strict;
use warnings;

my $initial = $ARGV[0] || '10000';
my $length = $ARGV[1] || 20;

sub calc_data
 {
  my ($initial, $length) = @_;

  while (length( $initial ) < $length) {
    $initial .= '0' . join( '', map { !$_ || 0 } reverse split( '', $initial ) );
print "Length of data is ", length($initial), "\n";
   }

  return substr( $initial, 0, $length );
 }

sub calc_checksum
 {
  my ($data) = @_;
  my $checksum = $data;

  do {
   my $char = 0;
   while ($char < length( $checksum )) {
     my $val = (substr( $checksum, $char, 2 ) =~ /^(.)\1/) ? 1 : 0;
     substr( $checksum, $char, 2 ) = $val;
     $char++;
    }
print "Length of checksum is ", length($checksum), "\n";
  } until (length($checksum) % 2);

  return $checksum;
 }

my $data = calc_data( $initial, $length );
#print "The data is $data\n";

my $checksum = calc_checksum( $data );
print "The checksum is $checksum\n";
