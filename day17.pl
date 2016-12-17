#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Digest::MD5 qw( md5_hex );

my $input = $ARGV[0] || 'hijkl';

{ package Route;

  my @dirs = qw( U D L R );

  sub new_path {
    my ($self, $dir) = @_;
 
    my $x = $self->{ x };
    my $y = $self->{ y };
    my $path = $self->{ path } . $dir;

    $y-- if ($dir eq 'U');
    $y++ if ($dir eq 'D');
    $x-- if ($dir eq 'L');
    $x++ if ($dir eq 'R');

    return if ($x < 0 || $x > 3 || $y < 0 || $y > 3);

    return Route->new( $x, $y, $path );
   }

  sub next_paths {
    my $self = shift;
    my @paths = ();

    my $hash = substr( Digest::MD5::md5_hex( "${input}$self->{ path }" ), 0, 4 );

    for (my $i = 0; $i < @dirs; $i++) {
      my $is_open = substr( $hash, $i, 1 );
      next unless ($is_open ge 'b' && $is_open le 'f');
      my $new_path = $self->new_path( $dirs[$i] );
      push @paths, $new_path if ($new_path);
     }

    return @paths;
  }

 sub at_end {
   my $self = shift;

   return ($self->{ x } == 3 && $self->{ y } == 3) ? $self->{ path } : '';
  }

 sub new {
   my ($class, $x, $y, $path) = @_;
   my $self = {
     path => $path,
     x => $x,
     y => $y,
   };

  bless $self, $class;
 }
}

my $paths = [ Route->new( 0, 0, '' ) ];

my $shortest = 0;
my $longest = 0;

my $count = 0;
while (1 && @{ $paths }) {
  my $next_paths = [];
  print "There are ", scalar( @{ $paths } ), " paths at $count\n";
  for my $path (@{ $paths }) {
    if (my $route = $path->at_end()) {
      warn "The shortest path is $route\n" unless ($shortest);
      $shortest = 1;
      $longest = length( $route ) if (length( $route ) > $longest);
      next;
     }

    push @{ $next_paths }, $path->next_paths();
   }

  $paths = $next_paths;
  $count++;
 }

print "The longest path is $longest\n";

