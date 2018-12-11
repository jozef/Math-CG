package Math::CG::PointSet;

use Math::CG::Point;

use Moose;
use Carp::Clan qw(croak);
use List::Util qw(max);
use JSON::XS qw(encode_json);

has 'points' => (is => 'rw', isa => 'ArrayRef', default => sub {[]}, lazy => 1);

use overload
    '""' => \&as_string,
    ;

sub count {return scalar(@{$_[0]->points})}

sub dimensions {
    return max(map {$_->dimensions} @{$_[0]->points});
}

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my %args;
    if (@_ == 1) {
        if (ref($_[0]) eq 'ARRAY') {
            $args{points} = $_[0];
        }
        elsif (ref($_[0]) eq 'HASH') {
            %args = %{$_[0]};
        }
        else {
            croak 'bad argument ' . $_[0];
        }
    }
    else {
        %args = @_;
    }

    $args{points} = [map {blessed($_) ? $_ : Math::CG::Point->new($_)} @{$args{points}}];

    # ? what about duplicated points ? will thay cause troubles with the math?

    return $class->$orig(%args);
};

sub as_string {
    my ($self) = @_;
    return encode_json([map {[$_->as_array]} @{$self->points}]);
}

sub check_edge {
    my ($self, $p1_idx, $p2_idx) = @_;
    my $left_empty  = 1;
    my $right_empty = 1;
    my $p1          = $self->points->[$p1_idx];
    my $p2          = $self->points->[$p2_idx];
    foreach my $idx (0 .. $self->count - 1) {
        next if ($p1_idx == $idx) || ($p2_idx == $idx);
        my $p = $self->points->[$idx];
        if ($p->left_of($p1, $p2)) {
            $left_empty = 0;
        }
        else {
            $right_empty = 0;
        }
        last if !$left_empty && !$right_empty;
    }
    return $left_empty || $right_empty;
}

sub extremes_idx {
    my ($self) = @_;
    my %extrm_idx;
    foreach my $idx1 (0 .. $self->count - 2) {
        foreach my $idx2 ($idx1 + 1 .. $self->count - 1) {
            if ($self->check_edge($idx1, $idx2)) {
                $extrm_idx{$idx1} = 1;
                $extrm_idx{$idx2} = 1;
            }
        }
    }
    return [sort keys %extrm_idx];
}

sub encloses {
    my ($self, $point) = @_;
    if ($self->count < 3) {
        croak 'huh?';
    }
    elsif ($self->count == 3) {
        my $to_left_sum = 0;
        foreach my $tp1_idx (0 .. 2) {
            my $tp2_idx = ($tp1_idx == 2 ? 0 : $tp1_idx + 1);
            $to_left_sum += (
                $point->left_of($self->points->[$tp1_idx], $self->points->[$tp2_idx])
                ? 1
                : -1
            );
            return 0 if ($to_left_sum == 0);    # early exit after two iterations
        }

        # inside the triangle if located always to the left or always to the right of the edges
        return abs($to_left_sum) == 3;
    }
    else {
        croak 'TODO';
    }
}

sub as_array {
    my ($self) = @_;
    return map {$_->as_array} @{$self->points};
}

sub first_point {
    my ($self) = @_;
    die 'no points' unless @{$self->points};
    return $self->points->[0];
}

sub last_point {
    my ($self) = @_;
    die 'no points' unless @{$self->points};
    return $self->points->[-1];
}

sub append {
    my ($self, @points) = @_;
    push(@{$self->points}, @points);
    return $self;
}

sub clone_first {
    my ($self, @move) = @_;
    die 'no points' unless @{$self->points};
    $self->append($self->first_point->clone);
    $self->last_point->move(@move)
        if @move;
    return $self->first_point;
}

sub clone_last {
    my ($self, @move) = @_;
    die 'no points' unless @{$self->points};
    $self->append($self->last_point->clone);
    $self->last_point->move(@move)
        if @move;
    return $self->last_point;
}

sub ltl_point {
    my ($self) = @_;
    my $point_idx = $self->ltl_point_idx;
    return undef unless defined $point_idx;
    return $self->points->[$point_idx];
}

sub ltl_point_idx {
    my ($self) = @_;
    return undef unless $self->count;
    my $ltl_point_idx = 0;
    my $points = $self->points;
    foreach my $point_idx ( 1 .. $self->count-1 ) {
        my $cmp_y_axes = ( $points->[$point_idx]->y <=> $points->[$ltl_point_idx]->y );
        next if $cmp_y_axes == 1;                                                       # y-axe higher
        $ltl_point_idx = $point_idx
            if (    ( $cmp_y_axes == -1 )                                               # y-axe lower
                 || ( $points->[$point_idx]->x < $points->[$ltl_point_idx]->x ) );  # y-axe same, x-axe smaller
    }
    return $ltl_point_idx;
}

sub sort {
    my ($self) = @_;
    return unless $self->count;

    my $ltl_point_idx = $self->ltl_point_idx;
    my $points        = $self->points;
    my $ltl_point     = splice( @{$points}, $ltl_point_idx, 1 );

    @{$points} = sort { $a->cmp( $ltl_point, $b ) || ( $a->x <=> $b->x ) || ( $a->y <=> $b->y ) }
        @{$points};
    unshift( @{$points}, $ltl_point );
    return;
}

sub hull { return $_[0]->hull_graham_scan() }

sub hull_graham_scan {
    my ($self) = @_;
    $self->sort;
    my @t_points = @{$self->points};
    my @s_points = splice(@t_points, 0, 3);

    while (@t_points) {
        if ($t_points[0]->left_of($s_points[-2], $s_points[-1])) {
            push(@s_points, shift(@t_points));
        }
        else {
            pop(@s_points);
        }
    }

    return \@s_points;
}

1;

__END__

=head1 NAME

Math::CG::PointSet - set of points

=head1 SYNOPSIS

    my $ptset = Math::CG::PointSet->new( points => [ [ 1, 1 ], [ 2, 1 ], [ 1, 2 ] ] );

=head1 METHODS

=head2 encloses($point)

Return true/false if L<Math::CG::Point> is inside the point set.

=head2 sort()

Sorts points by their angular relation to lowest-to-leftmost point

=head2 hull()

alias for hull_graham_scan().

=head2 hull_graham_scan()

Returns array ref of points that represent hull using Graham Scan algorithm.

=head1 AUTHOR

Jozef Kutej, C<< <jkutej at cpan.org> >>

=cut
