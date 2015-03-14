$config = {

    #Main Information and Params
    version  => "2.0",
    tests    => 0,
    #delimiter=> " ",
    loglevel=> "INFO",
    database => {
        maxAttempts    => 3,
        reconnectdelay => 0.5,
          connection=>"port=5432;host=localhost;dbname=postgres;",
    },
    defaultui => 'default',

    # Boards are output-modules.
    # e.g. printf-output, curses or JSON.

    UI => {
        default => {
            template   => "wall",
            updatetime => 1000000,    #ns
            checks     => [
                "Time","WAL", "SIZE", "UpTime",
                "TotRows", "S/I", "I/U/D","User", "txID"
            ]
        },
        curses =>{
            template=> "curses",
            checks =>["User"]
           },
        list =>{
            template => "list",
            checks => [ "Act" ]
         },
        wlwork => {
            template   => "wall",
            updatetime => 1000000,
            checks     => [
                "WAL",  "txID",  "SysBlk", "BlkAcc",  "Locks",
                "RTupT", "RTupI", "S/I",    "I/U/D"
            ]
        },
        wlusers => {
            template   => "wall",
            updatetime => 1000000,                      #ns
            checks     => [ "User", "Locks" ]
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
