# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Business::AntiFraud' ); }

my $object = Business::AntiFraud->new ();
isa_ok ($object, 'Business::AntiFraud');


