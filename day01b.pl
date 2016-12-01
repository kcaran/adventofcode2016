#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use File::Slurp;
use Data::Printer;

{ package Location;

  sub add_map {
    my $self = shift;

    my $key = "$self->{ pos_x }, $self->{ pos_y }";
 
    if ($self->{ map }{ $key }) {
      die "We have reached $key twice, ", $self->distance, " blocks away\n";
    }
    $self->{ map }{ $key } = 1;

    return $self;
  }

  sub distance {
    my $self = shift;

    return abs( $self->{ pos_x } ) + abs( $self->{ pos_y } );
  }

  sub move {
    my $self = shift;
    my $len = shift;

    while ($len--) {
      $self->next();
      $self->add_map();
     }
   }

  sub next {
    my $self = shift;

    if ($self->{ direction } == 0) {
      $self->{ pos_y }++;
    }
    if ($self->{ direction } == 90) {
      $self->{ pos_x }--;
    }
    if ($self->{ direction } == 180) {
      $self->{ pos_y }--;
    }
    if ($self->{ direction } == 270) {
      $self->{ pos_x }++;
    }

    return $self;
  }

  sub turn {
    my $self = shift;
    my $direction = shift;

    my $turn_angle = ($direction eq 'L') ? 90 : ($direction eq 'R') ? 270 : 0;
    $self->{ direction } = ($self->{ direction } + $turn_angle) % 360;

    return $self;
  }

  sub new {
    my $class = shift;
    my $self = { 
		direction => 0,
		pos_x => 0,
		pos_y => 0,
        map => {},
		};

    bless $self, $class;
    $self->add_map;

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input01.txt';

my $raw_input = read_file( $input_file );
chomp $raw_input;
my @input = split /\s*,\s*/, $raw_input;

my $loc = Location->new();

for my $route (@input) {
  my ($dir, $length) = $route =~ /^([LR])(\d+)$/;

  $loc->turn( $dir )->move( $length );

  next;
 }

print "The route is ", $loc->distance, " blocks away.\n";
