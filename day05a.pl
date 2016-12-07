#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );

my $code = $ARGV[0] || die "Please enter the code\n";

my $num = 0;
my $password = '';
while (length($password) < 8) {
  my $md5 = md5_hex( sprintf "${code}%d", $num++ );
  next unless (substr( $md5, 0, 5 ) eq '00000');
  $password .= substr( $md5, 5, 1 );
 }

print "The password is $password\n";
