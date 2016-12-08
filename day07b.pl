#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my $input_file = $ARGV[0] || 'input07.txt';

open my $input_fh, '<', $input_file or die $!;

sub find_abas
 {
  my @ip = split '', shift;
  my @abas;

  my $in_brackets = 0;
  for (my $i = 0; $i < @ip - 2; $i++) {
    if ($ip[$i] eq '[') {
      $in_brackets = 1;
      next;
     }

    if ($ip[$i] eq ']') {
      $in_brackets = 0;
      next;
     }

    next if ($in_brackets);
    next if ($ip[$i+1] eq '[');

    if ($ip[$i] eq $ip[$i + 2] && $ip[$i] ne $ip[$i + 1]) {
      push @abas, join( '', @ip[$i..$i+2] );
     }
   }

  return @abas;
 }

sub has_bab
 {
  my ($ip, $aba) = @_;

  my $bab = $aba;
  $bab =~ s/^(\w)(\w)(\w)$/$2$1$2/;

  return $ip =~ /\[(?:[^]]*)$bab(?:[^]]*)\]/;
 }

sub supports_ssl
 {
  my $ip = shift;

  my @abas = find_abas( $ip );

  for my $aba (@abas) {
    return 1 if (has_bab( $ip, $aba ));
   }
  return 0;
 }

my $count = 0;
while (<$input_fh>) {
  chomp;

  $count++ if (supports_ssl( $_ ));
 }

print "The number of addresses supporting ssl is $count\n";

