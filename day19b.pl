#!/usr/bin/perl
#
use strict;
use warnings;

my $debug = 0;

{ package Elf;
  sub new {
    my ($class, $index) = @_;
    my $self = {
      index => $index,
      num_presents => 1,
    };
    bless $self, $class;
  }
}

{ package ElfCache;
  sub new {
    my ($class, $elves) = @_;
    my $self = {
      num_elves => 0,
      first_removed => -1,
      index => [],
    };

    my $first_elf = $elves;
    while (::tail( $elves ) != $first_elf) {
      push @{ $self->{ index } }, $elves;
      $elves = ::tail( $elves );
      $self->{ num_elves }++;
     }
    push @{ $self->{ index } }, $elves;
    $self->{ num_elves }++;
    
    bless $self, $class;
  }
}

sub node {
  my ($h, $t, $p) = @_;
  my $node = [ $h, $t, undef ];
  $p->[2] = $node;
  return $node;
}

sub head {
  my ($ls) = @_;
  $ls->[0];
}

sub prev {
  my ($ls) = @_;
  $ls->[2];
}

sub tail {
  my ($ls) = @_;
  $ls->[1];
}

# Set up list of elves
my $prev;
my $elves;
my $first_elf;
my $num_elves = $ARGV[0] || 5;
for (my $i = $num_elves; $i > 0; $i--) {
  my $elf = Elf->new( $i );
  $prev = $elves;
  $elves = node( $elf, $elves, $prev );
  $first_elf ||= $elves;
 }

$first_elf->[1] = $elves;
$elves->[2] = $first_elf;

my $cache = ElfCache->new( $elves );
my $first_stolen = -1;
my $current_elf = 0;

while ($elves != tail( $elves )) {
  # Reset cache when necessary
  if ($first_stolen == $current_elf) {
    $cache = ElfCache->new( $elves );
    $first_stolen = -1;
    $current_elf = 0;
    print "New cache with ", $cache->{ num_elves }, " elves. \n";
   }

  # Find the elf to steal from (from right, not left)
  my $steal = ($current_elf - int( ($num_elves + 1) / 2 )) % $cache->{ num_elves };

  $first_stolen = $steal unless ($first_stolen >= 0);

  # Go to the elf directly before the one to steal
  my $stolen_elf = $cache->{ index }[$steal];

  # Steal the stolen elf's presents
  print "Elf #", head( $elves )->{ index }, " steals from ", head( $stolen_elf )->{ index }, "\n" if ($debug);
  head( $elves )->{ num_presents } += head( $stolen_elf )->{ num_presents };
  
  # Skip the elf
  prev( $stolen_elf )->[1] = tail( $stolen_elf );
  tail( $stolen_elf )->[2] = prev( $stolen_elf );
  $num_elves--;

  $current_elf++;
  $elves = tail( $elves );
  print "We have $num_elves left\n" if ($debug);
 }

print "Elf $elves->[0]{ index } has all the presents!\n";
exit;
