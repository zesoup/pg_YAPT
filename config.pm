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
    loglevel => "INFO",

    
    database => {
        maxAttempts    => 6,
        reconnectdelay => 0.75,
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
              #  { check => "Time",    label => "Time" },
                { check => "WAL",     label => "WAL" },
                { check => "dirtyd", label=> "New Dirt" },
		{ check => "dirty" , label=> "Total Dirt" },
                { check => "User", label => "U" },
                { check => "ReturnN", qParams=>["42",] },
                { check => "UpTime",  label => "Uptime" }
            ]
        },
        curses => {
            template => "curses",
            checks   => [ { check => "UserFull" }, { check => "blkhitread" } ]
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
