#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Map;

  my $top_floor = 3;
# my @elements = qw( h l );
# my @elements = qw( po th pr ru co );
  my @elements = qw( po th pr ru co el di );

  sub fried_micros {
    my $items = shift;
    my %floors;

    for my $elem (@elements) {
      # OK if we have our own generator
      my $mfloor = $items->{ "${elem}m" };
      next if ($mfloor eq $items->{ "${elem}g" });

      # Check if there are any other generators on our floor
      for my $gen_elem (@elements) {
        next if ($gen_elem eq $elem);
        return 1 if ($items->{ "${gen_elem}g" } == $mfloor);
       }
     }

    return 0;
   }

  sub from_legend {
    my $legend = shift;
    my $items = { split( /(\d+)/, $legend ) };
    
    my @floor_range = sort values %{ $items };

    return if (fried_micros( $items ));

    return { legend => $legend, items => $items,
		max_floor => $floor_range[-1],
		min_floor => $floor_range[0],
	};
   }

  sub go_up {
    my $self = shift;
    my $efloor = $self->{ items }{ E };

    # Don't bother going up if there are still things below us
    return if ($efloor == $top_floor);
    return if $efloor == $self->{ max_floor } && ($self->{ max_floor } - $self->{ min_floor }) > 1;
    return 1;
   }

  sub go_down {
    my $self = shift;
    my $efloor = $self->{ items }{ E };

    # Don't bother going down if not necessary
    return ($efloor != $self->{ min_floor });
   }

  sub to_legend {
    my $items = shift;
    my $legend = 'E' . $items->{ E };
    for my $elem (@elements) {
      $legend .= "${elem}g" . $items->{ "${elem}g" };
      $legend .= "${elem}m" . $items->{ "${elem}m" };
     }

    return $legend;
   }

  sub next_steps {
    my $self = shift;
    my $efloor = $self->{ items }{ E };
    my @onfloor = map { $_ ne 'E' && $self->{ items }{ $_ } == $efloor ? $_ : () } keys %{ $self->{ items } };
    my @next_steps;

    for (my $i = 0; $i < @onfloor; $i++) {
      # Going up - don't bother if we are at highest
      if ($self->go_up()) {
        my %new = %{ $self->{ items } };
        $new{ E }++;
        $new{ $onfloor[$i] }++;
        push @next_steps, to_legend( \%new );

        # Going up - Also add other items
        for (my $j = $i + 1; $j < @onfloor; $j++) {
          my %new2 = %new;
          $new2{ $onfloor[$j] }++;
          push @next_steps, to_legend( \%new2 );
         }
       }
      if ($self->go_down()) {
        # Going down - first just this item
        my %new = %{ $self->{ items } };
        $new{ E }--;
        $new{ $onfloor[$i] }--;
        push @next_steps, to_legend( \%new );

        # Going down - Also add other items
        for (my $j = $i + 1; $j < @onfloor; $j++) {
          my %new2 = %new;
          $new2{ $onfloor[$j] }--;
          push @next_steps, to_legend( \%new2 );
         }
       }
     }
    return @next_steps;
   }

  sub top_floor {
    my $self = shift;

    return (grep { $self->{ items }{ $_ } != $top_floor } keys %{ $self->{ items } }) ? 0 : 1;
   }

  sub new {
    my ($class, $legend) = @_;

    my $self = from_legend( $legend );

    return unless $self;
    bless $self, $class;
   }
}

#my $init = "E0hg1hm0lg2lm0";
#my $init = "E0pog0pom1thg0thm0prg0prm1rug0rum0cog0com0";
my $init = "E0pog0pom1thg0thm0prg0prm1rug0rum0cog0com0elg0elm0dig0dim0";
my $count = 0;
my @maps = ( Map->new( $init ) );
my %legends;
$legends{ $init } = 1;

while (1) {
  print "We are at count $count\n";
  my @new_maps = ();
  for my $map (@maps) {
    die "We did it in $count steps" if ($map->top_floor());
    my @next_steps = $map->next_steps();
    for my $step_legend (@next_steps) {
      next if ($legends{ $step_legend });
      $legends{ $step_legend } = 1;
      my $step = Map->new( $step_legend );
      push @new_maps, $step if ($step);
     } 
   }
  @maps = @new_maps;
  $count++;
 }
