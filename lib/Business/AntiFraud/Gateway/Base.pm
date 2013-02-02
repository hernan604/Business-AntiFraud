package Business::AntiFraud::Gateway::Base;
use Moo;
use Locale::Currency;
use Email::Valid;
use Business::AntiFraud::EmptyLogger;
use HTML::Element;
use Class::Load qw/load_first_existing_class/;

has receiver_email => (
    isa => sub {
        die "Must be a valid e-mail address"
            unless Email::Valid->address( $_[0] );
    },
    is => 'ro',
);

has currency => (
    isa => sub {
        my $curr = uc($_[0]);

        for (Locale::Currency::all_currency_codes()) {
            return 1 if $curr eq uc($_);
        }

        die "Must be a valid currency code";
    },
    coerce => sub { uc $_[0] },
    is => 'ro',
);

has log => (
    is => 'ro',
    default => sub { Business::AntiFraud::EmptyLogger->new },
);

has checkout_url => (
    is => 'ro',
);

has checkout_form_http_method => (
    is => 'ro',
    default => sub { 'post' },
);

has checkout_form_submit_name => (
    is => 'ro',
    default => sub { 'submit' },
);

has checkout_form_submit_value => (
    is => 'ro',
    default => sub { '' },
);

has form_encoding => (
    is      => 'ro',
    # TODO: use Encode::find_encoding()
    default => sub { 'UTF-8' },
);

sub new_cart {
    my ( $self, $info ) = @_;
    if ($self->log->is_debug) {
        $self->log->debug("Building a cart with: " . Dumper($info));
    }

    my $gateway_name = $self->gateway_name();
    my        @items = @{ $self->populate_items ( $gateway_name, $info ) };
    my        $buyer = $self->create_buyer      ( $gateway_name, $info );
    my     $shipping = $self->create_shipping   ( $gateway_name, $info );
    my      $billing = $self->create_billing    ( $gateway_name, $info );

    my $cart_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Cart::$gateway_name",
        "Business::AntiFraud::Cart"
    );

    return $cart_class->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
        shipping => $shipping,
        billing => $billing,
        %$info,
    );
}

sub create_buyer {
    my ( $self, $gateway_name, $info ) = @_;
    my $buyer_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Buyer::$gateway_name",
        "Business::AntiFraud::Buyer"
    );
    $self->log->info("Built buyer with class " . $buyer_class);
    return $buyer_class->new( delete $info->{buyer} );
}

sub create_shipping {
    my ( $self, $gateway_name, $info ) = @_;
    my $shipping_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Shipping::$gateway_name",
        "Business::AntiFraud::Shipping"
    );
    my $shipping_vals = delete $info->{ shipping }||{};
    $self->log->info("Built shipping address with class  " . $shipping_class );
    return $shipping_class->new( $shipping_vals );
}

sub create_billing {
    my ( $self, $gateway_name, $info ) = @_;
    my $billing_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Billing::$gateway_name",
        "Business::AntiFraud::Billing"
    );
    my $billing_vals = delete $info->{ billing }||{};
    $self->log->info("Built billing address with class  " . $billing_class );
    return $billing_class->new( $billing_vals );
}

sub populate_items {
    my ( $self, $gateway_name, $info ) = @_;
    my $item_class = Class::Load::load_optional_class( "Business::AntiFraud::Item::$gateway_name" ) ?
        "Business::AntiFraud::Item::$gateway_name" :
        "Business::AntiFraud::Item" ;
    my @items = map { ref $_ eq $item_class ? $_ : $item_class->new($_) }
      @{ delete $info->{items} || [] };
    return \@items;
}

sub gateway_name {
    my ( $self ) = @_;
    my $gateway_name = ref $self;
    $gateway_name =~ s/Business::AntiFraud::Gateway:://g;
    return $gateway_name;
}

sub get_hidden_inputs { () }

sub get_form {
    my ($self, $info) = @_;

    $self->log->info("Get form for payment " . $info->{payment_id});

    my @hidden_inputs = $self->get_hidden_inputs($info);

    if ($self->log->is_debug) {
        $self->log->debug("Building form with inputs: " . Dumper(\@hidden_inputs));
        $self->log->debug("form action => " . $self->checkout_url);
        $self->log->debug("form method => " . $self->checkout_form_http_method);
    }

    my $form = HTML::Element->new(
        'form',
        action => $self->checkout_url,
        method => $self->checkout_form_http_method,
    );

    while (@hidden_inputs) {
        $form->push_content(
            HTML::Element->new(
                'input',
                type  => 'hidden',
                value => pop @hidden_inputs,
                name  => pop @hidden_inputs
            )
        );
    }

    my @value = ();
    if (my $value = $self->checkout_form_submit_value) {
        @value = (value => $value);
    }

    $form->push_content(
        HTML::Element->new(
            'input',
            type  => 'submit',
            name  => $self->checkout_form_submit_name,
            @value
        )
    );

    return $form;
}

sub get_notification_details {}

sub query_transactions {}

sub get_transaction_details {}

1;
