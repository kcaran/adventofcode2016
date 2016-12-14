#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );

my $hash_cnt = 2016;
sub get_hash
 {
  my $input = shift;
  my $md5 = md5_hex( $input );
  for (my $i = 0; $i < $hash_cnt; $i++) {
    $md5 = md5_hex( $md5 );
   }
  return $md5; 
 }

my $salt = $ARGV[0] || die "Please enter the salt\n";

my $triples;
my @keys;

my $index = 0;
my $last = 64;
while (@keys < $last) {
  my $md5 = get_hash( sprintf "${salt}%d", $index );

  # Find exactly five in a row
  if ($md5 =~ /((.)(\2{4}))/) {
    my $key_char = $2;
    for my $key (sort grep { $_ =~ /^$key_char/ } keys %{ $triples }) {
      push @keys, $triples->{ $key };
print "The ", scalar @keys, " key is ", $triples->{ $key }{ char }, " at index ", $triples->{ $key }{ index }, "\n";
      delete $triples->{ $key };
     }
   }
  
  # Find exactly (?) three in a row
  if ($md5 =~ /((.)(\2{2}))/) {
    my $triplet_char = $2;
    $triples->{ "$triplet_char$index" } = { count => 1001, char => $triplet_char, index => $index };
   }

  # Decrement all of the keys
  for my $key (keys %{ $triples }) {
    $triples->{ $key }{ count }--;
    delete $triples->{ $key } unless ($triples->{ $key }{ count } > 0);
   }

  $index++;
 }

print "The final index is ", $keys[$last - 1]->{ index }, "\n";
