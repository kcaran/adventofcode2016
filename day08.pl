#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Screen;

  sub command {
    my $self = shift;
    my $cmd = shift;

    if ($cmd =~ /rect (\d+)x(\d+)/) {
      $self->rectangle( $1, $2 );
      return $self;
     }
    if ($cmd =~ /rotate row y=(\d+) by (\d+)/) {
      $self->rotate_row( $1, $2 );
      return $self;
     }
    if ($cmd =~ /rotate column x=(\d+) by (\d+)/) {
      $self->rotate_column( $1, $2 );
      return $self;
     }

    die "Illegal command: $cmd";
    return $self;
   }

  sub rectangle {
    my ($self, $width, $height) = @_;

    for (my $x = 0; $x < $width; $x++) {
      for (my $y = 0; $y < $height; $y++) {
        $self->{ pixels }[$y][$x] = 1;
       }
     }

    return $self;
   }

  sub rotate_column {
    my ($self, $column, $size) = @_;

    # Rotate column iteratively for the size amount
    for (my $i = 0; $i < $size; $i++) {
      my $y = $self->{ height } - 1;
      my $last_value = $self->{ pixels }[$y][$column];

      while ($y) {
        $self->{ pixels }[$y][$column] = $self->{ pixels }[$y - 1][$column];
        $y--;
       }
      $self->{ pixels }[0][$column] = $last_value;
     }
 
    return $self;
   }

  sub rotate_row {
    my ($self, $row, $size) = @_;

    # Rotate row iteratively for the size amount
    for (my $i = 0; $i < $size; $i++) {
      my $x = $self->{ width } - 1;
      my $last_value = $self->{ pixels }[$row][$x];

      while ($x) {
        $self->{ pixels }[$row][$x] = $self->{ pixels }[$row][$x - 1];
        $x--;
       }
      $self->{ pixels }[$row][0] = $last_value;
     }
 
    return $self;
   }

  sub pixels_lit {
    my $self = shift;
    my $pixel_count = 0;

    for (my $y = 0; $y < $self->{ height }; $y++) {
      for (my $x = 0; $x < $self->{ width }; $x++) {
        $pixel_count++ if ( $self->{ pixels }[$y][$x] );
       }
     }

    return $pixel_count;
   }

  sub message {
    my $self = shift;
    my $message;
    for (my $y = 0; $y < $self->{ height }; $y++) {
      for (my $x = 0; $x < $self->{ width }; $x++) {
        $message .= $self->{ pixels }[$y][$x] ? '*' : ' ';
       }
      $message .= "\n";
     }
   return $message;
  }

  sub new {
    my ($class, $width, $height ) = @_;
    my $self = {
		pixels => [],
		width => $width,
		height => $height,
		};

    for (my $y = 0; $y < $self->{ height }; $y++) {
      for (my $x = 0; $x < $self->{ width }; $x++) {
        $self->{ pixels }[$y][$x] = 0;
       }
     }
  
    bless $self, $class;
  }
}

my $input_file = $ARGV[0] || 'input08.txt';

open my $input_fh, '<', $input_file or die $!;

my $test = Screen->new( 50, 6 );

while (<$input_fh>) {
  chomp;
  $test->command( $_ );
  next;
 }

print "The number of lit pixels is ", $test->pixels_lit(), "\n";

print $test->message();
