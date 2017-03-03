#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Node;

  sub new {
    my ($class, $input) = @_;

    return unless ($input =~ /\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+(\d+)%/);

    my $self = {
      x => $1,
      y => $2,
      size => $3,
      used => $4,
      avail => $5,
      pct => $6,
    };

    bless $self, $class;
   }
};

sub count_pairs
 {
  my $nodes = shift;

  my @by_avail = sort { $b->{ avail } <=> $a->{ avail } } @{ $nodes };
  my $pairs_cnt = 0;

  for (my $i = 0; $i < @{ $nodes }; $i++) {
     my $used = $nodes->[$i]{ used };
     next unless ($used > 0);
     my $avail_idx = 0;
     while ($by_avail[$avail_idx]->{ avail } > $used) {
       $pairs_cnt++;
       $avail_idx++;
      }
   }

  return $pairs_cnt;
 }

my $input_file = $ARGV[1] || 'input22.txt';

open my $input_fh, '<', $input_file or die $!;

my @nodes;

while (<$input_fh>) {
  chomp;
  my $node = Node->new( $_ );
  push @nodes, $node if ($node);
 }

my $pairs = count_pairs( \@nodes );
print "There are $pairs viable pairs\n";
exit;
