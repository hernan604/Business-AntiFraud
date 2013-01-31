package Business::AntiFraud::Gateway::Base;
use Moo;
use Locale::Currency;
use Email::Valid;
use Business::AntiFraud::EmptyLogger;
use HTML::Element;
use Class::Load qw/load_first_existing_class/;
use Data::Printer;

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

    my $gateway_name = ref $self;
       $gateway_name =~ s/Business::AntiFraud::Gateway:://g;

    #===item_class===
    my $item_class = Class::Load::load_optional_class( "Business::AntiFraud::Item::$gateway_name" ) ?
        "Business::AntiFraud::Item::$gateway_name" :
        "Business::AntiFraud::Item" ;
    my @items = map { ref $_ eq $item_class ? $_ : $item_class->new($_) }
      @{ delete $info->{items} || [] };

    #===buyer_class===
    my $buyer_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Buyer::$gateway_name",
        "Business::AntiFraud::Buyer"
    );
    my $buyer = $buyer_class->new( delete $info->{buyer} );
    $self->log->info("Built cart for buyer " . $buyer->email);

    #===cart_class===
    my $cart_class  = Class::Load::load_first_existing_class(
        "Business::AntiFraud::Cart::$gateway_name",
        "Business::AntiFraud::Cart"
    );
    return $cart_class->new(
        _gateway => $self,
        _items   => \@items,
        buyer    => $buyer,
        %$info,
    );
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
