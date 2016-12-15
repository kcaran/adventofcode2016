#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Disc;

  sub at_zero {
    my ($self, $time) = @_;
 
    return ($self->{ disk_num } + $self->{ initial_pos } + $time) % $self->{ num_positions };
   }

  sub new {
    my ($class, $disk_num, $positions, $init) = @_;
    my $self = {
      disk_num => $disk_num,
      num_positions => $positions,
      initial_pos => $init,
     };

    bless $self, $class;
  }
}

my $discs = [
	Disc->new( 1, 13, 1 ),
	Disc->new( 2, 19, 10 ),
	Disc->new( 3, 3, 2 ),
	Disc->new( 4, 7, 1 ),
	Disc->new( 5, 5, 3 ),
	Disc->new( 6, 17, 5 ),
];

push @{ $discs }, Disc->new( 7, 11, 0 );

my $time = 0;
while (1) {
  die "Press the button at $time seconds\n" unless (grep { $_->at_zero( $time ) } @{ $discs });
  $time++;
 }
