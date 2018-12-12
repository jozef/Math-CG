#!/usr/bin/env perl

use Test::Most;
use strict;
use warnings;

use_ok('Math::CG::Point');
use_ok('Math::CG::Triangle');

subtest 'BUILD' => sub {
    my $pt2 = Math::CG::Point->new(x => 0, y => 1);
    my $pt3 = Math::CG::Point->new(x => 2, y => 3, z => 0);
    my $pt31 = Math::CG::Point->new([4, 5, 6]);
    is($pt2->dimensions,  2, 'auto set number of dimensions from new() arguments');
    is($pt3->dimensions,  3, 'auto set number of dimensions from new() arguments');
    is($pt31->dimensions, 3, 'auto set number of dimensions from new() arguments');
    is($pt2->x,           0, 'x dimension from new() arguments');
    is($pt3->z,           0, 'z dimension from new() arguments');
    is($pt31->y,          5, 'y dimension from new() arguments');
};

subtest 'override' => sub {
    my $pt0 = Math::CG::Point->new(x => 0, y => 0);
    is($pt0->as_string, $pt0 . '', 'stringification');
    is($pt0->as_string, '[0,0]',   'stringification');

    my $pt1 = Math::CG::Point->new(x => 2, y => 3);
    my $pt2 = Math::CG::Point->new(x => 2, y => 3);
    cmp_ok($pt0, '!=', $pt1, '!=');
    cmp_ok($pt1, '==', $pt2, '==');
};

subtest 'methods' => sub {
    my $pt0 = Math::CG::Point->new(x => 0, y => 0);
    my $p1  = Math::CG::Point->new(x => 1, y => 0);
    my $p2  = Math::CG::Point->new(x => 0, y => -1);
    ok(!$pt0->left_of($p1, $p2), 'left_of()');
    ok($pt0->left_of($p2, $p1), 'left_of()');

    my $p3 = $p1->clone();
    ok($p3->is_equal($p1),  'is_equal()');
    ok(!$p3->is_equal($p2), 'is_equal()');

    my $p4 = $pt0->clone()->move(0.5, 0)->move(0.5, 0);
    ok($p4->is_equal($p1), 'move()');
    $p4->move({x => -1, y => -1});
    ok($p4->is_equal($p2), 'move()');

    # between
    my @between_tests = (
        {ok => 1, p => [0,  0],  a => [-1, 0],  b => [1, 0]},    # horizontal line
        {ok => 1, p => [0,  0],  a => [0,  -1], b => [0, 1]},    # vertical line
        {ok => 1, p => [0,  0],  a => [0,  0],  b => [0, 1]},    # same point
        {ok => 1, p => [1,  1],  a => [1,  1],  b => [3, 3]},    # same point
        {ok => 1, p => [1,  1],  a => [1,  1],  b => [1, 1]},    # same point
        {ok => 1, p => [2,  2],  a => [1,  1],  b => [3, 3]},    # on 45° line
        {ok => 1, p => [2,  2],  a => [1,  3],  b => [3, 1]},    # on -45° line
        {ok => 0, p => [-2, 0],  a => [-1, 0],  b => [1, 0]},    # outside horizontal line
        {ok => 0, p => [0,  -2], a => [0,  -1], b => [0, 1]},    # outside vertical line
        {ok => 0, p => [0,  0],  a => [1,  1],  b => [3, 3]},    # outside 45° line
        {ok => 0, p => [4,  0],  a => [1,  3],  b => [3, 1]},    # outside -45° line
    );
    foreach my $btest (@between_tests) {
        map {$btest->{$_} = Math::CG::Point->new($btest->{$_})} qw(p a b);
        is( !!$btest->{p}->between($btest->{a}, $btest->{b}),
            !!$btest->{ok},
            ($btest->{ok} ? '' : 'not ')
                . $btest->{p}
                . '->between('
                . $btest->{a} . ','
                . $btest->{b} . ')'
        );
        is( !!$btest->{p}->between($btest->{b}, $btest->{a}),
            !!$btest->{ok},
            ($btest->{ok} ? '' : 'not ')
                . $btest->{p}
                . '->between('
                . $btest->{b} . ','
                . $btest->{a} . ')'
        )
    }
};

done_testing;

