
package selectone;
use warnings;
use strict;

use 5.20.1;

sub new {
    my (%params) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub show {
    my (%params) = @_;
    my $config = $params{config};

    my $out = "";
    my $metric;

    #use Data::Dumper;
    my $packname = __PACKAGE__;

    #say Dumper($config->{cache}->{$packname} );

    if ( $config->{cache}->{$packname} ) {
        my $hexvalold = substr $config->{cache}->{$packname}[0][0], 2, 10;
        $metric =
          $config->{dbi}->returnAndStore( $params->{query}, __PACKAGE__ );

        my $hexvalnew = substr $metric->[0][0], 2, 20;
        my $diffBytes = hex($hexvalnew) - hex($hexvalold);
        $diffBytes = $diffBytes / ( 1024 * 1024 );    #approx MB

        $out .= "Diff:" . $diffBytes . " ";
    }
    else {
        $metric = $config->{dbi}
          ->returnAndStore( "Select pg_current_xlog_location()", __PACKAGE__ );
    }
    $out .= $metric->[0][0];
    return $out;
}

1;
