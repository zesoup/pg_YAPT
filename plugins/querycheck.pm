
package querycheck;
use warnings;
use strict;
use POSIX;
use 5.20.1;
use utils;

sub new {
    shift;
    my ($params) = @_;

    $params->{base} =
      $utils::config->{checks}->{ $params->{check} };
    $params->{identifier} = ( $params->{label} || $params->{check} );
    bless( $params, __PACKAGE__ );
    return $params;

}

sub execute {
    my ($obj) = @_;
    my $identifier = $obj->{identifier};
    utils::stampbegin($obj);
    my $queryparams = undef;    #TODO

    # Call the Query and fetch the result.
    $obj->{metric} =
      $utils::config->{DB}->ask( $obj->{base}->{query}, $obj->{qParams}, $obj );

    # Make sure all values exist
    unless ( defined $obj->{metric} ) {
        $obj->{metric} = $obj->{base}->{querytest};
    }

    if ( not exists $obj->{oldmetric} ) {
        $obj->{oldmetric} = $obj->{metric};

        if ( exists $utils::config->{cache} ) {
            $obj->{oldmetric} =
              $utils::config->{cache}->{ $obj->{identifier} }->{oldmetric};
        }
        elsif ( $obj->{base}->{isDelta} ) {
            $obj->{needsredo} = 1;
        }
    }
    else { $obj->{needsredo} = 0; }

    # Start processing.

    if ( exists $obj->{base}->{action} ) {
        $obj->{returnVal} = $obj->{base}->{action}($obj);
    }
    elsif ( $obj->{base}->{isDelta} ) {
        $obj->{returnVal} = [];
        for ( my $r = 0 ; $r < scalar @{ $obj->{metric} } ; $r++ ) {
            my $rowArr = [];
            for ( my $c = 0 ; $c < scalar @{ $obj->{metric}[$r] } ; $c++ ) {
                push(
                    @{$rowArr},
                    [ $obj->{metric}[$r][$c] - $obj->{oldmetric}[$r][$c], 0 ]
                );
            }
            push( @{ $obj->{returnVal} }, $rowArr );
        }

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
    }
    $obj->{oldmetric} = $obj->{metric};

    utils::stampend($obj);
    utils::checkTiming($obj);

    return 0;
}

1;
