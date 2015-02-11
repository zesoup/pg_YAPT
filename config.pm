$config = {

    #Main Information and Params
    version    => "2.0",
    database   => {},
    updatetime => 100000,    #in ms
                              #Checks
    checks     => {
        thetime => {
            plugin => "thetime",
        },
        walcheck => {
            query  => "select pg_current_xlog_location();",
            plugin => "querycheck"
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
        waldiff => {
            plugin => "waldiff"
        },
        usercount => {
            query  => "select count(*) from pg_stat_activity;",
            plugin => "querycheck"
        },
        tuplereads => {
            plugin => "tuplediff"
        },
        blkaccess => { plugin => "statiodiff" }

    },
    boards => {
        default => {
            template => "rows",    #unused for now
            checks   => {
                0 => "usercount",
                1 => "thetime",
                2 => "tuplereads",

                #2 => "countrows",
                3 => "waldiff",
                4 => "blkaccess"
            }
        }
    }
};
