package Business::AntiFraud::Billing;
use Moo;
#billing information... who will pay for these products?

has name               => ( is => 'rw' );
has email              => ( is => 'rw' );
has document_id        => ( is => 'rw' ); #CPF ou CPNJ
has address_street     => ( is => 'rw' );
has address_number     => ( is => 'rw' );
has address_district   => ( is => 'rw' );
has address_city       => ( is => 'rw' );
has address_state      => ( is => 'rw' );
has address_zip_code   => ( is => 'rw' );
has address_country    => ( is => 'rw' );
has phone              => ( is => 'rw' );
has phone_prefix       => ( is => 'rw' );
has celular            => ( is => 'rw' ); #OPT
has celular_prefix     => ( is => 'rw' ); #OPT

1;
