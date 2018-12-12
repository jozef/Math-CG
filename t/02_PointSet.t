#!/usr/bin/env perl

use Test::Most;
use File::Basename qw(basename);

use strict;
use warnings;

use_ok('Math::CG::PointSet') or exit(1);

subtest 'BUILD' => sub {
    my $ptset = Math::CG::PointSet->new(points => [[1, 1], [2, 1], [1, 2]]);
    is($ptset->count,          3, 'points from new() arguments');
    is($ptset->points->[1]->x, 2, 'points from new() arguments');
    is($ptset->points->[2]->y, 2, 'points from new() arguments');
    is($ptset->dimensions,     2, 'points from new() arguments');
};

subtest 'methods' => sub {
    my $ptset = Math::CG::PointSet->new(points => [[0, 0], [0, 1], [1, 0]]);
    is($ptset->as_string, $ptset . '',           'stringification');
    is($ptset->as_string, '[[0,0],[0,1],[1,0]]', 'stringification');
    ok($ptset->first_point->is_equal(Math::CG::Point->new([0, 0])), 'first_point()');
    ok($ptset->last_point->is_equal(Math::CG::Point->new([1, 0])), 'last_point()');
    is_deeply([$ptset->as_array], [0, 0, 0, 1, 1, 0], 'as_array()');

    $ptset->clone_last(1,1);
    is_deeply([$ptset->as_array], [0, 0, 0, 1, 1, 0, 2, 1], 'clone_last()');
    $ptset->clone_first(0,1);
    eq_or_diff([$ptset->as_array], [0, 0, 0, 1, 1, 0, 2, 1, 0 , 1], 'clone_first()');
};

subtest 'encloses()' => sub {
    my $ptset = Math::CG::PointSet->new(points => [[0, 0], [0, 1], [1, 0]]);
    # 3 points (similar tests in 03_Triangle.t)
    ok($ptset->encloses(Math::CG::Point->new([0, 0])), 'encloses() edge point');
    ok($ptset->encloses(Math::CG::Point->new([0, 1])), 'encloses() edge point');
    ok($ptset->encloses(Math::CG::Point->new([0.5, 0.5])), 'encloses() inside point');
    ok(!$ptset->encloses(Math::CG::Point->new([0.5, 1])), 'encloses() outside point');

    # 3+ points
    my $ptset2 =
        Math::CG::PointSet->new(points => [[2, 2], [0, 0], [2, 0], [0, 2]]);
    ok($ptset2->encloses(Math::CG::Point->new([1, 1])), 'encloses() inside point that sits on triangle edge');
    ok($ptset2->encloses(Math::CG::Point->new([1, 2])), 'encloses() inside point that sits on triangle edge');
    ok(!$ptset2->encloses(Math::CG::Point->new([1, 2.1])), 'encloses() outside point');

    my $ptset3 =
        Math::CG::PointSet->new(points => [[2, 2], [0, 0], [1, 3], [2, 0], [3, 1], [0, 2]]);
    ok($ptset3->encloses(Math::CG::Point->new([0.5, 2])), 'encloses() inside point');
    ok(!$ptset3->encloses(Math::CG::Point->new([2.5, 1])), 'encloses() outside point');
};

subtest 'extremes' => sub {
    my $ptset = Math::CG::PointSet->new(points => [[1, 1], [1, 5], [2, 3], [3, 2], [4, 4], [5, 0]]);
    ok($ptset->check_edge(0, 1), 'check_edge()');
    ok(!$ptset->check_edge(0, 2), 'check_edge()');
    ok(!$ptset->check_edge(0, 3), 'check_edge()');
    ok(!$ptset->check_edge(0, 4), 'check_edge()');
    ok($ptset->check_edge(0, 5), 'check_edge()');
    ok($ptset->check_edge(4, 5), 'check_edge()');

    # ? that about points on a straight line?

    eq_or_diff($ptset->extremes_idx, [0, 1, 4, 5], 'extremes_idx()',);
};

subtest 'Graham Scan' => sub {
    my @sorted_point_set = (
        [1, 1], [2, 1], [7, 1], [6, 2], [4, 2], [4, 3], [7, 5], [2, 2],
        [3, 3], [5, 6], [3, 4], [2, 5], [1, 2], [1, 3], [0, 3], [0, 2],
    );
    my @hull_point_set =
        ([1, 1], [2, 1], [7, 1], [7, 5], [5, 6], [2, 5], [0, 3], [0, 2],);
    my @random_point_set = sort { int( rand(3) ) - 1 } @sorted_point_set;
    my $ptset  = Math::CG::PointSet->new( points => \@random_point_set );
    my $ptset2 = Math::CG::PointSet->new( points => \@random_point_set );
    my @ltl_point = @{ $ptset->ltl_point->coords };
    eq_or_diff( \@ltl_point, [ 1, 1 ], 'ltl_point()' )
        or return diag(
              'please check input data, without correct ltl point all other test here will fail');

    $ptset->sort();
    eq_or_diff( [ map { $_->coords } @{ $ptset->points } ], \@sorted_point_set, 'sort()' );
    eq_or_diff( [ map { $_->coords } @{ $ptset2->hull_graham_scan } ],  \@hull_point_set,   'hull_graham_scan()' );

    if ($ENV{DEBUG_FILES}) {
        eval q{
            use PostScript::Simple 0.06;
            my $ps = new PostScript::Simple(
                xsize    => 10,
                ysize    => 10,
                units    => "mm",
                colour   => 1,
                eps      => 1,
                reencode => undef
            );
            $ps->setcolour("red");
            $ps->setlinewidth( 0.01 );
            $ps->setfont("Times-Roman", 0.6);
            $ps->setcolour("red");
            foreach my $point (@{$ptset->points}) {
                $ps->circle({filled => 1}, $point->as_array, 0.05);
                $ps->line(@ltl_point, $point->as_array);
            }
            $ps->setcolour("blue");
            $ps->polygon( ( map { $_->as_array } @{ $ptset->hull } ), @ltl_point );
            my $i = 1;
            foreach my $point (@{$ptset->points}) {
                $ps->setcolour("black");
                $ps->circle({filled => 1}, $point->as_array, 0.02);
                $ps->text((map { $_ + 0.04 } $point->as_array), sprintf("%d [%d,%d]", $i++,$point->as_array));
            }
            $ps->output("examples/".basename($0)."-Graham-Scan.eps");
        };
        die $@ if $@;
    }
};

done_testing;
