$config = {

    #Main Information and Params
    version  => "2.0",
    tests    => 0,
    database => {
        maxAttempts    => 9999999,
        reconnectdelay => 0.5,
        connection => "host=127.0.0.1;dbname=postgres;application_name=pg_YAPT"
    },
    defaultui => 'default',

    # Boards are output-modules.
    # e.g. printf-output, curses or JSON.

    UI => {
        default => {
            template   => "wall",
            updatetime => 1000000,    #ns
            checks     => [
                "WAL",   "txID",    "BlkAcc", "SIZE",
                "TotRows", "Locks",  "RTupT",
                "RTupI"
            ]
        },
        wlwork => {
            template   => "wall",
            updatetime => 1000000,
            checks     => [
                "WAL",   "txID",  "SysBlk", "BlkAcc", "QTime", "Locks",
                "RTupT", "RTupI", "S/I",    "I/U/D"
            ]
        },
        wlusers => {
            template   => "wall",
            updatetime => 1000000,                      #ns
            checks     => [ "User", "txID", "Locks" ]
        },
         wlDML => {
            template   => "wall",
            updatetime => 1000000,                      #ns
            checks     => [ "S/I", "I/U/D" ]
        },

        json => {
            template   => "json",
            updatetime => 1000000,
            checks     => [
                "Random", "WAL",    "User",    "TheTime",
                "MaxBlt", "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        },
        csv => {
            template   => "csv",
            updatetime => 1000000,
            checks     => [
                "TotRows", "WAL",    "User",    "TheTime",
                "MaxBlt",  "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        }
        #curses => {
        #    template => "curses",
        #    checks   => [ "TheTime", "User", "MaxBlt" ]
        #  }

    }
};
