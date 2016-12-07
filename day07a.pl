#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my $input_file = $ARGV[0] || 'input07.txt';

open my $input_fh, '<', $input_file or die $!;

sub is_ipv7
 {
  my @ip = split '', shift;
  my $is_ipv7 = 0;

  my $first = '';
  my $in_brackets = 0;
  for (my $i = 0; $i < @ip - 2; $i++) {
    if ($ip[$i] eq '[') {
      $first = '';
      $in_brackets = 1;
      next;
     }

    if ($ip[$i] eq ']') {
      $first = '';
      $in_brackets = 0;
      next;
     }

    # Two in a row - ignore
    if ($ip[$i] eq $first) {
      next;
     }

    if ($first && $ip[$i + 2] eq $first && $ip[$i] eq $ip[$i + 1]) {
      return if ($in_brackets);
      $is_ipv7 = 1;
     }

    $first = $ip[$i];
   }

  return $is_ipv7;
 }

my $count = 0;
while (<$input_fh>) {
  chomp;

  $count++ if (is_ipv7( $_ ));
print "$_\n" if (is_ipv7( $_ ));
 }

print "The number of ipv7 addresses is $count\n";

