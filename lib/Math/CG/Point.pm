package Math::CG::Point;

use Moose;
use Carp qw(croak);
use JSON::XS qw(encode_json);
use Class::Load qw(load_class);
use List::Util qw(max);

has 'coords' => (is => 'rw', isa => 'ArrayRef', default => sub {[]}, lazy => 1);

sub dimensions {return scalar(@{$_[0]->coords})}
sub x          {return $_[0]->coords->[0]}
sub y          {return $_[0]->coords->[1]}
sub z          {return $_[0]->coords->[2]}

my %idx_to_dim = (
    0 => 'x',
    1 => 'y',
    2 => 'z',
);

use overload (
    '""' => \&as_string,
    '==' => \&is_equal,
    '!=' => \&is_not_equal,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my %args;
    if (@_ == 1) {
        if (ref($_[0]) eq 'ARRAY') {
            $args{coords} = $_[0];
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

    $args{coords} //= [];

    # set coordinates from names
    foreach my $idx (keys %idx_to_dim) {
        next unless exists($args{$idx_to_dim{$idx}});
        $args{coords}->[$idx] //= $args{$idx_to_dim{$idx}};
    }

    return $class->$orig(%args);
};

sub as_string {
    my ($self) = @_;
    return encode_json($self->coords);
}

sub as_array {
    my ($self) = @_;
    return @{$self->coords};
}

sub left_of {
    my ($self, $p1, $p2) = @_;
    load_class('Math::CG::Triangle');
    my $triangle = Math::CG::Triangle->new([$p1, $p2, $self]);
    return $triangle->area2 > 0;
}

sub is_not_equal {
    my ($self, $p1) = @_;
    return !$self->is_equal($p1);
}

sub is_equal {
    my ($self, $p1) = @_;
    my $max_dim = max($self->dimensions, $p1->dimensions);
    foreach my $idx (0 .. $max_dim - 1) {
        return 0 if ($self->coords->[$idx] // 0) != ($p1->coords->[$idx] // 0);
    }
    return 1;
}

sub clone {
    my ($self) = @_;
    return __PACKAGE__->new(coords => [$self->as_array]);
}

sub move {
    my ($self, @coords_delta) = @_;

    if (@coords_delta == 1) {
        my %delta = %{shift(@coords_delta)};
        foreach my $idx (sort keys %idx_to_dim) {
            next unless exists($delta{$idx_to_dim{$idx}});
            push(@coords_delta, $delta{$idx_to_dim{$idx}});
        }
    }

    my $idx = 0;
    foreach my $delta (@coords_delta) {
        $self->coords->[$idx] += $delta;
        $idx++;
    }
    return $self;
}

1;

__END__

=head1 NAME

Math::CG::Point - point in space

=head1 SYNOPSIS

    my $pt1 = Math::CG::Point->new( x => 2, y => 3 );

=head1 AUTHOR

Jozef Kutej, C<< <jkutej at cpan.org> >>

=cut
