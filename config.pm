# This is the main configuration
# It consists of a perl hash,
# If it gets too messy, use perlidy

$config = {

    #Main Information and Params


    # tests will cause try-runs.
    # No connection to the database will be opened.
    tests   => 0,

    # redirec STDERR to a file
    log => "/var/log/pg_YAPT",

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
                { check => "WAL",     label => "WAL/Files" },
                { check => "SIZE", label=>"DBSize"},
                { check=>"Serial/Index"},
                { check => "User", label => "Usr" },
                { check=>"Locks"},
                { check=>"txID"                 },
                { check => "UpTime",  label => "Uptime" }

            ]
        },
tuples => {
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
                { check => "AccTupleTable"},
                { check => "AccTupleIndex" },
                { check => "Inserted", label => "Inserted" },
                { check => "Updated", label => "Updated" },
                { check => "Deleted", label => "Deleted" },
                { check => "Returned",label => "Returned" },
                { check => "Fetched", label => "Fetched" }

            ]
        },

        curses => {
            template => "curses",
            checks   => [ { check => "UserFull" }, { check => "blkhitread" } ]
        },
        csv => {
            template   => "csv",
            updatetime => 1000000,
            checks     => [
              #  { check => "Time",    label => "Time" },
                { check => "WAL",     label => "WAL" },
               { check => "dirtyd", label=> "New Dirt" },
                { check => "dirty" , label=> "Total Dirt" },
                { check => "SIZE", label=>"DBSize"},
                { check=>"I/U/D" },
                { check=>"Serial/Index", label=>"SI"   },
                { check => "User", label => "U" },
                { check=>"Locks"},
                { check=>"txID"                 },
              #  { check => "ReturnN", qParams=>["42",] },
                { check => "UpTime",  label => "Uptime" }
            ]
          }

    }
};
