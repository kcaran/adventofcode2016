#!/usr/bin/perl
#
use strict;
use warnings;

{ package Elf;
  sub new {
    my ($class, $index) = @_;
    my $self = {
      index => $index,
      num_presents => 1,
    }
  }
}

sub node {
  my ($h, $t) = @_;
  [$h, $t];
}

sub head {
  my ($ls) = @_;
  $ls->[0];
}

sub tail {
  my ($ls) = @_;
  $ls->[1];
}

sub set_tail {
  my ($ls, $new_tail) = @_;
  $ls->[1] = $new_tail;
}

# Set up list of elves
my $elves;
my $first_elf;
my $num_elves = $ARGV[0] || 5;
for (my $i = $num_elves; $i > 0; $i--) {
  my $elf = Elf->new( $i );
  $elves = node( $elf, $elves );
  $first_elf ||= $elves;
 }

$first_elf->[1] = $elves;

while ($elves != tail( $elves )) {
  # Steal the next elf's presents
  my $next_elf = tail( $elves );
  head( $elves )->{ num_presents } += head( $next_elf )->{ num_presents };
  
  # Skip the next elf
  $elves->[1] = $next_elf->[1];
  $elves = tail( $elves );
 }

print "Elf $elves->[0]{ index } has all the presents!\n";
exit;
