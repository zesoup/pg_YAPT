
package thetime;
use strict;
use warnings;
use 5.20.1;

use POSIX;

sub new {
    my ( $name, %params ) = @_;
    my $self = { config => $params{config} };

    bless( $self, __PACKAGE__ );
    return $self;

}

sub execute {
    my ($obj, $params )  = @_;
    my $packname = __PACKAGE__;
    my $identifier =  ( $params->{label} || $params->{check} );

    $obj->{$identifier}->{metric} =
      strftime "%H:%M:%S", localtime;
    unless ( exists $obj->{$identifier}->{oldmetric} ) {
        $obj->{$identifier}->{oldmetric} = $obj->{$identifier}->{metric};
    }
    if   ( exists $obj->{action} ) { $obj->{$identifier}->{returnVal} = $obj->{action}($obj); }
    else                              
    { $obj->{$identifier}->{returnVal} = [[[$obj->{$identifier}->{metric},0]]]; }
    $obj->{$identifier}->{oldmetric} = $obj->{$identifier}->{metric};
    return 0;
}

1;
