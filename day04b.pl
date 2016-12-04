#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub calc_checksum
 {
  my ($name) = @_;
  my $checksum;
  my %chars;

  for my $char (grep { $_ ne '-' } split '', $name) {
    $chars{ $char }++;
   }

  my @sorted_chars = sort {
    ($chars{ $b } <=> $chars{ $a }) || ($a cmp $b);
  } keys %chars;

  $checksum = join( '', @sorted_chars[0..4] );

  return $checksum;
 }

sub decode_name
 {
  my ($room) = @_;

  my $shift = $room->{ id } % 26;
  my $decoded_name;
  my $ascii_start = 97;

  for my $char (split '', $room->{ name }) {
    if ($char eq '-') {
      $decoded_name .= ' ';
      next;
     }
    my $new_char = chr( (ord( $char ) - $ascii_start + $shift) % 26 + $ascii_start );
    $decoded_name .= $new_char;
   }

  return $decoded_name;
 }

sub is_real_room
 { 
  my ($room) = @_;

  my $calc_checksum = calc_checksum( $room->{ name } );

  return ($calc_checksum eq $room->{ checksum });
 }

sub parse_enc_name
 {
  my ($enc_name) = @_;
  my $room;

  @{ $room }{ qw( name id checksum ) } = ($enc_name =~ /^([a-z-]+)-(\d+)\[([a-z]+)\]$/);

  return $room;
 }

my $input_file = $ARGV[0] || 'input04.txt';

open my $input_fh, '<', $input_file or die $!;

my $sector_sum = 0;
while (<$input_fh>) {
  chomp;

  my $room = parse_enc_name( $_ );

  next unless (is_real_room( $room ));

  my $decoded_name = decode_name( $room );

  if (($decoded_name =~ /north/i)
   && ($decoded_name =~ /pole/i)
   && ($decoded_name =~ /object/i)) {
    print "Decoded to $decoded_name $room->{ id }\n";
    exit;
   }
 }

