#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my @arr = qw/a b c/;
while (@arr) {
    my $e = shift(@arr);
    push @arr, 'd' if $e eq 'a';
    push @arr, 'e' if $e eq 'b';
    push @arr, 'f' if $e eq 'c';
    push @arr, 'g' if $e eq 'd';
    push @arr, 'h' if $e eq 'e';
    push @arr, 'i' if $e eq 'f';
    print $e;
}
print "\n";
