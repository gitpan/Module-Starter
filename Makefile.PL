use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Module::Starter',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM        => 'Starter.pm',
    ABSTRACT_FROM       => 'Starter.pm',
    EXE_FILES           => [ 'bin/module-starter' ],
    PREREQ_PM => {
        'Test::More'            => 0,
        'ExtUtils::Command'     => 0,
        'File::Spec'            => 0,
        'Exporter'              => 0,
        'Getopt::Long'          => 0,
        'Pod::Usage'            => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Module-Release-*' },
);
