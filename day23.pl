#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Assembler;

  my $tgl_inst = {
	'tgl' => 'inc',
	'inc' => 'dec',
	'dec' => 'inc',
	'cpy' => 'jnz',
	'jnz' => 'cpy',
   };

  sub get_value {
    my ($self, $arg) = @_;
   
    return ($arg =~ /^[-0-9]+$/) ? $arg : $self->get_register( $arg );
   }

  sub instruc {
    my ($self, $instr) = @_;
    my ($cmd, @data) = split /\s+/, $instr;

    if ($cmd eq 'cpy') {
      my $value = $self->get_value( $data[0] );
      $self->{ registers }{ $data[1] } = $value if ($data[1] =~ /^[a-z]$/);
     }
    elsif ($cmd eq 'inc') {
      $self->{ registers }{ $data[0] } ||= 0;
      $self->{ registers }{ $data[0] }++;
     }
    elsif ($cmd eq 'dec') {
      $self->{ registers }{ $data[0] } ||= 0;
      $self->{ registers }{ $data[0] }--;
     }
    elsif ($cmd eq 'jnz') {
      my $value = $self->get_value( $data[0] );
      if ($value) {
        my $lines = $self->get_value( $data[1] );
        if ($lines) {
          $self->{ line } += $lines;
          return $self;
         }
       }
     }
    elsif ($cmd eq 'tgl') {
      my $value = $self->get_value( $data[0] );
      if ($value) {
        my $tgl_line = $self->{ line } + $value;
        if ($tgl_line >= 0 && $tgl_line < @{ $self->{ instructions } }) {
          my ($tgl_cmd, @tgl_data) = split /\s+/, $self->{ instructions }[$tgl_line];
          $tgl_cmd = $tgl_inst->{ $tgl_cmd };
          $self->{ instructions }[$tgl_line] = join( ' ', ($tgl_cmd, @tgl_data) );
         }
       }
     }
    else {
      die "Illegal command $cmd";
     }

    $self->{ line }++;

    return $self;
  }

  sub get_register {
    my ($self, $reg) = @_;

    return $self->{ registers }{ $reg } || 0;
  }

  sub push_instruction {
    my ($self, $instr) = @_;

    push( @{ $self->{ instructions } }, $instr );
    return $self;
  }

  sub init {
    my ($self, $reg, $value) = @_;

    $self->{ registers }{ $reg } = $value;

    return $self;
   }

  sub run {
    my ($self) = @_;
    $self->{ line } = 0;
    while ($self->{ line } < @{ $self->{ instructions } }) {
      $self->instruc( $self->{ instructions }[$self->{ line }] );
     }

    return $self;
  }

  sub new {
    my $class = shift;
    my $self = { 
		registers => {},
		instructions => [],
        line => 0,
		};

    bless $self, $class;

    return $self;
  }
}

my $assembler = Assembler->new();

my $input_file = $ARGV[0] || 'input23.txt';

open my $input_fh, '<', $input_file or die $!;

while (<$input_fh>) {
  chomp;
  $assembler->push_instruction( $_ );
 }

#$assembler->run();

$assembler->init( 'a', 7 )->run();

print "The register a is ", $assembler->get_register( 'a' ), "\n";
