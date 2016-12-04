#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my $input_file = $ARGV[0] || 'input04.txt';

open my $input_fh, '<', $input_file or die $!;

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

sub is_real_room
 { 
  my ($enc_name) = @_;

  my ($name, $id, $checksum) = ($enc_name =~ /^([a-z-]+)-(\d+)\[([a-z]+)\]$/);
  warn "Can't parse room" unless ($checksum);

  my $calc_checksum = calc_checksum( $name );

  return ($calc_checksum eq $checksum ? $id : 0);
 }

my $sector_sum = 0;
while (<$input_fh>) {
  chomp;

  my $sector_id = is_real_room( $_ );
  $sector_sum += $sector_id;
 }

print "The sum of the sector IDs is $sector_sum\n";
