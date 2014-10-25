package Module::Starter;

use strict;

use Exporter;
use ExtUtils::Command qw( rm_rf mkpath touch );
use File::Spec;

use vars qw( @ISA @EXPORT );

@ISA = qw( Exporter );
@EXPORT = qw( create_distro );

=head1 NAME

Module::Starter - Starter kit for any module

=head1 Version

Version 1.00

    $Header: /home/cvs/module-starter/Starter.pm,v 1.28 2004/06/25 23:00:02 andy Exp $

=cut

our $VERSION = '1.00';

=head1 Synopsis

Nothing in here is meant for public consumption.  Use F<module-starter>
from the command line.

    module-starter --module=Foo::Bar,Foo::Bat \
        --author="Andy Lester" --email=andy@petdance.com

=head1 Package variables

=over 4

=item * $verbose

=item * $force

=item * $author

=item * $email

=item * $license

=back

=cut

our $verbose = 0;
our $force = 0;
our $license = 'perl';
our $author;
our $email;

=head1 Functions

=head2 create_distro()

Takes a hash of parms:

    dir => $dirname,
    modules => [ module names ],
    distro => $distroname,
    builder => 'Module::Build', # Defaults to ExtUtils::MakeMaker
    # or specify more than one builder
    builder => [ 'Module::Build', 'ExtUtils::MakeMaker' ],

=cut

sub create_distro {
    my %args = @_;

    my $modules = $args{modules} || [];
    my @modules = map { split /,/ } @$modules;
    die "No modules specified.\n" unless @modules;

    die "Must specify an author\n" unless $author;
    die "Must specify an email address\n" unless $email;

    my $distro = $args{distro};
    if ( not defined $distro ) {
        $distro = $modules[0];
        $distro =~ s/::/-/g;
    }

    my $basedir = $args{dir} || $distro;
    create_directory( $basedir, $force );

    my @files;
    push @files, create_modules( $basedir, @modules );

    push @files, create_t( $basedir, @modules );
    push @files, create_cvsignore( $basedir, $distro );

    my @builders = (ref $args{builder} eq "ARRAY") ? @{$args{builder}} : ($args{builder});

    my @build_instructions;
    for my $builder ( @builders ) {
        if ( !@build_instructions ) {
            push @build_instructions, "To install this module, run the following commands:";
        } else {
            push @build_instructions, "Alternatively, to install with $builder, you can use the following commands:";
        }
        if ( $builder eq 'Module::Build' ) {
            push @files, create_Build_PL( $basedir, $distro, $modules[0] );
            push @build_instructions, <<'HERE';
    perl Build.PL
    ./Build
    ./Build test
    ./Build install
HERE
        } else {
            push @files, create_Makefile_PL( $basedir, $distro, $modules[0] );
            push @build_instructions, <<'HERE';
    perl Makefile.PL
    make
    make test
    make install
HERE
        }
    }

    my $build_instructions = join( "\n\n", @build_instructions );

    push @files, create_Changes( $basedir, $distro );
    push @files, create_README( $basedir, $distro, $author, $build_instructions );
    push @files, "MANIFEST";
    push @files, 'META.yml # Will be created by "make dist"';
    create_MANIFEST( $basedir, @files );
}

=head2 create_directory( $dir [, $force ] )

Creates a directory at I<$dir>.  If the directory already exists, and
I<$force> is true, then the existing directory will get erased.

If the directory can't be created, or re-created, it dies.

=cut

sub create_directory {
    my $dir = shift;
    my $force = shift;

    # Make sure there's no directory
    if ( -e $dir ) {
        die "$dir already exists.  Use --force if you want to stomp on it.\n" unless $force;

        local @ARGV = $dir;
        rm_rf();

        die "Couldn't delete existing $dir: $!\n" if -e $dir;
    }

    CREATE_IT: {
        print "Created $dir\n" if $verbose;

        local @ARGV = $dir;
        mkpath();

        die "Couldn't create $dir: $!\n" unless -d $dir;
    }
}

=head2 create_modules( $dir, @modules )

Creates starter modules for each of the modules passed in.

=cut

sub create_modules {
    my $dir = shift;
    my @modules = @_;

    my @files;

    for my $module ( @modules ) {
        push @files, _create_module( $dir, $module );
    }

    return @files;
}

sub _create_module {
    my $basedir = shift;
    my $module = shift;

    my @parts = split( /::/, $module );
    my $filepart = (pop @parts) . ".pm";
    my @dirparts = ( $basedir, 'lib', @parts );
    my $manifest_file = join( "/", "lib", @parts, $filepart );
    if ( @dirparts ) {
        my $dir = File::Spec->catdir( @dirparts );
        if ( not -d $dir ) {
            local @ARGV = $dir;
            mkpath @ARGV;
            print "Created $dir\n" if $verbose;
        }
    }

    my $module_file = File::Spec->catfile( @dirparts,  $filepart );

    open( my $fh, ">", $module_file ) or die "Can't create $module_file: $!\n";
    print $fh &_module_guts( $module );
    close $fh;
    print "Created $module_file\n" if $verbose;

    return $manifest_file;
}

sub _thisyear { (localtime())[5] + 1900 }

sub _module_guts {
    my $module = shift;

    my $rtname = lc $module;
    $rtname =~ s/::/-/g;

    my $year = _thisyear();

    return <<"HERE";
package $module;

use warnings;
use strict;

=head1 NAME

$module - The great new $module!

=head1 Version

Version 0.01

=cut

our \$VERSION = '0.01';

=head1 Synopsis

Quick summary of what the module does.

Perhaps a little code snippet.

    use $module;

    my \$foo = $module->new();
    ...

=head1 Export

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 Functions

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 Author

$author, C<< <$email> >>

=head1 Bugs

Please report any bugs or feature requests to
C<bug-$rtname\@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 Copyright & License

Copyright $year $author, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of $module
HERE
}

=head2 create_Makefile_PL( $basedir, $distro, $main_module )

Creates a Makefile.PL for the given module distro.

=cut

sub create_Makefile_PL {
    my $basedir = shift;
    my $distro = shift;
    my $main_module = shift;

    my @parts = split( /::/, $main_module );
    my $pm = pop @parts;
    my $main_pm_file = File::Spec->catfile( "lib", @parts, "${pm}.pm" );

    my $fname = File::Spec->catfile( $basedir, "Makefile.PL" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";

print $fh <<"HERE";
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => '$main_module',
    AUTHOR              => '$author <$email>',
    VERSION_FROM        => '$main_pm_file',
    ABSTRACT_FROM       => '$main_pm_file',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => '$distro-*' },
);
HERE

    close $fh;
    print "Created $fname\n" if $verbose;

    return "Makefile.PL";
}

=head2 create_Build_PL( $basedir, $distro, $main_module )

Creates a Build.PL for the given module distro.

=cut

sub create_Build_PL {
    my $basedir = shift;
    my $distro = shift;
    my $main_module = shift;

    my @parts = split( /::/, $main_module );
    my $pm = pop @parts;
    my $main_pm_file = File::Spec->catfile( "lib", @parts, "${pm}.pm" );

    my $fname = File::Spec->catfile( $basedir, "Build.PL" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";

print $fh <<"HERE";
use strict;
use warnings;
use Module::Build;

my \$builder = Module::Build->new(
    module_name         => '$main_module',
    license             => '$license',
    dist_author         => '$author <$email>',
    dist_version_from   => '$main_pm_file',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ '$distro-*' ],
);

\$builder->create_build_script();
HERE

    close $fh;
    print "Created $fname\n" if $verbose;

    return "Build.PL";
}

=head2 create_Changes( $basedir, $distro )

Creates a skeleton Changes file.

=cut

sub create_Changes {
    my $basedir = shift;
    my $distro = shift;

    my $fname = File::Spec->catfile( $basedir, "Changes" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";

print $fh <<"HERE";
Revision history for $distro

0.01    Date/time
        First version, released on an unsuspecting world.

HERE

    close $fh;
    print "Created $fname\n" if $verbose;

    return "Changes";
}

=head2 create_README( $basedir, $distro )

Creates a skeleton README file.

=cut

sub create_README {
    my $basedir = shift;
    my $distro = shift;
    my $author = shift;
    my $build_instructions = shift;

    my $year = _thisyear();

    my $fname = File::Spec->catfile( $basedir, "README" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";

print $fh <<"HERE";
$distro

The README is used to introduce the module and provide instructions on
how to install the module, any machine dependencies it may have (for
example C compilers and installed libraries) and any other information
that should be provided before the module is installed.

A README file is required for CPAN modules since CPAN extracts the README
file from a module distribution so that people browsing the archive
can use it get an idea of the modules uses. It is usually a good idea
to provide version information here so that people can decide whether
fixes for the module are worth downloading.

INSTALLATION

$build_instructions

COPYRIGHT AND LICENCE

Put the correct copyright and licence information here.

Copyright (C) $year $author

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
HERE

    close $fh;
    print "Created $fname\n" if $verbose;

    return "README";
}


=head2 create_t( $basedir, @modules )

Creates a bunch of *.t files for the modules.

=cut

sub create_t {
    my $basedir = shift;
    my @modules = @_;

    my @files;

    push @files, _create_t( $basedir, "pod.t", <<'HERE' );
use Test::More;
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();
HERE

    push @files, _create_t( $basedir, "pod-coverage.t", <<'HERE' );
use Test::More;
eval "use Test::Pod::Coverage 0.08";
plan skip_all => "Test::Pod::Coverage 0.08 required for testing POD coverage" if $@;
all_pod_coverage_ok();
HERE


    my $nmodules = @modules;
    my $main_module = $modules[0];
    my $use_lines = join( "\n", map { "use_ok( '$_' );" } @modules );

    push @files, _create_t( $basedir, "00.load.t", <<"HERE" );
use Test::More tests => $nmodules;

BEGIN {
$use_lines
}

diag( "Testing $main_module \$${main_module}::VERSION" );
HERE

    return @files;
}

sub _create_t {
    my $basedir = shift;
    my $filename = shift;
    my $content = shift;

    my @dirparts = ( $basedir, "t" );
    my $tdir = File::Spec->catdir( @dirparts );
    if ( not -d $tdir ) {
        local @ARGV = $tdir;
        mkpath();
        print "Created $tdir\n" if $verbose;
    }

    my $fname = File::Spec->catfile( @dirparts, $filename );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";
    print $fh $content;
    close $fh;
    print "Created $fname\n" if $verbose;

    return "t/$filename";
}

=head2 create_MANIFEST( $basedir, @files )

Must be run last, because all the other create_* functions have been
returning the functions they create.

=cut

sub create_MANIFEST {
    my $basedir = shift;
    my @files = sort @_;

    my $fname = File::Spec->catfile( $basedir, "MANIFEST" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";
    print $fh map { "$_\n" } @files;
    close $fh;

    print "Created $fname\n" if $verbose;

    return "MANIFEST";
}

=head2 create_cvsignore( $basedir, $distro )

Create .cvsignore file in the root so that your CVS knows to ignore
certain files.

=cut

sub create_cvsignore {
    my $basedir = shift;
    my $distro = shift;

    my $fname = File::Spec->catfile( $basedir, ".cvsignore" );
    open( my $fh, ">", $fname ) or die "Can't create $fname: $!\n";
    print $fh <<"HERE";
blib*
Makefile
Makefile.old
pm_to_blib*
*.tar.gz
.lwpcookies
$distro-*
cover_db
HERE
    close $fh;

    return; # Not a file that goes in the MANIFEST
}

=head1 Description

=head1 Export

=head1 Bugs

Please report any bugs or feature requests to
C<bug-module-starter@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 Author

Andy Lester, C<< <andy@petdance.com> >>

=head1 Copyright & License

Copyright 2004 Andy Lester, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=cut

1;
