use warnings;
use strict;

use 5.20.1;

package waldiff;

sub new {
    my ( $name, %params ) = @_;
    my $self = { config => $params{config}, name => $params{name} };
    bless( $self, __PACKAGE__ );
    $self->{cache} = [ ["0/0000"] ];
    return $self;
}

sub show {
    my ($obj) = @_;
    my $config = $obj->{config};

    my $params = $obj->{config}->{checks}->{ $obj->{name} };
    my $out    = "";

    my $metric;
    my $packname = __PACKAGE__;

    my $hexvalold = substr $obj->{cache}[0][0], 2, 10;
    $metric = $config->{dbi}
      ->returnAndStore( "SELECT pg_current_xlog_location();", $obj->{name} );

    my $hexvalnew = substr $metric->[0][0], 2, 20;
    my $diffBytes = hex($hexvalnew) - hex($hexvalold);
    $diffBytes = $diffBytes / ( 1024 * 1024 );    #approx MB
    $obj->{cache}=$metric;
    $out .= "" . sprintf("%8.2f",$diffBytes ). "MB";
    return $out;
}

1;

