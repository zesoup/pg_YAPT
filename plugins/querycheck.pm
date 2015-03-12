
package querycheck;
use warnings;
use strict;
use POSIX;
use 5.20.1;

sub new {
    my ( $name, %params ) = @_;

    my $self = { config => $params{config}, name => $params{name} };

    #    bless( $self, __PACKAGE__ );
    return $self;

}

sub execute {
    my ($obj) = @_;
    my $packname = __PACKAGE__;

    utils::stampbegin($obj);
    $obj->{metric} =
    $obj->{metric} =
      $obj->{config}->{DB}->returnAndStore( $obj->{query}, $obj->{name} );

    #Make sure all values exist
    unless ( defined $obj->{metric} ) {
        $obj->{metric} = $obj->{querytest} ;
    }
    unless ( exists $obj->{oldmetric} ) {
        $obj->{oldmetric} = $obj->{metric};
    }

    if ( exists $obj->{action} ) { $obj->{returnVal} = $obj->{action}($obj); }
    elsif ( ( exists $obj->{isDelta} ) and ( $obj->{isDelta} ) ) {
        $obj->{returnVal} =
          [ [ [ $obj->{'metric'}[0][0] - $obj->{'oldmetric'}[0][0], 0 ] ] ];
    }
    else {
        $obj->{returnVal} = [];

        foreach my $row ( @{ $obj->{metric} } ) {
            my $rowArr = [];
            foreach my $val ( @{$row} ) {
                push( @{$rowArr}, [ $val, 0 ] );
            }
            push( @{ $obj->{returnVal} }, $rowArr );

        }

        #use Data::Dumper; say STDERR Dumper($obj->{returnVal});
    }
    $obj->{oldmetric} = $obj->{metric};
    utils::stampend($obj);
    if (
            ( exists $obj->{config}->{timing} )
        and ( $obj->{config}->{timing} >= 0 )
        and ( ( $obj->{endstamp} - $obj->{initstamp} ) * 1000 >=
            $obj->{config}->{timing} )
      )
    {
        utils::ErrLog(
            ceil( 1000 * ( $obj->{endstamp} - $obj->{initstamp} ) ) . "ms",
            $obj->{name}, "INFO" );
    }

    return 0;
}

1;
