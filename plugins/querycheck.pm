
package querycheck;
use warnings;
use strict;

use 5.20.1;

sub new {
    my ( $name, %params ) = @_;

    #use Data::Dumper;
    #say Dumper(\%params);
    my $self = { config => $params{config}, name => $params{name} };
    bless( $self, __PACKAGE__ );
    return $self;

}

sub show {
    my ($obj) = @_;
    my $config = $obj->{config};

    my $params = $obj->{config}->{checks}->{ $obj->{name} };
    my $out    = "";

    my $metric;
    my $packname = __PACKAGE__;

    $metric = $config->{dbi}->returnAndStore( $params->{query}, $obj->{name} );

    $out .= $metric->[0][0];
    return $out;
}

1;
