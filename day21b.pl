#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use File::Slurp;

{ package Message;

  sub move {
    my ($self, $from, $to) = @_;

    my $char = substr( $self->{ input }, $from, 1, '' );
    substr( $self->{ input }, $to, 0, $char );

    return $self;
   }

  sub rotate {
    my ($self, $dir, $steps) = @_;

    $steps = $steps % length( $self->{ input } );

    if ($dir eq 'left') {
      my $begin = substr( $self->{ input }, 0, $steps, '' );
      $self->{ input } .= $begin;
     }
    elsif ($dir eq 'right') {
      my $end = substr( $self->{ input }, -($steps), $steps, '' );
      $self->{ input } = $end . $self->{ input };
     }
    else {
      die "Illegal rotate direction: $dir";
     }

    return $self;
   }

  sub rotate_based {
    my ($self, $letter) = @_;

    my $index = index( $self->{ input }, $letter );
    $index++ if ($index >= 4);
    $index++;

    $self->rotate( 'right', $index );

    return $self;
   }

  sub rotate_based_reverse {
    my ($self, $letter) = @_;

    my $rotated = Message->new( $self->{ input } );
    my $rotated_input = $rotated->{ input };

    while ($rotated->rotate_based( $letter )->{ input } ne $self->{ input }) {
      # Try again, rotating the input left once
      $rotated->{ input } = $rotated_input;
      $rotated_input = $rotated->rotate( 'left', 1 )->{ input };
     }

    $self->{ input } = $rotated_input;

    return $self;
   }

  sub reverse_positions {
    my ($self, $from, $to) = @_;
 
    my $len = $to - $from + 1;
    my $string = substr( $self->{ input }, $from, $len );
    $string = join( '',  reverse split '', $string );
    substr( $self->{ input }, $from, $len ) = $string;

    return $self;
   }

  sub swap_letter {
    my ($self, $swapa, $swapb) = @_;

    die "Illegal characters in input" if (index( $self->{ input }, '*' ) >= 0);

    $self->{ input } =~ s/$swapa/\*/g;
    $self->{ input } =~ s/$swapb/$swapa/g;
    $self->{ input } =~ s/\*/$swapb/g;

    return $self;
   }

  sub swap_position {
    my ($self, $swapa, $swapb) = @_;

    my $posa = substr( $self->{ input }, $swapa, 1 );
    my $posb = substr( $self->{ input }, $swapb, 1 );

    substr( $self->{ input }, $swapa, 1 ) = $posb;
    substr( $self->{ input }, $swapb, 1 ) = $posa;

    return $self;
   }

  sub reverse_operation {
    my ($self, $op) = @_;

    if ($op =~ /^rotate (\w+) (\d+) step/) {
      my $dir = $1 eq 'right' ? 'left' : 'right';
      $self->rotate( $dir, $2 );
     }
    elsif ($op =~ /^rotate based on position of letter (\w)/) {
      $self->rotate_based_reverse( $1 );
     }
    elsif ($op =~ /^move position (\d+) to position (\d+)/) {
      $self->move( $2, $1 );
     }
    else {
      # All of the other operations are the same
      $self->operation( $op );
     }

    return $self;
   }

  sub operation {
    my ($self, $op) = @_;

    if ($op =~ /^swap position (\d+) with position (\d+)/) {
      $self->swap_position( $1, $2 );
     }
    elsif ($op =~ /^swap letter (\w) with letter (\w)/) {
      $self->swap_letter( $1, $2 );
     }
    elsif ($op =~ /^move position (\d+) to position (\d+)/) {
      $self->move( $1, $2 );
     }
    elsif ($op =~ /^rotate based on position of letter (\w)/) {
      $self->rotate_based( 'right', $1 );
     }
    elsif ($op =~ /^rotate (\w+) (\d+) step/) {
      $self->rotate( $1, $2 );
     }
    elsif ($op =~ /^reverse positions (\d+) through (\d+)/) {
      $self->reverse_positions( $1, $2 );
     }
    else {
      die "Unknown operation $op\n";
     }

    return $self;
   }

  sub new {
    my ($class, $input) = @_;
    my $self = {
      input => $input,
    };
    bless $self, $class;
   }
};

my $message = $ARGV[0] || 'decab';
my $input_file = $ARGV[1] || 'test21.txt';

my @commands = reverse read_file( $input_file );
my $input = Message->new( $message );

for my $cmd (@commands) {
  $input->reverse_operation( $cmd );
print "$cmd: $input->{ input }\n";
 }

print "The original message is $input->{ input }\n";
