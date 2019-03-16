#!/usr/bin/env perl

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

    my $line_width        = 0.1;
    my $base_width        = 74.4 + 4 * $line_width;
    my $base_height       = 43 + 4 * $line_width;
    my $mounting_holes_dx = 71 - 3;
    my $mounting_holes_dy = 39.3 - 3;
    my $mounting_holes_r  = 3 / 2;
    my $drill_r           = 0.5;

    $ps = new PostScript::Simple(
        xsize    => $base_width,
        ysize    => $base_height,
        units    => "mm",
        colour   => 1,
        eps      => 1,
        reencode => undef
    );
    $ps->setcolour("red");
    $ps->setlinewidth($line_width);

    # draw hull
    my $hull = Math::CG::PointSet->new([[0, 0]]);
    $hull->clone_first($base_width, 0);
    $hull->clone_first($base_width, $base_height);
    $hull->clone_first(0,           $base_height);
    $ps->polygon($hull->as_array, $hull->first_point->as_array);

    # draw 4 holes
    my $sw_hole_x = (($base_width - $mounting_holes_dx) / 2);
    my $holes = Math::CG::PointSet->new([[$sw_hole_x, (($base_height - $mounting_holes_dy) / 2)]]);
    $holes->clone_first($mounting_holes_dx, 0);
    $holes->clone_first($mounting_holes_dx, $mounting_holes_dy);
    $holes->clone_first(0,                  $mounting_holes_dy);
    foreach my $hole (@{$holes->points}) {
        $ps->setcolour("black");
        $ps->circle({filled => 1}, $hole->as_array, $drill_r);
        $ps->setcolour("red");
        $ps->circle({filled => 0}, $hole->as_array, $mounting_holes_r);
    }

    # draw display around
    my $hull2 = Math::CG::PointSet->new([[$sw_hole_x - $mounting_holes_r + 5, 0]]);
    my $max_display_width = $mounting_holes_dx - 2 * (5 - $mounting_holes_r);
    $hull2->clone_first($max_display_width, 0);
    $hull2->clone_first($max_display_width, $base_height);
    $hull2->clone_first(0,                  $base_height);
    $ps->polygon($hull2->as_array, $hull2->first_point->as_array);

    # draw display visible
    my $visible_display_width  = 48.96;
    my $visible_display_height = 36.72;
    my $hull3                  = Math::CG::PointSet->new([
            [   $sw_hole_x - $mounting_holes_r + 8,
                $base_height - 43 + (43 - $visible_display_height) / 2
            ]
        ]
    );
    $hull3->clone_first($visible_display_width, 0);
    $hull3->clone_first($visible_display_width, $visible_display_height);
    $hull3->clone_first(0,                      $visible_display_height);
    $ps->polygon($hull3->as_array, $hull3->first_point->as_array);

    # draw display visible edge holes
    my $ve_edges = $hull3->points;
    $ve_edges->[0]->move($mounting_holes_r,$mounting_holes_r);
    $ve_edges->[1]->move(-$mounting_holes_r,$mounting_holes_r);
    $ve_edges->[2]->move(-$mounting_holes_r,-$mounting_holes_r);
    $ve_edges->[3]->move($mounting_holes_r,-$mounting_holes_r);
    foreach my $hole (@{$ve_edges}) {
        $ps->setcolour("black");
        $ps->circle({filled => 1}, $hole->as_array, $drill_r);
        $ps->setcolour("red");
        $ps->circle({filled => 0}, $hole->as_array, $mounting_holes_r);
    }

    $ps->output("nextion-nx3224t024_011.eps");

    exit(0);
}

__END__

=head1 SYNOPSIS

Generate a drill/cut/milling eps template for Nextion NX3224T024_011 touch display.

    ./nextion-nx3224t024_011.pl
        --help|h    print this help

^^^ will create nextion-nx3224t024_011.eps in local folder.

=head1 SEE ALSO

L<https://blog.kutej.net/2019/03/nextion-nx3224t024_011-drill-cut-milling>

=cut
