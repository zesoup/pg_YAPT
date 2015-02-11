use warnings;
use strict;

use 5.20.1;

package statiodiff;

sub new {
    my ( $name, %params ) = @_;
    my $self = { config => $params{config}, name => $params{name} };
    bless( $self, __PACKAGE__ );
    $self->{cache} = [ ["0"] ];
    return $self;
}

sub show {
    my ($obj) = @_;
    my $config = $obj->{config};

    my $params = $obj->{config}->{checks}->{ $obj->{name} };
    my $out    = "";

    my $metric;
    my $packname = __PACKAGE__;

    my $valold = $obj->{cache}[0][0];
    $metric = $config->{dbi}
     ->returnAndStore( "select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ; ", $obj->{name} );

    my $valnew = $metric->[0][0];
    my $diffReads = (($valnew - $valold)*8000)/(1024*1024);

    $obj->{cache}=$metric;
    $out .= "" . sprintf("%.1f",$diffReads ). "MB";
    return $out;
}

1;

