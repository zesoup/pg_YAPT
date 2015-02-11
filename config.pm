$config = {

    #Main Information and Params
    version    => "2.0",
    database   => {},
    updatetime => 500000,    #in ms
                             #Checks
    checks     => {
        TheTime => {
            plugin => "thetime",
        },
        "WAL-Diff" => {
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
        txIDCheck => {
            query  => "select txid_current();",
            plugin => "querycheck",
            action => sub {
                return $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
              }
        },
        selectnow => {
            query => "select extract(second from now());",

            # query => "select 8;",
            plugin => "querycheck"
        },
        countrows => {
            query  => "select reltuples from pg_class where relname='neu';",
            plugin => "querycheck",
        },
        UserCount => {
            query  => "select count(*) from pg_stat_activity;",
            plugin => "querycheck"
        },
        'Tuple-Reads' => {
            query =>
"select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) ) as reads from pg_stat_user_tables; ",
            plugin => "querycheck",
            action => sub {
                return $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
              }
        },
        'Block-Access' => {
            query =>
"select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;",
              plugin => "querycheck",
            action => sub {
                return $_[0]->{metric}->[0][0] - $_[0]->{oldmetric}->[0][0];
              }
          }

    },
    boards => {
        default => {
            template => "rows",    #unused for now
            checks   => {
                0 => "UserCount",
                1 => "TheTime",
                2 => "Tuple-Reads",
                3 => "WAL-Diff",
                5 => "txIDCheck",
                4 => "Block-Access"
            }
        }
    }
};
