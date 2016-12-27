#!/usr/bin/perl
#
use strict;
use warnings;

my $input_file = $ARGV[0] || 'input20.txt';

open my $input_fh, '<', $input_file or die $!;

# Get the ranges
my @ranges;
while (<$input_fh>) {
  chomp;
  my ($min, $max) = /^(\d+)\-(\d+)/;
  die "$max < $min" if ($max < $min);
  push @ranges, [$min, $max];
 }

# sort the ranges
@ranges = sort { $a->[0] <=> $b->[0] } @ranges;

my $ipmax = $ARGV[1] || 4294967295;

my $counter = 0;
my $ips;
my $idx = 0;
while ($counter <= $ipmax) {
  # Ignore ranges that are smaller than the previous
  while ($idx < @ranges && $counter > $ranges[$idx]->[1]) {
    $idx++
   }

  if ($idx == @ranges) {
    $ips += ($ipmax - $counter) + 1;
    last;
   }
  elsif ($counter >= $ranges[$idx]->[0] && $counter <= $ranges[$idx]->[1]) {
    $counter = $ranges[$idx]->[1] + 1;
    $idx++;
   }
  else {
    warn "$counter is not in a range.\n";
    $ips += ($ranges[$idx]->[0] - $counter);
    $counter = $ranges[$idx]->[0] + 1;
   }
 }

print "There are $ips ips\n";
