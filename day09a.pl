#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use File::Slurp;

sub decompress_input
 {
  my $input = shift;
  my $part_2 = shift;

  while ($input =~ /(\(\d+x\d+\))/g) {
    my $direct = $1;
    my $direct_len = length( $direct );

    # pos() is the next character *after* the match
    my $pos = pos( $input );
    my ($num_chars, $repeat) = ($direct =~ /(\d+)x(\d+)/);
    my $to_repeat = substr( $input, $pos, $num_chars );
    $to_repeat = decompress_input( $to_repeat, $part_2 ) if ($part_2);
    my $repeated = $to_repeat x $repeat;

    # Substitute the next n chars (and previous direction) with the repeat
    substr( $input, $pos - $direct_len, $direct_len + $num_chars ) = $repeated;

    pos( $input ) = $pos - $direct_len + length( $repeated );
   }

  return $input;
 }

my $input_file = $ARGV[0] || 'input09.txt';
my $part_2 = $ARGV[1];

my $raw_input = read_file( $input_file );
chomp $raw_input;

my $decompressed = decompress_input( $raw_input, $part_2 );

print "The length is ", length( $decompressed ), "\n";
