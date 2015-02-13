
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
    my ($obj)  = @_;
    my $packname = __PACKAGE__;


    $obj->{metric} =
      strftime "%H:%M:%S", localtime;
    unless ( exists $obj->{oldmetric} ) {
        $obj->{oldmetric} = $obj->{metric};
    }
    if   ( exists $obj->{action} ) { $obj->{returnVal} = $obj->{action}($obj); }
    else                              
    { $obj->{returnVal} = [($obj->{metric}->[0][0],0)]; }
    $obj->{oldmetric} = $obj->{metric};
    return 0;
}

1;
