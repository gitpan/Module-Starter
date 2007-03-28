package Module::Starter;
# vi:et:sw=4 ts=4

use warnings;
use strict;
use Carp qw( croak );

=head1 NAME

Module::Starter - a simple starter kit for any module

=head1 VERSION

Version 1.43_01

=cut

our $VERSION = '1.43_01';

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

=head2 Module::Starter->create_distro(%args)

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

=head1 PLUGINS

Module::Starter itself doesn't actually do anything.  It must load plugins that
implement C<create_distro> and other methods.  This is done by the class's C<import>
routine, which accepts a list of plugins to be loaded, in order.

For more information, refer to L<Module::Starter::Plugin>.

=cut

sub import {
    my $class = shift;
    my @plugins = ((@_ ? @_ : 'Module::Starter::Simple'), $class);
    my $parent;

    while (my $child = shift @plugins) {
        eval "require $child";
        croak "couldn't load plugin $child: $@" if $@;

        no strict 'refs';
        push @{"${child}::ISA"}, $parent if $parent;

        if ( @plugins && $child->can('load_plugins') ) {
            $parent->load_plugins(@plugins);
            last;
        }
        $parent = $child;
    }

    return;
}

=head1 AUTHORS

Andy Lester, C<< <petdance at cpan.org> >>

Ricardo Signes, C<< <rjbs at cpan.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Module::Starter

    You can also look for information at:

=over 4

=item * Source code at Google Code

L<http://code.google.com/p/module-starter/>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Module-Starter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Module-Starter>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Module-Starter>

=item * Search CPAN

L<http://search.cpan.org/dist/Module-Starter>

=back

=head1 BUGS

Please report any bugs or feature requests to
C<bug-module-starter at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2005-2007 Andy Lester and Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;