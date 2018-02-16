#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Maze;

  sub shortest_path {
    my ($self, $start, $end) = @_;

    # These are the positions we've already been to
    my %seen;
 
    # Keep number of moves and position
    my @tries = ( [0, $start] );

    while (@tries) {
      my $t = shift @tries;
      my ($steps, $pos) = @{ $t };
      $seen{ "$pos->[0],$pos->[1]" } = 1;

      #
      # Now we will move. The maze is set up so we don't have to worry about
      # "falling out" - less than 0 or greater than the maximum
      #
      $steps++;
      for my $next_pos ( [ $pos->[0] - 1, $pos->[1] ],
                     [ $pos->[0] + 1, $pos->[1] ],
                     [ $pos->[0], $pos->[1] - 1 ],
                     [ $pos->[0], $pos->[1] + 1 ] ) {
        my ($y, $x) = @{ $next_pos };
        next if ($self->{ maze }[$y][$x] eq '#');
        if ($y == $end->[0] && $x == $end->[1]) {
          # This must be shortest!
          return $steps;
         }

        push @tries, [ $steps, $next_pos ];
       }
     }

    # We shouldn't get here
    return -1;
   }

  sub shortest {
    my ($self, $start) = @_;

    my $pos = $self->{ targets }[$start];

   }

  sub init {
    my ($self, $file) = @_;

    $self->{ maze } = [];
    $self->{ targets } = [];
    for my $line (Path::Tiny::path( $file )->lines_utf8( { chomp => 1 } )) {
      my $row = [ split( '', $line ) ];
      push @{ $self->{ maze } }, $row;
     }

    for (my $y = 0; $y < @{ $self->{ maze } }; $y++) {
      my $line = $self->{ maze }[$y];
      for (my $x = 0; $x < @{ $line }; $x++) {
        if ($line->[$x] =~ /^([0-9])/) {
          $self->{ targets }[ $1 ] = [ $y, $x ];
         }
       }
     }

    return $self;
   }

  sub new {
    my ($class, $file) = @_;
    my $self = { 
		targets => [],
		maze => [],
		};

    bless $self, $class;

    $self->init( $file );

    return $self;
  }
};


my $input_file = $ARGV[0] || 'input24.txt';

my $maze = Maze->new( $input_file );

my $shortest = $maze->shortest_path( $maze->{ targets }[0], $maze->{ targets }[2] );
print "$shortest\n";
