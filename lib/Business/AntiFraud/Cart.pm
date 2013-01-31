package Business::AntiFraud::Cart;
use Moo;
use Business::AntiFraud::Item;
use Business::AntiFraud::Types qw/stringified_money/;

# VERSION

has buyer => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::AntiFraud::Buyer') or die "Must be a Business::AntiFraud::Buyer" },
);

has shipping => (
    is => 'ro',
    isa => sub {
        $_[0]->isa('Business::AntiFraud::Shipping') or die "Must be a Business::AntiFraud::Shipping"
    },
);

has tax => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has handling => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has discount => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has _gateway => (
    is => 'ro',
    isa => sub { $_[0]->isa('Business::AntiFraud::Gateway::Base') or die "Must be a AntiFraud::Gateway::Base" },
);

has _items => (
    is => 'ro',
    #isa => 'ArrayRef[Business::AntiFraud::Item]',
    default => sub { [] },
);

sub get_item {
    my ($self, $item_id) = @_;

    for (my $i = 0; $i < @{ $self->_items }; $i++) {
        my $item = $self->_items->[$i];
        if ($item->id eq "$item_id") {
            return $item;
        }
    }

    return undef;
}

sub add_item {
    my ($self, $info) = @_;

    my $item = ref $info && ref $info eq 'Business::AntiFraud::Item' ?
        $info
        :
        Business::AntiFraud::Item->new($info);

    push @{ $self->_items }, $item;

    return $item;
}

sub get_form_to_pay {
    my ($self, $payment) = @_;

    return $self->_gateway->get_form({
        payment_id => $payment,
        items      => [ @{ $self->_items } ], # make a copy for security
        buyer      => $self->buyer,
        cart       => $self,
    });
}

1;
