#!/usr/bin/env perl

use Test::Most;
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

done_testing;

