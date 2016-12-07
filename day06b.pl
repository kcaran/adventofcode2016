#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Code;

  sub add_signal {
    my $self = shift;
    my @signal = split '', shift;

    for (my $i = 0; $i < @signal; $i++) {
      $self->{ letters }[$i]{ $signal[$i] }++;
     }

    return $self;
  }

  sub decode {
    my $self = shift;
    my $decoded_string = '';

    for my $letter (@{ $self->{ letters } }) {
      $decoded_string .= $self->least_frequent( $letter ); 
     }

    return $decoded_string;
  }

  sub least_frequent {
    my $self = shift;
    my $letter = shift;
    my $min = 0;
    my $char = '';
    for my $key (keys %{ $letter }) {
      if (!$char || $letter->{ $key } < $min) {
        $char = $key;
        $min = $letter->{ $key };
       }
     }

    return $char;
  }

  sub most_frequent {
    my $self = shift;
    my $letter = shift;
    my $max = 0;
    my $char = '';
    for my $key (keys %{ $letter }) {
      if ($letter->{ $key } > $max) {
        $char = $key;
        $max = $letter->{ $key };
       }
     }

    return $char;
  }

  sub new {
    my $class = shift;
    my $self = {
		letters => [],
		};
    bless $self, $class;

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input06.txt';

open my $input_fh, '<', $input_file or die $!;

my $code = Code->new();

while (<$input_fh>) {
  chomp;

  $code->add_signal( $_ );
 }

print "The code is ", $code->decode(), "\n";
