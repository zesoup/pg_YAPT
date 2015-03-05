$config = {

    #Main Information and Params
    version   => "2.0",
    database  => {},
    defaultui => 'wall',

    # checks are the check-templates.
    # unless used in the current board,
    # they are not executed.
    # every check consists of at least one plugin.
    # this plugin refers to /plugins/<name>.pm

    # most plugins provide an "action"
    # actions are anonymous functions.
    # they are given a reference to the object.
    #
    # e.g. $_[0]->{metric} refers to the current metric.
    # $_[0]->{oldmetric} refers to the old one.
    # The main purpose of actions are subtractions.( e.g. WAL)
    checks => {
        hosttime => {
            plugin => "thetime",
        },
        "MaxBlt" => {
            query =>
"select substring(relname,length(relname)-7)||'/'||round((coalesce(n_dead_tup,0)/coalesce(n_live_tup::numeric,1) )*100,0)::text||'%' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;",
            plugin => "querycheck"
        },
        "WAL" => {
            query   => "select pg_current_xlog_location();",
            isDelta => 1,
            plugin  => "querycheck",
            units   => ["MB"],
            action  => sub {
                my $walwritten = (
                    hex( substr( $_[0]->{metric}->[0][0], 2, 10 ) ) -
                      hex( substr( $_[0]->{oldmetric}->[0][0], 2, 10 ) ) ) /
                  ( 1024 * 1024 );
                return [ sprintf( "%.1f", $walwritten ),
                    int( $walwritten / 10 ) ];
              }
        },
        'txID' => {
            query  => "select txid_current();",
            plugin => "querycheck",
            action => sub {
                return [ $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0],
                    0 ];
              }
        },
        TheTime => {
            query  => "select to_char(current_timestamp, 'HH24:MI:SS');",
           # query => "select pg_sleep(1.9);",
            plugin => "querycheck"
        },
        "TotRows" => {
            query  => "select sum(coalesce(reltuples,0) ) from pg_class;",
            plugin => "querycheck",
            units  => ["m"],
            action => sub {
                return [ sprintf( "%.1f", $_[0]->{metric}->[0][0] / 1000000 ),
                    0 ];
              }
        },
        User => {
            query  => "select count(*) from pg_stat_activity;",
            plugin => "querycheck"
        },
        'TupReadT' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  from pg_stat_user_tables ",
            plugin => "querycheck",
            units  => [""],
            action => sub {
                my $TBL = $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
                return [ floor($TBL / 1.0), 0 ];
              }
        },

        'TupReadI' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ) from pg_stat_user_indexes",
            plugin => "querycheck",
            units  => [""],
            action => sub {
                my $IDX = $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
                return [ floor($IDX / 1.0), 0 ];
              }
        },
        'Random' => {
            query  => 'select random()*20',
            plugin => "querycheck"
        },
        'BlkAcc' => {
            query =>
"select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;",
            plugin => "querycheck",
            units  => ["MB"],
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

    },

    # Boards are output-modules.
    # e.g. printf-output, curses or JSON.

    UI => {
        wall => {
            template   => "rows",    #unused for now
            updatetime => 1000000,    #ns
            checks     => [
                "User", "TheTime", "TupReadT", "TupReadI",
                "WAL",  "txID",    "BlkAcc",   "TotRows"
            ]
        },
        json => {
            updatetime => 1000000,
            checks     => [ "Random", "WAL", "User", "TheTime", "MaxBlt" ]
        },
        curses => {
            checks => [ "TheTime", "User", "MaxBlt" ]
          }

    }
};
