package Business::AntiFraud::Item;
use Moo;
use Business::AntiFraud::Types qw/stringified_money/;

# VERSION

has id => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has price => (
    coerce => \&stringified_money,
    is => 'ro',
);

has weight => (
    coerce => sub { 0 + $_[0] },
    required => 0,
    is => 'ro',
);

has shipping => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has shipping_additional => (
    coerce => \&stringified_money,
    required => 0,
    is => 'ro',
);

has description => (
    coerce => sub { '' . $_[0] },
    is => 'ro',
);

has quantity => (
    coerce => sub { int $_[0] },
    is => 'ro',
);

1;
