package Business::AntiFraud;
use strict;
use warnings;
use Class::Load;

our $VERSION     = '0.01';

sub new {
    my $class = shift;

    my %data = ref $_[0] && ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;

    my $gateway = $data{gateway};
    my $gateway_class = "Business::AntiFraud::Gateway::$gateway";

    Class::Load::load_class($gateway_class);

    return $gateway_class->new(%data);
}


=head1 NAME

Business::AntiFraud - Interface for multiple antifraud systems

=head1 SYNOPSIS

  use Business::AntiFraud;

=head1 DESCRIPTION

Blah blah blah.

=head1 USAGE

=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    -
    hernanlopes@gmail.com
    http://www.movimentoperl.com.br

=head1 OTHER THANKS

Other thanks goes to the creators of the Business CPI standard idea (André Walker) which i copied over into this module.

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).

=cut

1;
