use strict;
use warnings;
use 5.20.1;

package pg_dbi;
use Time::HiRes qw (gettimeofday usleep);
use DBI;
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
    my $dbh = DBI->connect( 'DBI:Pg:' . $_[0]->{database}->{connection},
        "", "", { PrintError => 0, } )
      or
      utils::ErrLog( "Couldnt connect to DB!\n" . $DBI::errstr, "DB", "FATAL" );
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

sub returnAndStore {
    my ( $config, $query, $cachename ) = @_;
    my ( $starts, $startms ) = gettimeofday;
    if ( $config->{config}->{tests} ) {
        my $output = [ [0] ];
        $output = $config->{config}->{checks}->{$cachename}->{querytest};
        return $output;
    }
    my $attempts = 0;
  RETRY:
    if ( $attempts >= $config->{config}->{database}->{maxAttempts} ) {
        die "could not reestablish connection";
    }
    if ($attempts) {
        if ( $config->{connected} ) {
            utils::ErrLog( "Not Connected to DB!", "DB", "WARN" );
            usleep( $config->{config}->{database}->{reconnectdelay} * 1000000 );
            utils::ErrLog( "Trying to reconnect", "DB", "INFO" );
        }
        $config->{dbh} = init( $config->{config} );
    }

    $attempts++;
    goto RETRY unless ( UNIVERSAL::isa( $config->{dbh}, "DBI::db" ) );
    utils::ErrLog( "$query" , "$cachename via DB", "debug");
    my $stm = $config->{dbh}->prepare($query) or goto RETRY;
    $stm->execute() or goto RETRY;

    my $out = $stm->fetchall_arrayref() or goto RETRY;
  my ( $ends, $endms ) = gettimeofday;
    unless ( exists $config->{config}->{DB}->{worsed} ) {
        $config->{config}->{DB}->{worsed} = 0;
    }
    if ( $config->{config}->{DB}->{worsed} < $endms - $startms ) {    # SECONDS!
        $config->{config}->{DB}->{worsed} = $endms - $startms;
    }

    $config->{config}->{cache}->{$cachename} = $out;
    return $out;
}

1;

