#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use File::Slurp;
use Data::Printer;

{ package Keypad;

  my $moves = {
	1 => { U => 1, D => 4, L => 1, R => 2 },
	2 => { U => 2, D => 5, L => 1, R => 3 },
	3 => { U => 3, D => 6, L => 2, R => 3 },
	4 => { U => 1, D => 7, L => 4, R => 5 },
	5 => { U => 2, D => 8, L => 4, R => 6 },
	6 => { U => 3, D => 9, L => 5, R => 6 },
	7 => { U => 4, D => 7, L => 7, R => 8 },
	8 => { U => 5, D => 8, L => 7, R => 9 },
	9 => { U => 6, D => 9, L => 8, R => 9 },
	};

  sub move {
    my $self = shift;
    my $dir = shift;

    $self->{ pos } = $moves->{ $self->{ pos } }{ $dir };

    return $self;
   }

  sub location {
    my $self = shift;

    return $self->{ pos };
  }

  sub new {
    my $class = shift;
    my $self = { 
		pos => 5,
		};

    bless $self, $class;

    return $self;
  }
}

my $combo = '';
my $keypad = Keypad->new();

my $input_file = $ARGV[0] || 'input02.txt';

open my $input_fh, '<', $input_file or die $!;

while (<$input_fh>) {
  chomp;
  for my $dir (split( '', $_ )) {
    $keypad->move( $dir ); 
   }
  $combo .= $keypad->location();
 }

print "The combination is $combo\n";
