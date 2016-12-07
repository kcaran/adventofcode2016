#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );

my $code = $ARGV[0] || die "Please enter the code\n";

my $num = 0;
my $password = '        ';
while (index( $password, ' ' ) >= 0) {
  my $md5 = md5_hex( sprintf "${code}%d", $num++ );
  next unless (substr( $md5, 0, 5 ) eq '00000');
  my $pos = substr( $md5, 5, 1 );
  next unless ($pos ge '0' && $pos le '7');
  next unless (substr( $password, $pos, 1 ) eq ' ');
  substr( $password, $pos, 1 ) = substr( $md5, 6, 1 );
  print "The password is '$password'\n";
 }
