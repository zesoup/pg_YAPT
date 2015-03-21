use strict;
use warnings;
use 5.20.1;

package pg_dbi;
use Time::HiRes qw (gettimeofday usleep);
use DBI;

use DBI qw(:sql_types);
use DBD::Pg qw(:pg_types);

use utils;

sub new {
    my (%params) = @_;
    $params{config}->{DB} = {};    #clear last connection (if exists)
    my $self = $params{config}->{DB};
    $self->{config}    = $params{config};
    $self->{connected} = 0;
    bless( $self, __PACKAGE__ );
    if ( $self->{config}->{tests} ) {
        utils::ErrLog( "Tests Enabled! Will not connect to DB!", "DB", "WARN" );
    }
    return $self;
}

sub init {
    if ( $_[0]->{tests} ) { return undef; }
    $_[0]->{DB}->{connected} = 1;
    my $dbh = DBI->connect(
        'DBI:Pg:'
          . $_[0]->{database}->{connection}
          . "; application_name=pg_YAPT",
        "", "",
        {
            PrintError        => 0,
            AutoCommit        => 0,
            pg_server_prepare => 0
        }
      )
      or
      (utils::ErrLog( "Couldnt connect to DB!", "DB", "FATAL" )
      and 
      utils::ErrLog( "\n".$DBI::errstr, "DB", "INFO" ) ) ;
    $dbh->{AutoCommit}  = 0;
    $dbh->{ReadOnly}    = 1;
    $dbh->{destination} = $_[0]->{database}->{connection};
    unless ($dbh) { exit(1); }
    return $dbh;
}

sub commit {
    return
      if (  ( exists $_[0]->{config}->{tests} )
        and ( $_[0]->{config}->{tests} == 1 ) );
    return unless ( UNIVERSAL::isa( $_[0]->{dbh}, "DBI::db" ) );
    $_[0]->{dbh}->commit;
    return;
}

sub ask {
    my ( $config, $query, $qparams, $check) = @_;
    if ( $config->{config}->{tests} ) {
        my $output = [ [0] ];
        $output = $config->{config}->{checks}->{ $check->{identifier} }->{querytest};
        return $output;
    }
    my $attempts = 0;
  RETRY:
    if ( $attempts > $config->{config}->{database}->{maxAttempts} ) {
        die "could not reestablish connection";
    }
    if ($attempts) {
        if ( $config->{connected} ) {
            utils::ErrLog( "DB Error!", "DB", "WARN" );
            utils::ErrLog( "\n".$DBI::errstr, "DB", "INFO" );
            usleep( $config->{config}->{database}->{reconnectdelay} * 1000000 );
            utils::ErrLog( "Trying to reconnect($attempts/".$config->{config}->{database}->{maxAttempts} .")", "DB", "WARN" );
        }
        $config->{dbh} = init( $config->{config} );
    }

    $attempts++;
    goto RETRY unless ( UNIVERSAL::isa( $config->{dbh}, "DBI::db" ) );
    utils::ErrLog( "$query", $check->{identifier}." via DB", "debug" );
    my $stm = $config->{dbh}->prepare($query) or goto RETRY;
    if ( exists $qparams->[0] ) {
        $stm->execute( @{$qparams} );
    }
    else {
        $stm->execute()
          or ( utils::ErrLog( "$_", "DB", "WARN" ) and goto RETRY );
    }
    my $out = $stm->fetchall_arrayref() or goto RETRY;

    return $out;
}

1;

