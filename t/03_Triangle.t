#!/usr/bin/env perl

use Test::Most;
use strict;
use warnings;

use_ok('Math::CG::Triangle');

subtest 'BUILD' => sub {
    my $triangle = Math::CG::Triangle->new(points => [[1, 1], [2, 1], [1, 2]]);
    is($triangle->count, 3, 'points from new() arguments');

    # TODO exception when more than three points
};

subtest 'methods' => sub {
    my $triangle = Math::CG::Triangle->new(points => [[0, 0], [2, 0], [0, 2]]);
    is($triangle->area,  2, 'area(' . $triangle . ')');
    is($triangle->area2, 4, 'area2(' . $triangle . ')');
    my $triangle2 = Math::CG::Triangle->new(points => [[0, 0], [0, 2], [2, 0]]);
    is($triangle2->area2, -4, 'area2(' . $triangle2 . ')');
};

subtest 'encloses' => sub {
    my $p3 = Math::CG::Point->new(x => 1,  y => 1);
    my $p4 = Math::CG::Point->new(x => -1, y => 1);
    my $t1 = Math::CG::Triangle->new([[0.5, 0.5], [3, 0], [0, 3]]);
    my $t2 = Math::CG::Triangle->new([[0,   0],   [0, 3], [3, 0]]);
    ok($t1->encloses($p3),  'is_inside()');
    ok($t2->encloses($p3),  'is_inside()');
    ok(!$t1->encloses($p4), 'is_inside()');
    ok(!$t2->encloses($p4), 'is_inside()');
};

done_testing;

