package Module::Starter;
# vi:et:sw=4 ts=4

our $VERSION = '1.30';

use warnings;
use strict;

=head1 NAME

Module::Starter - a simple starter kit for any module

=head1 VERSION

Version 1.30

    $Header: /home/cvs/module-starter/lib/Module/Starter.pm,v 1.6 2004/08/16 19:03:05 rjbs Exp $

=head1 SYNOPSIS

Nothing in here is meant for public consumption.  Use F<module-starter>
from the command line.

    module-starter --module=Foo::Bar,Foo::Bat \
        --author="Andy Lester" --email=andy@petdance.com

=head1 DESCRIPTION

This is the core module for Module::Starter.  If you're not looking to extend
or alter the behavior of this module, you probably want to look at
L<module-starter> instead.

Module::Starter is used to create a skeletal CPAN distribution, including basic
builder scripts, tests, documentation, and module code.  This is done through
just one method, C<create_distro>.

=head1 METHODS 

=over 4

=item C<< Module::Starter->create_distro(%args) >>

C<create_distro> is the only method you should need to use from outside this
module; all the other methods are called internally by this one.

This method creates orchestrates all the work; it creates distribution and
populates it with the all the requires files.

It takes a hash of params, as follows:

    distro  => $distroname,      # distribution name (defaults to first module)
    modules => [ module names ], # modules to create in distro
    dir     => $dirname,         # directory in which to build distro
    builder => 'Module::Build',  # defaults to ExtUtils::MakeMaker
                                 # or specify more than one builder in an
                                 # arrayref

    license => $license,  # type of license; defaults to 'perl'
    author  => $author,   # author's full name (required)
    email   => $email,    # author's email address (required)

    verbose => $verbose,  # bool: print progress messages; defaults to 0
    force   => $force     # bool: overwrite existing files; defaults to 0

=back

=head1 PLUGINS

Module::Starter itself doesn't actually do anything.  It must load plugins that
implement C<create_distro> and other methods.  This is done by the class's C<import>
routine, which accepts a list of plugins to be loaded, in order.

For more information, refer to L<Module::Starter::Plugin>.

=cut

sub import {
    my $class = shift;
    my @plugins = @_ ? @_ : 'Module::Starter::Simple';
    my $parent;

    no strict 'refs';
    for (@plugins, $class) {
        if ($parent) {
            eval "require $parent;"; 
            die "couldn't load plugin $parent: $@" if $@;
            push @{"${_}::ISA"}, $parent;
        }
        $parent = $_;
    }
}

=head1 AUTHORS

Andy Lester, C<< <petdance@cpan.org> >>

Ricardo Signes, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-module-starter@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2004 Andy Lester, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;