# This is the main configuration
# It consists of a perl hash,
# If it gets too messy, use perlidy

$config = {

    #Main Information and Params


    # tests will cause try-runs.
    # No connection to the database will be opened.
    tests   => 0,


    # An optional delimiter can be set. Mostly useful for
    # CSV(todo) and wall. 
    #delimiter=> " ",

    # Loglevel will be one of:
    # FATAL, WARN, INFO, debug
    loglevel => "WARN",

    
    database => {
        maxAttempts    => 3,
        reconnectdelay => 0.5,
        connection     => "port=5432;host=localhost;dbname=postgres;",
    },

    defaultui => 'default',

    UI => {
        default => {
            # first, define a "template".
            # pg_YAPT -l will have a list under *checks*.
            template   => "wall",

            updatetime => 1000000,    #ns

            # define the different checks.
            # An Array of Hashes is expected.
            # [ {check1}, {check2}, {check3} ]
            # Checks refer via 'check' to the
            # checkimplementation.
            # A list is available via pg_YAPT -l
            checks     => [
                { check => "Time",    label => "T" },
                { check => "WAL",     label => "W1" },
                { check => "WAL",     label => "W2" },
                { check => "ReturnN", label => "N", param => [2] },
                { check => "UpTime",  label => "UP" }
            ]
        },
        curses => {
            template => "curses",
            checks   => [ { check => "User" }, { check => "blkhitread" } ]
        },
        list => {
            template => "list",
            checks   => [ { check => "Act" } ]
        },

        json => {
            template   => "json",
            updatetime => 1000000,
            checks     => [
                { check => "Random" },
                { check => "WAL" },
                { check => "User" },
                { check => "UpTime" },
                { check => "MaxBlt" },
                { check => "BlkAcc" },
                { check => "TotRows" },
                { check => "Locks" },
                { check => "txID" }
            ]
        },
        csv => {
            template   => "csv",
            updatetime => 1000000,
            checks     => [
                { check => "TotRows" },
                { check => "WAL" },
                { check => "User" },
                { check => "UpTime" },
                { check => "MaxBlt" },
                { check => "BlkAcc" },
                { check => "TotRows" },
                { check => "Locks" },
                { check => "txID" }
            ]
          }

    }
};
