$config1 = {
             'defaultui' => 'wall',
             'database' => {
                             'connection' => 'host=127.0.0.1;dbname=postgres;application_name=pg_YAPT'
                           },
             'checks' => {
                           'Locks' => bless( {
                                               'name' => 'Locks',
                                               'oldmetric' => [
                                                                [
                                                                  0,
                                                                  0
                                                                ]
                                                              ],
                                               'returnVal' => [
                                                                '0/0',
                                                                0
                                                              ],
                                               'initstamp' => '1425669909.4087',
                                               'config' => {},
                                               'plugin' => 'querycheck',
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               return [$_[0]{'metric'}[0][0] . '/' . $_[0]{'metric'}[0][1] . '', floor($_[0]{'metric'}[0][1] / 5)];
                                                           },
                                               'endstamp' => '1425669909.40924',
                                               'query' => '
select * from 
(select count(*) from pg_locks where pid != pg_backend_pid())as locks 
join 
(select count(*) from pg_locks where not granted) as notgranted 
on true;',
                                               'metric' => []
                                             }, 'querycheck' ),
                           'WAL' => bless( {
                                             'name' => 'WAL',
                                             'initstamp' => '1425669909.39241',
                                             'oldmetric' => [
                                                              [
                                                                '6/7BEF42E8',
                                                                '00000001000000060000007B'
                                                              ]
                                                            ],
                                             'returnVal' => [
                                                              '0|0',
                                                              0
                                                            ],
                                             'units' => [
                                                          'MB'
                                                        ],
                                             'endstamp' => '1425669909.39263',
                                             'config' => {},
                                             'action' => sub {
                                                             package utils;
                                                             use warnings;
                                                             use strict;
                                                             use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                             no feature 'array_base';
                                                             my $walwritten = (hex(substr $_[0]{'metric'}[0][0], 2, 10) - hex(substr $_[0]{'oldmetric'}[0][0], 2, 10)) / 1048576;
                                                             my $walfiles = hex($_[0]{'metric'}[0][1]) - hex($_[0]{'oldmetric'}[0][1]);
                                                             return [$walfiles . '|' . sprintf('%.0f', $walwritten), $walfiles];
                                                         },
                                             'plugin' => 'querycheck',
                                             'isDelta' => 1,
                                             'query' => 'select pg_current_xlog_location(), pg_xlogfile_name(pg_current_xlog_location() );',
                                             'metric' => []
                                           }, 'querycheck' ),
                           'TheTime' => bless( {
                                                 'endstamp' => '1425669909.39361',
                                                 'plugin' => 'querycheck',
                                                 'config' => {},
                                                 'metric' => [
                                                               [
                                                                 2623
                                                               ]
                                                             ],
                                                 'query' => 'SELECT floor(extract(epoch from  now() - pg_postmaster_start_time() ))',
                                                 'name' => 'TheTime',
                                                 'initstamp' => '1425669909.39337',
                                                 'oldmetric' => [],
                                                 'returnVal' => [
                                                                  2623,
                                                                  0
                                                                ]
                                               }, 'querycheck' ),
                           'TotRows' => bless( {
                                                 'endstamp' => '1425669909.4087',
                                                 'units' => [
                                                              'm'
                                                            ],
                                                 'plugin' => 'querycheck',
                                                 'action' => sub {
                                                                 package utils;
                                                                 use warnings;
                                                                 use strict;
                                                                 use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                 no feature 'array_base';
                                                                 return [sprintf('%.1f', $_[0]{'metric'}[0][0] / 1000000), 0];
                                                             },
                                                 'config' => {},
                                                 'metric' => [
                                                               [
                                                                 '2.08471e+06'
                                                               ]
                                                             ],
                                                 'query' => 'select sum(coalesce(reltuples,0) ) from pg_class;',
                                                 'name' => 'TotRows',
                                                 'initstamp' => '1425669909.4083',
                                                 'oldmetric' => [],
                                                 'returnVal' => [
                                                                  '2.1',
                                                                  0
                                                                ]
                                               }, 'querycheck' ),
                           'Random' => bless( {
                                                'initstamp' => '1425669909.39179',
                                                'oldmetric' => [
                                                                 [
                                                                   '2.85319804213941'
                                                                 ]
                                                               ],
                                                'returnVal' => [
                                                                 '2.85319804213941',
                                                                 0
                                                               ],
                                                'name' => 'Random',
                                                'query' => 'select random()*20',
                                                'metric' => [],
                                                'endstamp' => '1425669909.39241',
                                                'plugin' => 'querycheck',
                                                'config' => {}
                                              }, 'querycheck' ),
                           'User' => bless( {
                                              'returnVal' => [
                                                               1,
                                                               0
                                                             ],
                                              'oldmetric' => [
                                                               [
                                                                 1
                                                               ]
                                                             ],
                                              'initstamp' => '1425669909.39264',
                                              'name' => 'User',
                                              'metric' => [],
                                              'query' => 'select count(*) from pg_stat_activity;',
                                              'plugin' => 'querycheck',
                                              'config' => {},
                                              'endstamp' => '1425669909.39337'
                                            }, 'querycheck' ),
                           'txID' => bless( {
                                              'oldmetric' => [
                                                               [
                                                                 11923456
                                                               ]
                                                             ],
                                              'returnVal' => [
                                                               1,
                                                               0
                                                             ],
                                              'initstamp' => '1425669909.40924',
                                              'name' => 'txID',
                                              'query' => 'select txid_current();',
                                              'metric' => [],
                                              'config' => {},
                                              'plugin' => 'querycheck',
                                              'action' => sub {
                                                              package utils;
                                                              use warnings;
                                                              use strict;
                                                              use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                              no feature 'array_base';
                                                              return [$_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0], 0];
                                                          },
                                              'endstamp' => '1425669909.40939'
                                            }, 'querycheck' ),
                           'S/I' => bless( {
                                             'plugin' => 'querycheck',
                                             'name' => 'S/I',
                                             'action' => sub {
                                                             package utils;
                                                             use warnings;
                                                             use strict;
                                                             use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                             no feature 'array_base';
                                                             my $SEQ = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                             my $IDX = $_[0]{'metric'}[0][1] - $_[0]{'oldmetric'}[0][1];
                                                             my $total = $SEQ + $IDX;
                                                             if ($total <= 0) {
                                                                 $total = 1;
                                                             }
                                                             return [floor(10 * $SEQ / $total) . '/' . floor(10 * $IDX / $total) . '|' . ceil($total / 10000) . 'k', 0];
                                                         },
                                             'config' => {},
                                             'query' => 'select sum(seq_scan), sum(idx_scan) from pg_stat_user_tables;'
                                           }, 'querycheck' ),
                           'SIZE' => bless( {
                                              'name' => 'SIZE',
                                              'plugin' => 'querycheck',
                                              'config' => {},
                                              'units' => [
                                                           'GB'
                                                         ],
                                              'query' => 'select round(sum(pg_database_size(datname))/(1024*1024*1024),1) from pg_database;'
                                            }, 'querycheck' ),
                           'hosttime' => bless( {
                                                  'config' => {},
                                                  'name' => 'hosttime',
                                                  'plugin' => 'thetime'
                                                }, 'thetime' ),
                           'RTupI' => bless( {
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ) from pg_stat_user_indexes',
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $IDX = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($IDX / 1), 0];
                                                           },
                                               'plugin' => 'querycheck',
                                               'name' => 'RTupI',
                                               'config' => {},
                                               'units' => [
                                                            ''
                                                          ]
                                             }, 'querycheck' ),
                           'PID' => bless( {
                                             'query' => 'Select pg_backend_pid();',
                                             'name' => 'PID',
                                             'plugin' => 'querycheck',
                                             'config' => {}
                                           }, 'querycheck' ),
                           'MaxBlt' => bless( {
                                                'plugin' => 'querycheck',
                                                'config' => {},
                                                'endstamp' => '1425669909.40584',
                                                'query' => 'select substring(relname,length(relname)-7)||\'/\'||round((coalesce(n_dead_tup,0)/coalesce(n_live_tup::numeric,1) )*100,0)::text||\'%\' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;',
                                                'metric' => [
                                                              []
                                                            ],
                                                'name' => 'MaxBlt',
                                                'returnVal' => [
                                                                 undef,
                                                                 0
                                                               ],
                                                'oldmetric' => [],
                                                'initstamp' => '1425669909.39361'
                                              }, 'querycheck' ),
                           'BlkAcc' => bless( {
                                                'name' => 'BlkAcc',
                                                'initstamp' => '1425669909.40586',
                                                'returnVal' => [
                                                                 0,
                                                                 0
                                                               ],
                                                'oldmetric' => [
                                                                 [
                                                                   0
                                                                 ]
                                                               ],
                                                'endstamp' => '1425669909.40829',
                                                'units' => [
                                                             'MB'
                                                           ],
                                                'action' => sub {
                                                                package utils;
                                                                use warnings;
                                                                use strict;
                                                                use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                no feature 'array_base';
                                                                return [sprintf('%.f', ($_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0]) / 125), 0];
                                                            },
                                                'plugin' => 'querycheck',
                                                'config' => {},
                                                'query' => 'select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;',
                                                'metric' => []
                                              }, 'querycheck' ),
                           'RTupT' => bless( {
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  from pg_stat_user_tables ',
                                               'units' => [
                                                            ''
                                                          ],
                                               'plugin' => 'querycheck',
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $TBL = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($TBL / 1), 0];
                                                           },
                                               'name' => 'RTupT',
                                               'config' => {}
                                             }, 'querycheck' ),
                           'AnlzAge' => bless( {
                                                 'config' => {},
                                                 'name' => 'AnlzAge',
                                                 'plugin' => 'querycheck',
                                                 'query' => 'select extract(epoch from now() -min(last_analyze))::integer from pg_stat_user_tables ;'
                                               }, 'querycheck' ),
                           'I/U/D' => bless( {
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $INS = $_[0]{'metric'}[0][2] - $_[0]{'oldmetric'}[0][2];
                                                               my $UPD = $_[0]{'metric'}[0][3] - $_[0]{'oldmetric'}[0][3];
                                                               my $DEL = $_[0]{'metric'}[0][4] - $_[0]{'oldmetric'}[0][4];
                                                               my $total = $INS + $UPD + $DEL;
                                                               if ($total <= 0) {
                                                                   $total = 1;
                                                               }
                                                               $INS = floor(10 * $INS / $total);
                                                               $UPD = floor(10 * $UPD / $total);
                                                               $DEL = floor(10 * $DEL / $total);
                                                               return [$INS . '/' . $UPD . '/' . $DEL . '|' . ceil($total / 10000) . 'k', 0];
                                                           },
                                               'name' => 'I/U/D',
                                               'plugin' => 'querycheck',
                                               'config' => {},
                                               'query' => 'select sum(tup_returned), sum(tup_fetched), sum(tup_inserted), sum(tup_updated), sum(tup_deleted) from pg_stat_database;'
                                             }, 'querycheck' )
                         },
             'cache' => {
                          'TotRows' => [],
                          'BlkAcc' => [],
                          'TheTime' => [],
                          'MaxBlt' => [],
                          'WAL' => [],
                          'Locks' => [],
                          'txID' => [],
                          'User' => [],
                          'Random' => []
                        },
             'Reattachable' => 1,
             'version' => '2.0',
             'age' => '1425669908',
             'UI' => {
                       'json' => bless( {
                                          'updatetime' => 1000000,
                                          'checks' => [
                                                        'Random',
                                                        'WAL',
                                                        'User',
                                                        'TheTime',
                                                        'MaxBlt',
                                                        'BlkAcc',
                                                        'TotRows',
                                                        'Locks',
                                                        'txID'
                                                      ]
                                        }, 'json' ),
                       'csv' => bless( {
                                         'checks' => [
                                                       'I/U/D',
                                                       'WAL',
                                                       'User',
                                                       'TheTime',
                                                       'MaxBlt',
                                                       'BlkAcc',
                                                       'TotRows',
                                                       'Locks',
                                                       'txID'
                                                     ],
                                         'updatetime' => 1000000
                                       }, 'csv' ),
                       'wall' => bless( {
                                          'checks' => [
                                                        'User',
                                                        'WAL',
                                                        'txID',
                                                        'BlkAcc',
                                                        'SIZE',
                                                        'TotRows',
                                                        'Locks',
                                                        'RTupT',
                                                        'RTupI',
                                                        'I/U/D',
                                                        'S/I'
                                                      ],
                                          'updatetime' => 1000000
                                        }, 'wall' ),
                       'curses' => bless( {
                                            'checks' => [
                                                          'TheTime',
                                                          'User',
                                                          'MaxBlt'
                                                        ]
                                          }, 'curses' )
                     }
           };
$config1->{'checks'}{'Locks'}{'config'} = $config1;
$config1->{'checks'}{'Locks'}{'metric'} = $config1->{'checks'}{'Locks'}{'oldmetric'};
$config1->{'checks'}{'WAL'}{'config'} = $config1;
$config1->{'checks'}{'WAL'}{'metric'} = $config1->{'checks'}{'WAL'}{'oldmetric'};
$config1->{'checks'}{'TheTime'}{'config'} = $config1;
$config1->{'checks'}{'TheTime'}{'oldmetric'} = $config1->{'checks'}{'TheTime'}{'metric'};
$config1->{'checks'}{'TotRows'}{'config'} = $config1;
$config1->{'checks'}{'TotRows'}{'oldmetric'} = $config1->{'checks'}{'TotRows'}{'metric'};
$config1->{'checks'}{'Random'}{'metric'} = $config1->{'checks'}{'Random'}{'oldmetric'};
$config1->{'checks'}{'Random'}{'config'} = $config1;
$config1->{'checks'}{'User'}{'metric'} = $config1->{'checks'}{'User'}{'oldmetric'};
$config1->{'checks'}{'User'}{'config'} = $config1;
$config1->{'checks'}{'txID'}{'metric'} = $config1->{'checks'}{'txID'}{'oldmetric'};
$config1->{'checks'}{'txID'}{'config'} = $config1;
$config1->{'checks'}{'S/I'}{'config'} = $config1;
$config1->{'checks'}{'SIZE'}{'config'} = $config1;
$config1->{'checks'}{'hosttime'}{'config'} = $config1;
$config1->{'checks'}{'RTupI'}{'config'} = $config1;
$config1->{'checks'}{'PID'}{'config'} = $config1;
$config1->{'checks'}{'MaxBlt'}{'config'} = $config1;
$config1->{'checks'}{'MaxBlt'}{'oldmetric'} = $config1->{'checks'}{'MaxBlt'}{'metric'};
$config1->{'checks'}{'BlkAcc'}{'config'} = $config1;
$config1->{'checks'}{'BlkAcc'}{'metric'} = $config1->{'checks'}{'BlkAcc'}{'oldmetric'};
$config1->{'checks'}{'RTupT'}{'config'} = $config1;
$config1->{'checks'}{'AnlzAge'}{'config'} = $config1;
$config1->{'checks'}{'I/U/D'}{'config'} = $config1;
$config1->{'cache'}{'TotRows'} = $config1->{'checks'}{'TotRows'}{'metric'};
$config1->{'cache'}{'BlkAcc'} = $config1->{'checks'}{'BlkAcc'}{'oldmetric'};
$config1->{'cache'}{'TheTime'} = $config1->{'checks'}{'TheTime'}{'metric'};
$config1->{'cache'}{'MaxBlt'} = $config1->{'checks'}{'MaxBlt'}{'metric'};
$config1->{'cache'}{'WAL'} = $config1->{'checks'}{'WAL'}{'oldmetric'};
$config1->{'cache'}{'Locks'} = $config1->{'checks'}{'Locks'}{'oldmetric'};
$config1->{'cache'}{'txID'} = $config1->{'checks'}{'txID'}{'oldmetric'};
$config1->{'cache'}{'User'} = $config1->{'checks'}{'User'}{'oldmetric'};
$config1->{'cache'}{'Random'} = $config1->{'checks'}{'Random'}{'oldmetric'};

