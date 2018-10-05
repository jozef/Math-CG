#! /usr/bin/env perl

use strict;
use warnings;

use PostScript::Simple 0.06;
use Getopt::Long;
use Pod::Usage;

use Math::CG::Point;
use Math::CG::PointSet;

exit main() unless caller;

sub main {
    my $ps;
    my $eps;
    my $directeps;
    my $y;

    my $help;
    GetOptions('help|h' => \$help,) or pod2usage;
    pod2usage if $help;

    $ps = new PostScript::Simple(
        xsize    => 110,
        ysize    => 100,
        units    => "mm",
        colour   => 1,
        eps      => 1,
        reencode => undef
    );
    $ps->setcolour("red");
    $ps->setlinewidth("thin");

    # draw hull
    my $width        = 102.5;
    my $height       = 83.1;
    my $sec_middle_y = 13.5;
    my $sec1_y       = ($height - $sec_middle_y) / 2;
    my $ledge_x      = 1.6;
    my $hull         = Math::CG::PointSet->new([[0, 0]]);
    $hull->clone_last($width,    0);
    $hull->clone_last(0,         $sec1_y);
    $hull->clone_last(-$ledge_x, 0);
    $hull->clone_last(0,         $sec_middle_y);
    $hull->clone_last($ledge_x,  0);
    $hull->clone_last(0,         $sec1_y);
    $hull->clone_last(-$width,   0);
    $hull->clone_last(0,         -$sec1_y);
    $hull->clone_last($ledge_x,  0);
    $hull->clone_last(0,         -$sec_middle_y);
    $hull->clone_last(-$ledge_x, 0);
    $ps->polygon($hull->as_array, $hull->first_point->as_array);

    # draw 4 holes
    my $hole_dx = 91 -   (2 * 1.3) - (2 * 1.2);
    my $hole_dy = 55.9 - (2 * 1.3) - (2 * 1.2);
    my $hole_r  = 3 / 2;
    my $holes =
        Math::CG::PointSet->new([[(($width - $hole_dx) / 2), (($height - $hole_dy) / 2)]]);
    $holes->clone_first($hole_dx, 0);
    $holes->clone_first(0,        $hole_dy);
    $holes->clone_first($hole_dx, $hole_dy);
    foreach my $hole (@{$holes->points}) {
        $ps->circle({filled => 1}, $hole->as_array, $hole_r);
    }

    $ps->output("base-plate.eps");

    exit(0);
}

__END__

=head1 SYNOPSIS

generate a base plate eps drawing

    ./base-plate.pl
        --help|h    print this help

=cut
