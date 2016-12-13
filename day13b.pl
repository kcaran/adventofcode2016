#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Storable 'dclone';

my $FAVE_NUM = 1352;

{ package Route;

  sub add {
    my ($self, $x, $y) = @_;

    # Return undefined if we've already seen this space
    return if ($self->{ prev_moves }{ "$x,$y" });

    $self->{ num_moves }++;
    $self->{ prev_moves }{ "$x,$y" } = $self->{ num_moves };
    $self->{ position } = [ $x, $y ];

    return $self;
   }

  sub is_open_space {
    my ($x, $y) = @_;

    return unless ($x >= 0 && $y >= 0);

    my $sum = ($x * $x) + (3 * $x) + (2 * $x * $y) + $y + ($y * $y) + $FAVE_NUM;
 
    # Not sure if there is a simpler way of counting bits
    return (scalar( grep { $_ eq 1 } split '', sprintf "%b", $sum ) % 2 == 0);
   }

  sub next_moves {
    my ($self) = @_;

    my @moves;

    my ($x, $y) = @{ $self->{ position } };
    
    push @moves, [ $x - 1, $y ] if (is_open_space( $x - 1, $y ));
    push @moves, [ $x + 1, $y ] if (is_open_space( $x + 1, $y ));
    push @moves, [ $x, $y - 1 ] if (is_open_space( $x, $y - 1 ));
    push @moves, [ $x, $y + 1 ] if (is_open_space( $x, $y + 1 ));

    return @moves;
   }

  sub moves {
    my $self = shift;

    return $self->{ num_moves };
   }

  sub new {
    my ($class, $x, $y) = @_;
    my $self = {
      num_moves => 0,
      position => [ $x, $y ],
      prev_moves => { "$x,$y" => 0 },
     };
    bless $self, $class;
  }
}

use Data::Printer;

my $moves = [ Route->new( 1, 1 ) ];

my $diff_moves = { "1,1" => 1 };

my $depth = 0;
while ($depth < 50) {
  my $new_moves = [];
  for my $m (@{ $moves }) {
    for my $next_pos ($m->next_moves()) {
      $diff_moves->{ "$next_pos->[0],$next_pos->[1]" } = 1;

      my $next_move = dclone( $m )->add( @{ $next_pos } );
      push @{ $new_moves }, $next_move if ($next_move);
     }
    }
  $moves = $new_moves;
  $depth++;
  print "Reached ", scalar keys( %{ $diff_moves } ), " positions in $depth moves\n";
 }

exit;
