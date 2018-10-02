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
    return encode_json([map {$_->as_data} @{$self->points}]);
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

1;

__END__

=head1 NAME

Math::CG::PointSet - set of points

=head1 SYNOPSIS

    my $ptset = Math::CG::PointSet->new( points => [ [ 1, 1 ], [ 2, 1 ], [ 1, 2 ] ] );

=head1 METHODS

=head2 encloses($point)

Return true/false if L<Math::CG::Point> is inside the point set.

=head1 AUTHOR

Jozef Kutej, C<< <jkutej at cpan.org> >>

=cut
