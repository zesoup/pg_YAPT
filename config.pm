# This is the main configuration
# It consists of a perl hash,
# If it gets too messy, use perlidy

$config = {

    #Main Information and Params


    # tests will cause try-runs.
    # No connection to the database will be opened.
    tests   => 0,
    humanreadable => 1,
    color => 1,
    # redirec STDERR to a file
    #log => "/var/log/pg_YAPT",

    # An optional delimiter can be set. Mostly useful for
    # CSV(todo) and wall. 
    #delimiter=> " ",

    # Loglevel will be one of:
    # FATAL, WARN, INFO, debug
    loglevel => "INFO",

    
    database => {
        maxAttempts    => 3,
        reconnectdelay => 3,
        connection     => "",
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
                { check => "SIZE", label=>"ClusterSize"},
		{ check=> "BlkAcc", label=>"BlkAcc"},
                { check=>"Serial/Index"},
                { check => "RF",  label => "Ret/Fetch" },
                { check => "User", label => "User/Wait" },
                { check=>"Locks", label=>"Locks/NGranted"},
                { check => "UpTime",  label => "Uptime" },
                { check => "TotRows",  label => "ROWS" },
                { check => "txID",  label => "TXID" },
                { check => "blkhitread",  label => "hit/fetch" }
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
                { check => "AccTupleIndex" },
                { check => "Inserted", label => "Inserted" },
                { check => "Updated", label => "Updated" },
                { check => "Deleted", label => "Deleted" },
                { check => "Returned",label => "Returned" },
                { check => "Fetched", label => "Fetched" }

            ]
        },

        curses => {
            updatetime => 1000000,
            template => "curses",
            checks=>[
                { check => "UserCurses", label => "User/Wait" },
                { check=>"Locks", label=>"Locks/Waiting   "},
		"linebreak",
                { check=>"txID", label=>"Transactions "},
                { check => "UpTime",  label => "Uptime          " },
                {check=>"WAL", label=>"WalWritten  "},
		"linebreak",
                { check=>"TotRows", label=>"DBRows       "},
                { check => "SIZE", label=>"Clustersizer    "},
                { check=>"Serial/Index", label=>"Seq/Idx-Scan"   },
		"linebreak",
                { check=>"BlkAcc", label=>"BlockAccess  "   },
                { check=>"SysBlk", label=>"BlockAccess(sys)" },
		"linebreak", "linebreak",
                { check => "AccTupleTable", label=>"Read Heaptabletuples"},
                { check => "AccTupleIndex", label=>"Read Indextuples"},
		"linebreak",
                { check => "Inserted", label => "Inserted" },
                { check => "Updated", label => "Updated" },
                { check => "Deleted", label => "Deleted" },
                { check => "Returned",label => "Returned" },
                { check => "Fetched", label => "Fetched" },
		"linebreak",
		{ check => "Backends", position=>"bottomlist", action=>"user"}
			]
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
