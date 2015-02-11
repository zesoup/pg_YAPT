
package querycheck;
use warnings;
use strict;

use 5.20.1;

sub new {
    my ( $name, %params ) = @_;

    my $self = { config => $params{config}, name => $params{name} };
    bless( $self, __PACKAGE__ );
    return $self;

}

sub show {
    my ($obj)  = @_;
    my $params = $obj->{config}->{checks}->{ $obj->{name} };
    my $out    = "";

    my $packname = __PACKAGE__;

    $params->{metric} =
      $obj->{config}->{dbi}->returnAndStore( $params->{query}, $obj->{name} );
    unless ( exists $params->{oldmetric} ) {
        $params->{oldmetric} = $params->{metric};
    }
    if   ( exists $params->{action} ) { $out .= $params->{action}($params); }
    else                              { $out .= $params->{metric}->[0][0]; }
    $params->{oldmetric} = $params->{metric};
    return $out;
}

1;
