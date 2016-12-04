#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub is_triangle
 {
  my @sides = @_;

  @sides = reverse sort { $a <=> $b } @sides;

  return ($sides[0] < $sides[1] + $sides[2]);
 }

my $num_triangles = 0;

my $input_file = $ARGV[0] || 'input03.txt';

open my $input_fh, '<', $input_file or die $!;

while (<$input_fh>) {
  chomp;
  s/^\D+//;
  my @sides = split /\D+/, $_;
  $num_triangles++ if (is_triangle( @sides ));
 }

print "The number of triangles are $num_triangles\n";
