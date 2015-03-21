# This is the main configuration
# It consists of a perl hash,
# If it gets too messy, use perlidy

$config = {

    #Main Information and Params


    # tests will cause try-runs.
    # No connection to the database will be opened.
    tests   => 1,


    # An optional delimiter can be set. Mostly useful for
    # CSV(todo) and wall. 
    #delimiter=> " ",

    # Loglevel will be one of:
    # FATAL, WARN, INFO, debug
    loglevel => "WARN",

    
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

            updatetime => 10000,    #ns

            # define the different checks.
            # An Array of Hashes is expected.
            # [ {check1}, {check2}, {check3} ]
            # Checks refer via 'check' to the
            # checkimplementation.
            # A list is available via pg_YAPT -l
            checks     => [
              #  { check => "Time",    label => "Time" },
               
            ]
	}

    }
};
