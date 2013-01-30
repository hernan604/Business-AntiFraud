package Business::AntiFraud::EmptyLogger;
use Moo;

sub new      { bless {}, shift }
sub is_debug {}
sub debug    {}
sub info     {}
sub warn     {}
sub error    {}
sub fatal    {}

1;
