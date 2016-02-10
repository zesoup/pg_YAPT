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
    my ($config) = $_[0];
    if ( $config->{tests} ) { return undef; }
    $config->{DB}->{connected} = 1;
    
    my $dbh = DBI->connect(
        'DBI:Pg:'
          . $config->{database}->{connection}
          . "; application_name=pg_YAPT",
        "", "",
        {
            PrintError        => 0,
            AutoCommit        => 0,
            pg_server_prepare => 0
        }
      )
      or (  utils::ErrLog( "Couldnt connect to DB!", "DB", "FATAL" )
        and utils::ErrLog( "\n" . $DBI::errstr, "DB", "INFO" ) );
    $dbh->{AutoCommit}  = 0;
    $dbh->{ReadOnly}    = 1;
    $dbh->{destination} = $config->{database}->{connection};
    unless ($dbh) { exit(1); }
    return $dbh;
}

sub commit {
    my ($config) = $_[0];
    return
      if (  ( exists $config->{config}->{tests} )
        and ( $config->{config}->{tests} == 1 ) );
    return unless ( UNIVERSAL::isa( $config->{dbh}, "DBI::db" ) );
    $config->{dbh}->commit;
    return;
}

sub ask {
    my ( $config, $query, $qparams, $check ) = @_;
    if ( $config->{config}->{tests} ) {
        my $output = [ [0] ];
        unless ( exists $check->{base}->{querytest} ) {
            utils::ErrLog( $check->{identifier} . " lacks Querytest!",
                "DBI", "FATAL" );
        }
        $output = $check->{base}->{querytest};
        return $output;
    }

    my $attempts = 0;
    do {
        my $output = 0;

        $output = eval {
            die
              unless ( UNIVERSAL::isa( $config->{dbh}, "DBI::db" ) );
            utils::ErrLog( "$query", $check->{identifier} . " via DB",
                "debug" );
            my $stm = $config->{dbh}->prepare($query) or die;
            if ( exists $qparams->[0] ) {
                $stm->execute( @{$qparams} ) or die;
            }
            else {
                $stm->execute() or die;
            }
            my $out = $stm->fetchall_arrayref() or die;
            return $out;
        };

        if ( not defined $output ) {
            eval {
                if ( $config->{connected} ) {
                    utils::ErrLog( "DB Error!",         "DB", "WARN" );
                    utils::ErrLog( "\n" . $DBI::errstr, "DB", "INFO" );
                    usleep(
                        $config->{config}->{database}->{reconnectdelay} *
                          1000000 );
                    utils::ErrLog(
                        "Trying to reconnect($attempts/"
                          . $config->{config}->{database}->{maxAttempts} . ")",
                        "DB", "WARN"
                    );
                }
                $config->{dbh} = init( $config->{config} );
            };
        }
        else { return $output }
        $attempts = $attempts + 1;

    } while ( $attempts < $config->{config}->{database}->{maxAttempts} );

    die "could not reestablish connection";
}

1;

