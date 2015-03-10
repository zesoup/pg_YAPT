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
                "WAL", "SIZE", "UpTime",
                "TotRows", "S/I", "I/U/D"
            ]
        },
        list =>{
            template => "list",
            checks => [ "Act" ]
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
                "Random", "WAL",    "User",    "UpTime",
                "MaxBlt", "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        },
        csv => {
            template   => "csv",
            updatetime => 1000000,
            checks     => [
                "TotRows", "WAL",    "User",    "UpTime",
                "MaxBlt",  "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        },
        test => {
            template   => "wall",
            updatetime => 100000,
            checks     => [
                "AnlzAge", "BlkAcc",  "I/U/D",   "Locks",
                "MaxBlt",  "PID",     "QTime",   "RTupI",
                "RTupT",   "Random",  "S/I",     "SIZE",
                "SysBlk",  "UpTime", "TotRows", "User",
                "WAL",     "txID"
              ]

          }

          #curses => {
          #    template => "curses",
          #    checks   => [ "UpTime", "User", "MaxBlt" ]
          #  }

    }
};
