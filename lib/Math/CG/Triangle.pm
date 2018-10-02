package Math::CG::Triangle;

use Carp::Clan qw(croak);

use Moose;
extends qw(Math::CG::PointSet);

sub area {
    my ($self) = @_;
    return abs($self->area2 / 2);
}

sub area2 {
    my ($self) = @_;

    my $points = $self->points;
    my $p      = $points->[0];
    my $q      = $points->[1];
    my $s      = $points->[2];

    #<<< not perltidy
    return 
          $p->x*$q->y - $p->y*$q->x
        + $q->x*$s->y - $q->y*$s->x
        + $s->x*$p->y - $s->y*$p->x;
    #>>>
}

1;

__END__

=head1 NAME

Math::CG::Triangle - triangle functions

=head1 SYNOPSIS

    my $triangle = Math::CG::Triangle->new(points => [[0, 0], [2, 0], [0, 2]]);

=head1 METHODS

=head2 new

Constructor inherited from L<Math::CG::PointSet>. A triangle need a set of three points.

=head2 area

Computes area of the tringle.

=head2 area2

Computes 2 times the triange area with sign. The sign is used for L<Math::CG::Point/left_of>.

=head1 AUTHOR

Jozef Kutej, C<< <jkutej at cpan.org> >>

=cut
