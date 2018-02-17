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
          # Check if this is a loop
          if ($lines == -2
          && $self->{ instructions }[$self->{ line } - 1] eq "dec $data[0]"
          && $self->{ instructions }[$self->{ line } - 2] =~ /^inc ([a-z])/) {
            $self->{ registers }{ $1 } += $self->{ registers }{ $data[0] };
            $self->{ registers }{ $data[0] } = 0;
           }
          elsif ($lines == -2
          && $self->{ instructions }[$self->{ line } - 2] eq "dec $data[0]"
          && $self->{ instructions }[$self->{ line } - 1] =~ /^inc ([a-z])/) {
            $self->{ registers }{ $1 } += $self->{ registers }{ $data[0] };
            $self->{ registers }{ $data[0] } = 0;
           }
          elsif ($lines == -2
          && $self->{ instructions }[$self->{ line } - 1] eq "inc $data[0]"
          && $self->{ instructions }[$self->{ line } - 2] =~ /^inc ([a-z])/) {
            $self->{ registers }{ $1 } += -$self->{ registers }{ $data[0] };
            $self->{ registers }{ $data[0] } = 0;
           }
          else {
            $self->{ line } += $lines;
            return $self;
           }
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
    elsif ($cmd eq 'out') {
      my $value = $self->get_value( $data[0] ) ? 1 : 0;

      # We are looking for a clock signal
      if (substr( $self->{ output }, -1 ) eq $value) {
        $self->{ clock } = -1;
       }
      else {
        $self->{ output } .= $value;
        # If the registers are exactly the same, we've been here before!
        my $regs = join( ',', values %{ $self->{ registers } } );
        if ($self->{ regs }{ $regs }) {
          $self->{ clock } = 1;
         }
        else {
          $self->{ regs }{ $regs } = 1;
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

    $self->{ registers } = {};
    $self->{ registers }{ $reg } = $value;

    return $self;
   }

  sub run {
    my ($self) = @_;
    $self->{ line } = 0;
    $self->{ output } = '';
    $self->{ clock } = 0;
    $self->{ regs } = {};
    while ($self->{ line } < @{ $self->{ instructions } } && !$self->{ clock } ) {
      $self->instruc( $self->{ instructions }[$self->{ line }] );
     }

    return ($self->{ clock } > 0);
  }

  sub new {
    my $class = shift;
    my $self = { 
		registers => {},
		instructions => [],
        line => 0,
        output => '',
        clock => 0,
        regs => {},
		};

    bless $self, $class;

    return $self;
  }
}

my $assembler = Assembler->new();

my $input_file = $ARGV[0] || 'input25.txt';

open my $input_fh, '<', $input_file or die $!;

while (<$input_fh>) {
  chomp;
  $assembler->push_instruction( $_ );
 }

my $test = 0;

while ( !$assembler->init( 'a', $test )->run() ) {
  $test++;
 }

print "Register a should be $test for a clock signal.\n";
