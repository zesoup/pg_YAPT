$config = {

    #Main Information and Params
    version    => "2.0",
    database   => {},
    updatetime => 2000000,    #in ms

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
"select substring(relname,0,6)||'/'||(n_dead_tup/n_live_tup)::text from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;",
            plugin => "querycheck"
        },
        "WAL/d" => {
            query  => "select pg_current_xlog_location();",
            plugin => "querycheck",
            action => sub {
                return sprintf(
                    "%.1f",
                    (
                        hex( substr( $_[0]->{metric}->[0][0], 2, 10 ) ) -
                          hex( substr( $_[0]->{oldmetric}->[0][0], 2, 10 ) )
                    ) / ( 1024 * 1024 )
                ) . "MB";
              }
        },
        'txID/d' => {
            query  => "select txid_current();",
            plugin => "querycheck",
            action => sub {
                return $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
              }
        },
        TheTime => {
            query  => "select to_char(current_timestamp, 'HH24:MI:SS');",
            plugin => "querycheck"
        },
        "TotRows/d" => {
            query  => "select sum(coalesce(reltuples,0) ) from pg_class;",
            plugin => "querycheck",
            action => sub {
                return
                  sprintf( "%.1f", $_[0]->{metric}->[0][0] / 1000000 ) . "mil";
              }
        },
        User => {
            query  => "select count(*) from pg_stat_activity;",
            plugin => "querycheck"
        },
        'TupRead/d' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) ) as reads from pg_stat_user_tables; ",
            plugin => "querycheck",
            action => sub {
                return $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
              }
        },
        'BlkAcc/d' => {
            query =>
"select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;",
            plugin => "querycheck",
            action => sub {
                return sprintf( "%.f",
                    ( $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0] ) /
                      ( ( 1 / 8 ) * 1000 ) )
                  . "MB";
              }
          }

    },

    # Boards are output-modules.
    # e.g. printf-output, curses or JSON.

    boards => {
        default => {
            template => "rows",    #unused for now
            checks   => {
                1 => "User",
                0 => "TheTime",
                2 => "TupRead/d",
                3 => "WAL/d",
                5 => "txID/d",
                4 => "BlkAcc/d",
                6 => "TotRows/d",
                7 => "MaxBlt"
            }
        }
    }
};
