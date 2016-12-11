#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use File::Slurp;

{ package Input;

  sub decompress {
    my $self = shift;

    while ($self->{ string } =~ /(\(\d+x\d+\))/g) {
      my $direct = $1;
      my $direct_len = length( $direct );

      # pos() is the next character *after* the match
      my $pos = pos( $self->{ string } );

      my ($num_chars, $repeat) = ($direct =~ /(\d+)x(\d+)/);

      my $to_repeat = Input->new( substr( $self->{ string }, $pos, $num_chars ) );
      $to_repeat->decompress();

      $self->{ chars_decoded } += $to_repeat->total_length() * $repeat;

      # Remove the command and repeated portion
      substr( $self->{ string }, $pos - $direct_len, $direct_len + $num_chars ) = '';

      pos( $self->{ string } ) = $pos - $direct_len;
     }
  }

  sub total_length {
    my $self = shift;
    return length( $self->{ string } ) + $self->{ chars_decoded };
  }

  sub new {
    my $class = shift;
    my $input = shift;

    my $self = {
		string => $input,
		chars_decoded => 0,
		};
    bless $self, $class;
  }
}

my $input_file = $ARGV[0] || 'input09.txt';

my $raw_input = read_file( $input_file );
chomp $raw_input;

my $input = Input->new( $raw_input );
$input->decompress();

print "The length is ", $input->total_length(), "\n";
