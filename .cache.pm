$config1 = {
             'Reattachable' => 1,
             'UI' => {
                       'csv' => bless( {
                                         'checks' => [
                                                       'TotRows',
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
                                          'updatetime' => 1000000,
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
                                                        'Locks',
                                                        'TheTime'
                                                      ]
                                        }, 'wall' ),
                       'curses' => bless( {
                                            'checks' => [
                                                          'TheTime',
                                                          'User',
                                                          'MaxBlt'
                                                        ]
                                          }, 'curses' ),
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
                                        }, 'json' )
                     },
             'cache' => {
                          'txID' => [
                                      [
                                        11923792
                                      ]
                                    ],
                          'TotRows' => [
                                         [
                                           '2.08471e+06'
                                         ]
                                       ],
                          'MaxBlt' => [
                                        []
                                      ],
                          'BlkAcc' => [
                                        [
                                          0
                                        ]
                                      ],
                          'TheTime' => [
                                         [
                                           10841
                                         ]
                                       ],
                          'User' => [
                                      [
                                        3
                                      ]
                                    ],
                          'WAL' => [
                                     [
                                       '6/8E001D78',
                                       '00000001000000060000008E'
                                     ]
                                   ],
                          'Locks' => [
                                       [
                                         0,
                                         0
                                       ]
                                     ]
                        },
             'defaultui' => 'wall',
             'checks' => {
                           'BlkAcc' => bless( {
                                                'initstamp' => '1425678127.64053',
                                                'action' => sub {
                                                                package utils;
                                                                use warnings;
                                                                use strict;
                                                                use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                no feature 'array_base';
                                                                return [sprintf('%.f', ($_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0]) / 125), 0];
                                                            },
                                                'metric' => [],
                                                'oldmetric' => [],
                                                'config' => {},
                                                'name' => 'BlkAcc',
                                                'query' => 'select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;',
                                                'endstamp' => '1425678127.64229',
                                                'returnVal' => [
                                                                 0,
                                                                 0
                                                               ],
                                                'units' => [
                                                             'MB'
                                                           ],
                                                'plugin' => 'querycheck'
                                              }, 'querycheck' ),
                           'User' => bless( {
                                              'initstamp' => '1425678127.62747',
                                              'metric' => [],
                                              'config' => {},
                                              'query' => 'select count(*) from pg_stat_activity;',
                                              'name' => 'User',
                                              'oldmetric' => [],
                                              'units' => [],
                                              'plugin' => 'querycheck',
                                              'returnVal' => [
                                                               3,
                                                               0
                                                             ],
                                              'endstamp' => '1425678127.62817'
                                            }, 'querycheck' ),
                           'WAL' => bless( {
                                             'action' => sub {
                                                             package utils;
                                                             use warnings;
                                                             use strict;
                                                             use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                             no feature 'array_base';
                                                             my $walwritten = (hex(substr $_[0]{'metric'}[0][0], 2, 10) - hex(substr $_[0]{'oldmetric'}[0][0], 2, 10)) / 1048576;
                                                             my $walfiles = hex(substr $_[0]{'metric'}[0][1], 17, 23) - hex(substr $_[0]{'oldmetric'}[0][1], 17, 23);
                                                             return [$walfiles . '|' . sprintf('%.0f', $walwritten), $walfiles];
                                                         },
                                             'initstamp' => '1425678127.62727',
                                             'isDelta' => 1,
                                             'metric' => [],
                                             'oldmetric' => [],
                                             'name' => 'WAL',
                                             'query' => 'select pg_current_xlog_location(), pg_xlogfile_name(pg_current_xlog_location() );',
                                             'config' => {},
                                             'returnVal' => [
                                                              '0|0',
                                                              0
                                                            ],
                                             'endstamp' => '1425678127.62746',
                                             'units' => [
                                                          'MB'
                                                        ],
                                             'plugin' => 'querycheck'
                                           }, 'querycheck' ),
                           'RTupI' => bless( {
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $IDX = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($IDX / 1), 0];
                                                           },
                                               'config' => {},
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ) from pg_stat_user_indexes',
                                               'name' => 'RTupI',
                                               'units' => [
                                                            ''
                                                          ],
                                               'plugin' => 'querycheck'
                                             }, 'querycheck' ),
                           'Random' => bless( {
                                                'plugin' => 'querycheck',
                                                'config' => {},
                                                'name' => 'Random',
                                                'query' => 'select random()*20'
                                              }, 'querycheck' ),
                           'TotRows' => bless( {
                                                 'metric' => [],
                                                 'action' => sub {
                                                                 package utils;
                                                                 use warnings;
                                                                 use strict;
                                                                 use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                 no feature 'array_base';
                                                                 return [sprintf('%.1f', $_[0]{'metric'}[0][0] / 1000000), 0];
                                                             },
                                                 'initstamp' => '1425678127.6423',
                                                 'endstamp' => '1425678127.64263',
                                                 'returnVal' => [
                                                                  '2.1',
                                                                  0
                                                                ],
                                                 'units' => [
                                                              'm'
                                                            ],
                                                 'plugin' => 'querycheck',
                                                 'oldmetric' => [],
                                                 'query' => 'select sum(coalesce(reltuples,0) ) from pg_class;',
                                                 'name' => 'TotRows',
                                                 'config' => {}
                                               }, 'querycheck' ),
                           'MaxBlt' => bless( {
                                                'oldmetric' => [],
                                                'name' => 'MaxBlt',
                                                'query' => 'select substring(relname,length(relname)-7)||\'/\'||round((coalesce(n_dead_tup,0)/coalesce(n_live_tup::numeric,1) )*100,0)::text||\'%\' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;',
                                                'config' => {},
                                                'endstamp' => '1425678127.64052',
                                                'returnVal' => [
                                                                 undef,
                                                                 0
                                                               ],
                                                'plugin' => 'querycheck',
                                                'units' => [],
                                                'initstamp' => '1425678127.62844',
                                                'metric' => []
                                              }, 'querycheck' ),
                           'AnlzAge' => bless( {
                                                 'config' => {},
                                                 'name' => 'AnlzAge',
                                                 'query' => 'select extract(epoch from now() -min(last_analyze))::integer from pg_stat_user_tables ;',
                                                 'plugin' => 'querycheck'
                                               }, 'querycheck' ),
                           'I/U/D' => bless( {
                                               'query' => 'select sum(tup_returned), sum(tup_fetched), sum(tup_inserted), sum(tup_updated), sum(tup_deleted) from pg_stat_database;',
                                               'name' => 'I/U/D',
                                               'config' => {},
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
                                               'plugin' => 'querycheck'
                                             }, 'querycheck' ),
                           'TheTime' => bless( {
                                                 'config' => {},
                                                 'query' => 'SELECT floor(extract(epoch from  now() - pg_postmaster_start_time() ))',
                                                 'name' => 'TheTime',
                                                 'oldmetric' => [],
                                                 'plugin' => 'querycheck',
                                                 'units' => [],
                                                 'returnVal' => [
                                                                  10841,
                                                                  0
                                                                ],
                                                 'endstamp' => '1425678127.62843',
                                                 'initstamp' => '1425678127.62817',
                                                 'metric' => []
                                               }, 'querycheck' ),
                           'RTupT' => bless( {
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  from pg_stat_user_tables ',
                                               'name' => 'RTupT',
                                               'config' => {},
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $TBL = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($TBL / 1), 0];
                                                           },
                                               'units' => [
                                                            ''
                                                          ],
                                               'plugin' => 'querycheck'
                                             }, 'querycheck' ),
                           'Locks' => bless( {
                                               'config' => {},
                                               'query' => '
select * from 
(select count(*) from pg_locks where pid != pg_backend_pid())as locks 
join 
(select count(*) from pg_locks where not granted) as notgranted 
on true;',
                                               'name' => 'Locks',
                                               'oldmetric' => [],
                                               'plugin' => 'querycheck',
                                               'units' => [],
                                               'returnVal' => [
                                                                '0/0',
                                                                0
                                                              ],
                                               'endstamp' => '1425678127.64324',
                                               'initstamp' => '1425678127.64264',
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               return [$_[0]{'metric'}[0][0] . '/' . $_[0]{'metric'}[0][1] . '', floor($_[0]{'metric'}[0][1] / 5)];
                                                           },
                                               'metric' => []
                                             }, 'querycheck' ),
                           'txID' => bless( {
                                              'endstamp' => '1425678127.64344',
                                              'returnVal' => [
                                                               1,
                                                               0
                                                             ],
                                              'plugin' => 'querycheck',
                                              'units' => [],
                                              'oldmetric' => [],
                                              'config' => {},
                                              'name' => 'txID',
                                              'query' => 'select txid_current();',
                                              'metric' => [],
                                              'initstamp' => '1425678127.64325',
                                              'action' => sub {
                                                              package utils;
                                                              use warnings;
                                                              use strict;
                                                              use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                              no feature 'array_base';
                                                              return [$_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0], 0];
                                                          }
                                            }, 'querycheck' ),
                           'S/I' => bless( {
                                             'plugin' => 'querycheck',
                                             'config' => {},
                                             'name' => 'S/I',
                                             'query' => 'select sum(seq_scan), sum(idx_scan) from pg_stat_user_tables;',
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
                                                         }
                                           }, 'querycheck' ),
                           'PID' => bless( {
                                             'plugin' => 'querycheck',
                                             'config' => {},
                                             'name' => 'PID',
                                             'query' => 'Select pg_backend_pid();'
                                           }, 'querycheck' ),
                           'hosttime' => bless( {
                                                  'plugin' => 'thetime',
                                                  'config' => {},
                                                  'name' => 'hosttime'
                                                }, 'thetime' ),
                           'SIZE' => bless( {
                                              'plugin' => 'querycheck',
                                              'units' => [
                                                           'GB'
                                                         ],
                                              'config' => {},
                                              'name' => 'SIZE',
                                              'query' => 'select round(sum(pg_database_size(datname))/(1024*1024*1024),1) from pg_database;'
                                            }, 'querycheck' )
                         },
             'database' => {
                             'connection' => 'host=127.0.0.1;dbname=postgres;application_name=pg_YAPT'
                           },
             'version' => '2.0',
             'age' => '1425678091'
           };
$config1->{'checks'}{'BlkAcc'}{'metric'} = $config1->{'cache'}{'BlkAcc'};
$config1->{'checks'}{'BlkAcc'}{'oldmetric'} = $config1->{'cache'}{'BlkAcc'};
$config1->{'checks'}{'BlkAcc'}{'config'} = $config1;
$config1->{'checks'}{'User'}{'metric'} = $config1->{'cache'}{'User'};
$config1->{'checks'}{'User'}{'config'} = $config1;
$config1->{'checks'}{'User'}{'oldmetric'} = $config1->{'cache'}{'User'};
$config1->{'checks'}{'WAL'}{'metric'} = $config1->{'cache'}{'WAL'};
$config1->{'checks'}{'WAL'}{'oldmetric'} = $config1->{'cache'}{'WAL'};
$config1->{'checks'}{'WAL'}{'config'} = $config1;
$config1->{'checks'}{'RTupI'}{'config'} = $config1;
$config1->{'checks'}{'Random'}{'config'} = $config1;
$config1->{'checks'}{'TotRows'}{'metric'} = $config1->{'cache'}{'TotRows'};
$config1->{'checks'}{'TotRows'}{'oldmetric'} = $config1->{'cache'}{'TotRows'};
$config1->{'checks'}{'TotRows'}{'config'} = $config1;
$config1->{'checks'}{'MaxBlt'}{'oldmetric'} = $config1->{'cache'}{'MaxBlt'};
$config1->{'checks'}{'MaxBlt'}{'config'} = $config1;
$config1->{'checks'}{'MaxBlt'}{'metric'} = $config1->{'cache'}{'MaxBlt'};
$config1->{'checks'}{'AnlzAge'}{'config'} = $config1;
$config1->{'checks'}{'I/U/D'}{'config'} = $config1;
$config1->{'checks'}{'TheTime'}{'config'} = $config1;
$config1->{'checks'}{'TheTime'}{'oldmetric'} = $config1->{'cache'}{'TheTime'};
$config1->{'checks'}{'TheTime'}{'metric'} = $config1->{'cache'}{'TheTime'};
$config1->{'checks'}{'RTupT'}{'config'} = $config1;
$config1->{'checks'}{'Locks'}{'config'} = $config1;
$config1->{'checks'}{'Locks'}{'oldmetric'} = $config1->{'cache'}{'Locks'};
$config1->{'checks'}{'Locks'}{'metric'} = $config1->{'cache'}{'Locks'};
$config1->{'checks'}{'txID'}{'oldmetric'} = $config1->{'cache'}{'txID'};
$config1->{'checks'}{'txID'}{'config'} = $config1;
$config1->{'checks'}{'txID'}{'metric'} = $config1->{'cache'}{'txID'};
$config1->{'checks'}{'S/I'}{'config'} = $config1;
$config1->{'checks'}{'PID'}{'config'} = $config1;
$config1->{'checks'}{'hosttime'}{'config'} = $config1;
$config1->{'checks'}{'SIZE'}{'config'} = $config1;

