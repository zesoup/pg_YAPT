
    # checks are the check-templates.
    # unless used in the current board,
    # they are not executed.
    # every check consists of at least one plugin.
    # this plugin refers to /plugins/<name>.pm

    # most plugins provide an "action"
    # actions are anonymous functions.
    # they are given a reference to the object.
    # e.g. $_[0]->{metric} refers to the current metric.
    # $_[0]->{oldmetric} refers to the old one.
    # The main purpose of actions are subtractions.( e.g. WAL)

  # CheckStructure:
  #   NAME => {
  #   plugin => "<pluginname>", #choose a plugin from /plugins.
  #   In OO-terms - this will be the class of the hash.
  #   units  => ["",] , #define the unit of returning values here.
  #   action => sub {}  #define the subaction.
  #   It's ment to enable additional processing.
  #   isDelta=> 0/1,    # is this a Delta? If yes, a previous check is required.
   $checks = {
        hosttime => {
            plugin => "thetime",
        },
        "PID" => {
            query  => "Select pg_backend_pid();",
            plugin => "querycheck",
            querytest=>[[1234]]
        },
        "MaxBlt" => {
            query =>
"select substring(relname,length(relname)-7)||'/'||round((coalesce(n_dead_tup,0)/coalesce(n_live_tup::numeric,1) )*100,0)::text||'%' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;",
            plugin => "querycheck",
            querytest=>[["_tellers/50%"]]
        },
        "WAL" => {
            query =>
"select pg_current_xlog_location(), pg_xlogfile_name(pg_current_xlog_location() );",
            isDelta => 1,
            plugin  => "querycheck",
            units   => ["MB"],
            querytest=> [["6/8FA66AE0","00000001000000060000008F"]],
            action  => sub {
                my $walwritten = (
                    hex( substr( $_[0]->{metric}->[0][0], 2, 10 ) ) -
                      hex( substr( $_[0]->{oldmetric}->[0][0], 2, 10 ) ) ) /
                  ( 1024 * 1024 );
                my $walfiles = (
                    hex( substr($_[0]->{metric}->[0][1]   ,17,23    ) ) -
                    hex( substr($_[0]->{oldmetric}->[0][1],17,23 ) ) );
                return [
                    $walfiles . '|' . sprintf( "%.0f", $walwritten ),
                    $walfiles
                ];
              }
        },
        'S/I' => {
            query =>
              "select sum(seq_scan), sum(idx_scan) from pg_stat_user_tables;",
            plugin => "querycheck",
            querytest => [[0,0]],
            action => sub {
                my $SEQ = $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
                my $IDX = $_[0]->{metric}->[0][1] - $_[0]->{oldmetric}->[0][1];
                my $total = $SEQ + $IDX;
                if ( $total <= 0 ) { $total = 1; }
                return [

                    floor( 10 * $SEQ / $total ) . '/'
                      . floor( 10 * $IDX / $total ) . '|'
                      . ceil( $total / 10000 ) . 'k',
                    0
                ];
              }
        },

        'txID' => {
            query  => "select txid_current();",
            plugin => "querycheck",
            querytest => [[0]],
            action => sub {
                return [ $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0],
                    0 ];
              }
        },
        TheTime => {
            query =>
"SELECT floor(extract(epoch from  now() - pg_postmaster_start_time() ))",
            plugin => "querycheck",
            querytest=>[[0]]
        },
        "TotRows" => {
            query  => "select sum(coalesce(reltuples,0) ) from pg_class;",
            plugin => "querycheck",
            querytest => [[0]],
            units  => ["m"],
            action => sub {
                return [ sprintf( "%.1f", $_[0]->{metric}->[0][0] / 1000000 ),
                    0 ];
              }
        },
        User => {
            query  => "select count(*) from pg_stat_activity;",
            plugin => "querycheck",
            querytest=>[[0]],
        },
        Locks => {
            query => "
select * from 
(select count(*) from pg_locks where pid != pg_backend_pid())as locks 
join 
(select count(*) from pg_locks where not granted) as notgranted 
on true;",
            plugin => "querycheck",
            querytest=>[[0,0]],
            action => sub {
                return [
                    $_[0]->{metric}->[0][0] . '/'
                      . $_[0]->{metric}->[0][1] . '',
                    floor( $_[0]->{metric}->[0][1] / 5 )
                ];
              }
        },
        'RTupT' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  from pg_stat_user_tables ",
            plugin => "querycheck",
            units  => [""],
            querytest => [[0]],
            action => sub {
                my $TBL = $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
                return [ floor( $TBL / 1.0 ), 0 ];
              }
        },
        'I/U/D' => {
            query =>
"select sum(tup_returned), sum(tup_fetched), sum(tup_inserted), sum(tup_updated), sum(tup_deleted) from pg_stat_database;",
            plugin => "querycheck",
            querytest => [[0,0,0,0,0]],
            action => sub {
                my $INS = $_[0]->{metric}->[0][2] - $_[0]->{oldmetric}->[0][2];
                my $UPD = $_[0]->{metric}->[0][3] - $_[0]->{oldmetric}->[0][3];
                my $DEL = $_[0]->{metric}->[0][4] - $_[0]->{oldmetric}->[0][4];
                my $total = $INS + $UPD + $DEL;
                if ( $total <= 0 ) { $total = 1; }
                $INS = floor( 10 * $INS / $total );
                $UPD = floor( 10 * $UPD / $total );
                $DEL = floor( 10 * $DEL / $total );
                return [

                    $INS . '/'
                      . $UPD . '/'
                      . $DEL . '|'
                      . ceil( $total / 10000 ) . 'k',
                    0
                ];
              }

        },
        'SIZE' => {
            query =>
"select round(sum(pg_database_size(datname))/(1024*1024*1024),1) from pg_database;",
            plugin => "querycheck",
            querytest => [[0]],
            units  => [ "GB", ]
        },
        'RTupI' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ) from pg_stat_user_indexes",
            plugin => "querycheck",
            units  => [""],
            querytest => [[0]],
            action => sub {
                my $IDX = $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
                return [ floor( $IDX / 1.0 ), 0 ];
              }
        },
        'AnlzAge' => {
            query =>
"select extract(epoch from now() -min(last_analyze))::integer from pg_stat_user_tables ;",
            plugin => "querycheck",
            querytest => [[0]]
        },
        'Random' => {
            query  => 'select random()*20',
            plugin => "querycheck",
            querytest => [[0]]

        },
        'BlkAcc' => {
            query =>
"select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;",
            plugin => "querycheck",
            units  => ["MB"],
            querytest => [[0]],
            action => sub {
                return [
                    sprintf(
                        "%.f",
                        (
                            $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0]
                        ) / ( ( 1 / 8 ) * 1000 )
                    ),
                    0
                ];
              }
          }

      };

