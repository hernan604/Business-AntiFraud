# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use warnings;
use strict;
use Test::More;

BEGIN { use_ok( 'Business::AntiFraud' ); }

#my $object = Business::AntiFraud->new ();
#isa_ok ($object, 'Business::AntiFraud');
use Business::AntiFraud;

my $antifraud = eval {
    Business::AntiFraud->new(
        gateway          => 'Test',
        receiver_email   => 'hernanlopes@gmail.com',
        currency         => 'BRL',
        checkout_url     => '',
    );
};

ok($antifraud, 'the object was defined');
ok(!$@, 'no error');

if ($@) {
    diag $@;
}

isa_ok($antifraud, 'Business::AntiFraud::Gateway::Test');

my $cart = $antifraud->new_cart({
    buyer => {
        email => 'hernan@cpan.org',
        name  => 'Mr. Buyer',
    },
});

$cart->add_item({
    id          => 1,
    description => 'Expensive item',
    price       => 200.5,
    quantity    => 10,
});

$cart->add_item({
    id          => '02',
    description => 'Cheap item',
    price       => 0.56,
    quantity    => 5,
});

$cart->add_item({
    id          => '03',
    description => 'Third item',
    price       => 10,
    quantity    => 1,
});

$cart->add_item({
    id          => 'my-id',
    description => 'Real string id',
    price       => 10,
    quantity    => 1,
});

{
    my $item = eval { $cart->get_item(1) };

    ok($item, 'item is defined');
    ok(!$@, 'no error');

    if ($@) {
        diag $@;
    }

    isa_ok($item, 'Business::AntiFraud::Item');
    is($item->id,          '1',              'item id is correct');
    is($item->description, 'Expensive item', 'item desc is correct');
    isnt($item->price,     200.5,            'item price is not numeric');
    is($item->price,       '200.50',         'item price is correct');
    is($item->quantity,    10,               'item quantity is correct');
}

{
    my $item = eval { $cart->get_item('02') };

    ok($item, 'item is defined');
    ok(!$@, 'no error');

    if ($@) {
        diag $@;
    }

    isa_ok($item, 'Business::AntiFraud::Item');
    is($item->id,          '02',           'item id is correct');
    is($item->description, 'Cheap item',   'item desc is correct');
    is($item->price,       '0.56',         'item price is correct');
    is($item->quantity,    5,              'item quantity is correct');
}

{
    my $item = eval { $cart->get_item('03') };

    ok($item, 'item is defined');
    ok(!$@, 'no error');

    if ($@) {
        diag $@;
    }

    isa_ok($item, 'Business::AntiFraud::Item');

    is($item->id,          '03',         'item id is correct');
    is($item->description, 'Third item', 'item desc is correct');
    isnt($item->price,     10,           'item price is not numeric');
    is($item->price,       '10.00',      'item price is correct');
    is($item->quantity,    1,            'item quantity is correct');
}

{
    my $item = eval { $cart->get_item('my-id') };

    ok($item, 'item is defined');
    ok(!$@, 'no error');

    if ($@) {
        diag $@;
    }

    isa_ok($item, 'Business::AntiFraud::Item');

    is($item->id,          'my-id',          'item id is correct');
    is($item->description, 'Real string id', 'item desc is correct');
    isnt($item->price,     10,               'item price is not numeric');
    is($item->price,       '10.00',          'item price is correct');
    is($item->quantity,    1,                'item quantity is correct');
}

{
    ok(my $form = $cart->get_form_to_pay('pay123'), 'get form');
    isa_ok($form, 'HTML::Element');
    warn "\n" . $form->as_HTML;
    warn "^^^";
    is( get_value_for($form, 'receiver_email'), 'hernanlopes@gmail.com', 'form value receiver_email is correct');
    is( get_value_for($form, 'currency'),       'BRL',                      'form value currency is correct');
    is( get_value_for($form, 'payment_id'),     'pay123',                   'form value payment_id is correct');
    is( get_value_for($form, 'buyer_name'),     'Mr. Buyer',                'form value buyer_name is correct');
    is( get_value_for($form, 'buyer_email'),    'hernan@cpan.org',    'form value buyer_email is correct');
    is( get_value_for($form, 'encoding'),       'UTF-8',                    'form value encoding is correct');


    is( get_value_for($form, 'item1_id'),       '1',                        'form value item1_id is correct');
    is( get_value_for($form, 'item1_desc'),     'Expensive item',           'form value item1_desc is correct');
    is( get_value_for($form, 'item1_price'),    '200.50',                   'form value item1_price is correct');
    is( get_value_for($form, 'item1_qty'),      '10',                       'form value item1_qty is correct');

    is( get_value_for($form, 'item2_id'),       '02',                       'form value item2_id is correct');
    is( get_value_for($form, 'item2_desc'),     'Cheap item',               'form value item2_desc is correct');
    is( get_value_for($form, 'item2_price'),    '0.56',                     'form value item2_price is correct');
    is( get_value_for($form, 'item2_qty'),      '5',                        'form value item2_qty is correct');

    is( get_value_for($form, 'item3_id'),       '03',                       'form value item3_id is correct');
    is( get_value_for($form, 'item3_desc'),     'Third item',               'form value item3_desc is correct');
    is( get_value_for($form, 'item3_price'),    '10.00',                    'form value item3_price is correct');
    is( get_value_for($form, 'item3_qty'),      '1',                        'form value item3_qty is correct');

    is( get_value_for($form, 'item4_id'),       'my-id',                    'form value item4_id is correct');
    is( get_value_for($form, 'item4_desc'),     'Real string id',           'form value item4_desc is correct');
    is( get_value_for($form, 'item4_price'),    '10.00',                    'form value item4_price is correct');
    is( get_value_for($form, 'item4_qty'),      '1',                        'form value item4_qty is correct');
}

$antifraud->create_xml();

done_testing;
use Data::Printer;
sub get_value_for {
    my ($form, $name) = @_;
    return $form->look_down(_tag => 'input', name => $name )->attr('value');
}
