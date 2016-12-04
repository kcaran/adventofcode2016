#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub read_input
 {
  my ($input_file) = @_;
  my $triangles = [];

  open my $input_fh, '<', $input_file or die $!;

  my $row_count = 0;
  while (<$input_fh>) {
    chomp;
    s/^\D+//;
    my @sides = split /\D+/, $_;
    my $triangle = ($row_count - $row_count % 3);
    my $side_cnt = 0;
    for my $side (@sides) {
      push @{ $triangles->[$triangle + $side_cnt] }, $side;
      $side_cnt++;
     }
    $row_count++;
   }

  return $triangles;
 }


sub is_triangle
 {
  my @sides = @_;

  @sides = reverse sort { $a <=> $b } @sides;

  return ($sides[0] < $sides[1] + $sides[2]);
 }

my $num_triangles = 0;

my $triangles = read_input( $ARGV[0] || 'input03.txt' );

for (@{ $triangles }) {
  $num_triangles++ if (is_triangle( @{ $_ } ));
 }

print "The number of triangles are $num_triangles\n";
