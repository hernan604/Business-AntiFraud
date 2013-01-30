package Business::AntiFraud::Gateway::Test;
# Teste para o M clearsale
use Moo;
use HTTP::Tiny;
extends qw/Business::AntiFraud::Gateway::Base/;

=head1 ATTRIBUTES

=head2 ua

Uses HTTP::Tiny as useragent

=cut

has ua => (
    is => 'rw',
    default => sub { HTTP::Tiny->new() },
);

=head2 sandbox

Indica se homologação ou sandbox

=cut

has sandbox => ( is => 'rw' );

=head2 url_alterar_status

Holds the url_alterar_status. You DONT need to pass it, it will figure out its own url based on $self->sandbox

=cut

has url_alterar_status => (
    is => 'rw',
);

=head2 url_envio_pedido

Holds the url_alterar_status. You DONT need to pass it, it will figure out its own url based on $self->sandbox

=cut

has url_envio_pedido => (
    is => 'rw',
);

=head1 METHODS

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    if ( $self->sandbox ) {
        $self->url_alterar_status('http://homologacao.clearsale.com.br/integracaov2/FreeClearSale/AlterarStatus.aspx');
        $self->url_envio_pedido('http://homologacao.clearsale.com.br/integracaov2/freeclearsale/frame.aspx');
    } else {
        $self->url_alterar_status('http://clearsale.com.br/integracaov2/FreeClearSale/AlterarStatus.aspx');
        $self->url_envio_pedido('http://www.clearsale.com.br/integracaov2/freeclearsale/frame.aspx');
    }
};

=head2 create_xml

=cut

sub create_xml {
    my ( $self ) = @_;
    warn "\n\n*** GERANDO XML ***\n\n";

}

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my $buyer = $info->{buyer};
    my $cart  = $info->{cart};

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $buyer->name,
        buyer_email    => $buyer->email,
    );

    my %buyer_extra = (
        address_line1    => 'shipping_address',
        address_line2    => 'shipping_address2',
        address_city     => 'shipping_city',
        address_state    => 'shipping_state',
        address_country  => 'shipping_country',
        address_zip_code => 'shipping_zip',
    );

    for (keys %buyer_extra) {
        if (my $value = $buyer->$_) {
            push @hidden_inputs, ( $buyer_extra{$_} => $value );
        }
    }

    my %cart_extra = (
        discount => 'discount_amount',
        handling => 'handling_amount',
        tax      => 'tax_amount',
    );

    for (keys %cart_extra) {
        if (my $value = $cart->$_) {
            push @hidden_inputs, ( $cart_extra{$_} => $value );
        }
    }

    my $i = 1;

    foreach my $item (@{ $info->{items} }) {
        push @hidden_inputs,
          (
            "item${i}_id"    => $item->id,
            "item${i}_desc"  => $item->description,
            "item${i}_price" => $item->price,
            "item${i}_qty"   => $item->quantity,
          );

        if (my $weight = $item->weight) {
            push @hidden_inputs, ( "item${i}_weight" => $weight * 1000 ); # show in grams
        }

        if (my $ship = $item->shipping) {
            push @hidden_inputs, ( "item${i}_shipping" => $ship );
        }

        if (my $ship = $item->shipping_additional) {
            push @hidden_inputs, ( "item${i}_shipping2" => $ship );
        }

        $i++;
    }

    return @hidden_inputs;
}

1;
