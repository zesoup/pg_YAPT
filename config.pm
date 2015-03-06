$config = {

    #Main Information and Params
    version  => "2.0",
    database => {
        connection => "host=127.0.0.1;dbname=postgres;application_name=pg_YAPT"
    },
    defaultui => 'wall',

    # Boards are output-modules.
    # e.g. printf-output, curses or JSON.

    UI => {
        wall => {
            updatetime => 1000000,    #ns
            checks     => [
                "User",  "WAL",   "txID", "BlkAcc","SIZE",
                "TotRows", "Locks","RTupT", "RTupI", "Locks", "TheTime"
            ]
        },
        json => {
            updatetime => 1000000,
            checks     => [
                "Random", "WAL",    "User",    "TheTime",
                "MaxBlt", "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        },
        csv=> {
            updatetime => 1000000,
            checks     => [
                "TotRows", "WAL",    "User",    "TheTime",
                "MaxBlt", "BlkAcc", "TotRows", "Locks",
                "txID"
            ]
        },

        curses => {
            checks => [ "TheTime", "User", "MaxBlt" ]
          }

    }
};
