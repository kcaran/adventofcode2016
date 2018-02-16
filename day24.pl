#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

$| = 1;

{ package Maze;

  sub shortest_path {
    my ($self, $start, $end) = @_;

    # These are the positions we've already been to
    my %seen;
 
    my $key = join( ',', @{ $start }, @{ $end } );

    return $self->{ distance }{ $key } if ($self->{ distance }{ $key });

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
        next if ($seen{ "$y,$x" });
        next if ($self->{ maze }[$y][$x] eq '#');
        if ($y == $end->[0] && $x == $end->[1]) {
          # This must be shortest!
          $self->{ distance }{ $key } = $steps;
          return $steps;
         }
        $seen{ "$y,$x" } = 1;
        push @tries, [ $steps, $next_pos ];
       }
     }

    # We shouldn't get here
    return -1;
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
		distance => {},
		};

    bless $self, $class;

    $self->init( $file );

    return $self;
  }
};

sub possible_paths
 {
  my (@paths) = @_;

  my $routes;
  return [ [$paths[0] ] ] if (@paths == 1);

  for (my $i = 0; $i < @paths; $i++) {
    my @new_paths = @paths;
    my $path = splice( @new_paths, $i, 1 );
    my $new_routes = possible_paths( @new_paths );
    for my $r ( @{ $new_routes } ) {
      push @{ $routes }, [ $path, @{ $r } ];
     }
   }

  return $routes; 
 }


my $input_file = $ARGV[0] || 'input24.txt';

my $maze = Maze->new( $input_file );

# We are starting at 0 so ignore it
my $paths = possible_paths( ( 0 .. @{ $maze->{ targets } } - 2 ) );

my $shortest = 1000000;
for my $p (@{ $paths }) {
   my $steps = 0;
   for (my $i = -1; $i < @{ $p } - 1; $i++) {
     my $from = $i < 0 ? 0 : $p->[$i] + 1;
     my $to = $p->[$i + 1] + 1;
     $steps += $maze->shortest_path( $maze->{ targets }[$from], $maze->{ targets }[$to] );
     # Don't bother if it is longer
     if ($steps > $shortest) {
       $steps = 0;
       last;
      }
    }

   print "$steps for ", join( '-', @{ $p } ), "\n";
   $shortest = $steps if ($steps && $steps < $shortest);
  }
print "The shortest path is: $shortest\n";
