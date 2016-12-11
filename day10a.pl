#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

my @bots = ();
my @outputs = ();

{ package Output;

  sub add {
    my ($self, $a) = @_;

    $self->{ value } = $a;

    return $self;
   }

  sub new {
    my $class = shift;
    my $num = shift;

    my $self = {
		num => $num,
		value => '',
		};
    bless $self, $class;
  }
}

{ package Bot;

  my $low_val = 17;
  my $high_val = 61;

  sub add {
    my ($self, $a) = @_;

    push @{ $self->{ chips } }, $a;

    warn "Bot $self->{ num } compares $low_val with $high_val\n" if ($self->equals( $low_val, $high_val ));

    if (@{ $self->{ chips } } == 2) {
      my $low_bot = $self->{ low_bot };
      my $high_bot = $self->{ high_bot };
      if ($self->{ chips }[0] < $self->{ chips }[1]) {
        $low_bot->add( $self->{ chips }[0] );
        $high_bot->add( $self->{ chips }[1] );
       }
      else {
        $low_bot->add( $self->{ chips }[1] );
        $high_bot->add( $self->{ chips }[0] );
       }

      $self->{ chips } = [];
     }
 
    return $self;
   }

  sub distribute_rules {
    my ($self, $low_bot, $high_bot) = @_;

    $self->{ low_bot } = $low_bot;
    $self->{ high_bot } = $high_bot;

    return $self;
   }

  sub equals {
    my ($self, $a, $b) = @_;

    return unless (@{ $self->{ chips } } == 2);

    return ($self->{ chips }[0] == $a && $self->{ chips }[1] == $b)
		|| ($self->{ chips }[0] == $b && $self->{ chips }[1] == $a);
   }

  sub new {
    my $class = shift;
    my $num = shift;

    my $self = {
		num => $num,
		chips => [],
		low_bot => '',
		high_bot => '',
		};
    bless $self, $class;
  }
}

sub get_bot
 {
  my $num = shift;

  $bots[$num] = Bot->new( $num ) unless $bots[$num];

  return $bots[$num];
 }

sub get_output
 {
  my $num = shift;

  $outputs[$num] = Output->new( $num ) unless $outputs[$num];

  return $outputs[$num];
 }

sub init_values
 {
  my $inst = shift;

  if ($inst =~ /value (\d+) goes to bot (\d+)/) {
    my $value = $1;
    my $bot = get_bot( $2 );
    $bot->add( $value );
   }

  return;
 }

sub set_distribution
 {
  my $inst = shift;

  if ($inst =~ /bot (\d+) gives low to (\S+) (\d+) and high to (\S+) (\d+)/) {
    my $num = get_bot( $1 );
    my $low = ($2 eq 'output') ? get_output( $3 ) : get_bot( $3 );
    my $high = ($4 eq 'output') ? get_output( $5 ) : get_bot( $5 );
    
    $num->distribute_rules( $low, $high );
   }

  return;
 }

my @instructions = ();

my $input_file = $ARGV[0] || 'input10.txt';
open my $input_fh, '<', $input_file or die $!;

while (<$input_fh>) {
  chomp;
  push @instructions, $_;
 }

for my $inst (@instructions) {
  set_distribution( $inst );
 }

for my $inst (@instructions) {
  init_values( $inst );
 }

exit;
