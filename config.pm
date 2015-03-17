$config = {

    #Main Information and Params
    version  => "2.0",
    tests    => 0,
    #delimiter=> " ",
    loglevel=> "WARN",
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
                {check=>"Time",label=>"T"},
                {check=>"WAL", label=>"W1"},
                {check=>"WAL", label=>"W2"}, 
                {check=>"ReturnN",label=>"N", param=>[2]}, 
                {check=>"UpTime",label=>"UP"}
            ]
        },
        curses =>{
            template=> "curses",
            checks =>[{check=>"User"},{check=>"blkhitread"}]
           },
        list =>{
            template => "list",
            checks => [{check=>"Act"} ]
         },

        json => {
            template   => "json",
            updatetime => 1000000,
            checks     => [
                {check=>"Random"},{check=>"WAL"}, {check=>"User"},
                {check=>"UpTime"},{check=>"MaxBlt"},{check=>"BlkAcc"}, 
                {check=>"TotRows"},{check=>"Locks"},{check=> "txID"}
            ]
        },
        csv => {
            template   => "csv",
            updatetime => 1000000,
            checks     => [
                {check=>"TotRows"},  {check=>"WAL"},
                {check=>    "User"},  {check=>   "UpTime"},
                {check=>"MaxBlt"},   {check=>"BlkAcc"},
                {check=> "TotRows"}, {check=> "Locks"},
                {check=>"txID"}
            ]
        }

    }
};
