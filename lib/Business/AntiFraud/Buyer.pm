package Business::AntiFraud::Buyer;
use Moo;
use Locale::Country ();
use Email::Valid ();
use Business::AntiFraud::Shipping;

has email => (
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    },
    is => 'ro',
);

has name => (
#    isa => 'Str',
    is => 'ro',
);
has phone => (
    is => 'rw',
);

has address_line1      => ( is => 'lazy' );
has address_line2      => ( is => 'lazy' );

has address_street     => ( is => 'ro', required => 0 );
has address_number     => ( is => 'ro', required => 0 );
has address_district   => ( is => 'ro', required => 0 );
has address_complement => ( is => 'ro', required => 0 );
has address_zip_code   => ( is => 'ro', required => 0 );
has address_city       => ( is => 'ro', required => 0 );
has address_state      => ( is => 'ro', required => 0 );
has address_country    => (
    is => 'ro',
    required => 0,
    isa => sub {
        for (Locale::Country::all_country_codes()) {
            return 1 if $_ eq $_[0];
        }
    },
    coerce => sub {
        my $country = lc $_[0];
        for (Locale::Country::all_country_codes()) {
            return $_ if $_ eq $country;
        }
        return Locale::Country::country2code($country);
    },
);

sub _build_address_line1 {
    my $self = shift;

    my $street = $self->address_street || '';
    my $number = $self->address_number || '';

    return unless $street;

    return $street unless $number;

    return "$street, $number";
}

sub _build_address_line2 {
    my $self = shift;

    my $distr = $self->address_district   || '';
    my $compl = $self->address_complement || '';

    return $distr if ($distr && !$compl);
    return $compl if (!$distr && $compl);

    return "$distr - $compl";
}

1;
