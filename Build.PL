use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name        => 'Math::CG',
    license            => 'perl',
    dist_author        => 'Jozef Kutej <jkutej@cpan.org>',
    dist_version_from  => 'lib/Math/CG.pm',
    configure_requires => {'Module::Build' => '0.3607',},
    requires           => {
        'Moose'       => 0,
        'Carp'        => 0,
        'JSON::XS'    => 0,
        'Class::Load' => 0,
        'List::Util'  => 0,
    },
    build_requires => {'Test::Most' => 0,},
    add_to_cleanup => ['Math-CG-*'],
    create_readme  => 1,
    meta_merge     => {
        resources => {
            repository => 'http://github.com/jozef/Math-CG',
            bugtracker => 'http://github.com/jozef/Math-CG/issues',
        },
        keywords => [qw/ math computational geometry /],
    },
);

$builder->create_build_script();
