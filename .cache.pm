$config1 = {
             'age' => '1425651376',
             'version' => '2.0',
             'checks' => {
                           'Locks' => bless( {
                                               'config' => {},
                                               'name' => 'Locks',
                                               'oldmetric' => [
                                                                [
                                                                  0,
                                                                  0
                                                                ]
                                                              ],
                                               'endstamp' => '1425651377.7991',
                                               'initstamp' => '1425651377.79815',
                                               'query' => '
select * from 
(select count(*) from pg_locks where pid != pg_backend_pid())as locks 
join 
(select count(*) from pg_locks where not granted) as notgranted 
on true;',
                                               'returnVal' => [
                                                                '0[0]',
                                                                0
                                                              ],
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               return [$_[0]{'metric'}[0][0] . '[' . $_[0]{'metric'}[0][1] . ']', $_[0]{'metric'}[0][1]];
                                                           },
                                               'metric' => [],
                                               'plugin' => 'querycheck'
                                             }, 'querycheck' ),
                           'AnlzAge' => bless( {
                                                 'query' => 'select extract(epoch from now() -min(last_analyze))::integer from pg_stat_user_tables ;',
                                                 'name' => 'AnlzAge',
                                                 'config' => {},
                                                 'plugin' => 'querycheck'
                                               }, 'querycheck' ),
                           'S/I' => bless( {
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
                                                             return ['(' . floor(10 * $SEQ / $total) . '/' . floor(10 * $IDX / $total) . ')x' . floor($total / 1000) . 'k', 0];
                                                         },
                                             'plugin' => 'querycheck'
                                           }, 'querycheck' ),
                           'PID' => bless( {
                                             'plugin' => 'querycheck',
                                             'name' => 'PID',
                                             'query' => 'Select pg_backend_pid();',
                                             'config' => {}
                                           }, 'querycheck' ),
                           'I/U/D' => bless( {
                                               'plugin' => 'querycheck',
                                               'returnVal' => [
                                                                '(0/0/0)x0k',
                                                                0
                                                              ],
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
                                                               return ['(' . $INS . '/' . $UPD . '/' . $DEL . ')x' . floor($total / 1000) . 'k', 0];
                                                           },
                                               'metric' => [
                                                             [
                                                               205371117,
                                                               10261165,
                                                               1189294,
                                                               68309,
                                                               20
                                                             ]
                                                           ],
                                               'query' => 'select sum(tup_returned), sum(tup_fetched), sum(tup_inserted), sum(tup_updated), sum(tup_deleted) from pg_stat_database;',
                                               'initstamp' => '1425651377.77692',
                                               'endstamp' => '1425651377.78971',
                                               'name' => 'I/U/D',
                                               'oldmetric' => [],
                                               'config' => {}
                                             }, 'querycheck' ),
                           'txID' => bless( {
                                              'query' => 'select txid_current();',
                                              'plugin' => 'querycheck',
                                              'returnVal' => [
                                                               1,
                                                               0
                                                             ],
                                              'action' => sub {
                                                              package utils;
                                                              use warnings;
                                                              use strict;
                                                              use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                              no feature 'array_base';
                                                              return [$_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0], 0];
                                                          },
                                              'metric' => [
                                                            [
                                                              50403
                                                            ]
                                                          ],
                                              'oldmetric' => [],
                                              'name' => 'txID',
                                              'config' => {},
                                              'initstamp' => '1425651377.79911',
                                              'endstamp' => '1425651377.7997'
                                            }, 'querycheck' ),
                           'TotRows' => bless( {
                                                 'query' => 'select sum(coalesce(reltuples,0) ) from pg_class;',
                                                 'plugin' => 'querycheck',
                                                 'returnVal' => [
                                                                  '0.3',
                                                                  0
                                                                ],
                                                 'units' => [
                                                              'm'
                                                            ],
                                                 'action' => sub {
                                                                 package utils;
                                                                 use warnings;
                                                                 use strict;
                                                                 use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                 no feature 'array_base';
                                                                 return [sprintf('%.1f', $_[0]{'metric'}[0][0] / 1000000), 0];
                                                             },
                                                 'metric' => [
                                                               [
                                                                 264973
                                                               ]
                                                             ],
                                                 'oldmetric' => [],
                                                 'name' => 'TotRows',
                                                 'config' => {},
                                                 'endstamp' => '1425651377.79814',
                                                 'initstamp' => '1425651377.79745'
                                               }, 'querycheck' ),
                           'Random' => bless( {
                                                'config' => {},
                                                'query' => 'select random()*20',
                                                'name' => 'Random',
                                                'plugin' => 'querycheck'
                                              }, 'querycheck' ),
                           'WAL' => bless( {
                                             'metric' => [
                                                           [
                                                             '0/1B090C10'
                                                           ]
                                                         ],
                                             'units' => [
                                                          'MB'
                                                        ],
                                             'returnVal' => [
                                                              '0.0',
                                                              0
                                                            ],
                                             'action' => sub {
                                                             package utils;
                                                             use warnings;
                                                             use strict;
                                                             use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                             no feature 'array_base';
                                                             my $walwritten = (hex(substr $_[0]{'metric'}[0][0], 2, 10) - hex(substr $_[0]{'oldmetric'}[0][0], 2, 10)) / 1048576;
                                                             return [sprintf('%.1f', $walwritten), int $walwritten / 10];
                                                         },
                                             'plugin' => 'querycheck',
                                             'isDelta' => 1,
                                             'query' => 'select pg_current_xlog_location();',
                                             'endstamp' => '1425651377.79039',
                                             'initstamp' => '1425651377.78972',
                                             'config' => {},
                                             'name' => 'WAL',
                                             'oldmetric' => []
                                           }, 'querycheck' ),
                           'User' => bless( {
                                              'metric' => [
                                                            [
                                                              2
                                                            ]
                                                          ],
                                              'returnVal' => [
                                                               2,
                                                               0
                                                             ],
                                              'plugin' => 'querycheck',
                                              'query' => 'select count(*) from pg_stat_activity;',
                                              'initstamp' => '1425651377.7904',
                                              'endstamp' => '1425651377.79171',
                                              'config' => {},
                                              'name' => 'User',
                                              'oldmetric' => []
                                            }, 'querycheck' ),
                           'MaxBlt' => bless( {
                                                'plugin' => 'querycheck',
                                                'returnVal' => [
                                                                 '_tellers/0%',
                                                                 0
                                                               ],
                                                'metric' => [
                                                              [
                                                                '_tellers/0%'
                                                              ]
                                                            ],
                                                'query' => 'select 
substring(relname,length(relname)-7)||\'/\'||round((coalesce(n_dead_tup,0)/coalesce(n_live_tup::numeric+n_dead_tup::numeric,1) )*100,0)::text||\'%\' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;',
                                                'initstamp' => '1425651377.79232',
                                                'endstamp' => '1425651377.79518',
                                                'name' => 'MaxBlt',
                                                'oldmetric' => [],
                                                'config' => {}
                                              }, 'querycheck' ),
                           'TheTime' => bless( {
                                                 'name' => 'TheTime',
                                                 'oldmetric' => [
                                                                  [
                                                                    2684
                                                                  ]
                                                                ],
                                                 'config' => {},
                                                 'endstamp' => '1425651377.7923',
                                                 'initstamp' => '1425651377.79172',
                                                 'query' => 'SELECT floor(extract(epoch from  now() - pg_postmaster_start_time() ))',
                                                 'plugin' => 'querycheck',
                                                 'returnVal' => [
                                                                  2684,
                                                                  0
                                                                ],
                                                 'metric' => []
                                               }, 'querycheck' ),
                           'BlkAcc' => bless( {
                                                'initstamp' => '1425651377.79519',
                                                'endstamp' => '1425651377.79743',
                                                'oldmetric' => [
                                                                 [
                                                                   731089
                                                                 ]
                                                               ],
                                                'name' => 'BlkAcc',
                                                'config' => {},
                                                'plugin' => 'querycheck',
                                                'metric' => [],
                                                'action' => sub {
                                                                package utils;
                                                                use warnings;
                                                                use strict;
                                                                use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                                no feature 'array_base';
                                                                return [sprintf('%.f', ($_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0]) / 125), 0];
                                                            },
                                                'units' => [
                                                             'MB'
                                                           ],
                                                'returnVal' => [
                                                                 0,
                                                                 0
                                                               ],
                                                'query' => 'select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_user_tables ;'
                                              }, 'querycheck' ),
                           'hosttime' => bless( {
                                                  'name' => 'hosttime',
                                                  'config' => {},
                                                  'plugin' => 'thetime'
                                                }, 'thetime' ),
                           'RTupI' => bless( {
                                               'name' => 'RTupI',
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ) from pg_stat_user_indexes',
                                               'config' => {},
                                               'plugin' => 'querycheck',
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $IDX = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($IDX / 1), 0];
                                                           },
                                               'units' => [
                                                            ''
                                                          ]
                                             }, 'querycheck' ),
                           'RTupT' => bless( {
                                               'config' => {},
                                               'query' => 'select sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  from pg_stat_user_tables ',
                                               'name' => 'RTupT',
                                               'units' => [
                                                            ''
                                                          ],
                                               'action' => sub {
                                                               package utils;
                                                               use warnings;
                                                               use strict;
                                                               use feature 'current_sub', 'evalbytes', 'fc', 'say', 'state', 'switch', 'unicode_strings', 'unicode_eval';
                                                               no feature 'array_base';
                                                               my $TBL = $_[0]{'metric'}[0][0] - $_[0]{'oldmetric'}[0][0];
                                                               return [floor($TBL / 1), 0];
                                                           },
                                               'plugin' => 'querycheck'
                                             }, 'querycheck' )
                         },
             'database' => {
                             'connection' => 'host=172.26.14.169;port=5494;dbname=postgres;user=discostu;application_name=pg_YAPT'
                           },
             'UI' => {
                       'csv' => bless( {
                                         'updatetime' => 1000000,
                                         'checks' => [
                                                       'TheTime',
                                                       'I/U/D',
                                                       'WAL',
                                                       'User',
                                                       'TheTime',
                                                       'MaxBlt',
                                                       'BlkAcc',
                                                       'TotRows',
                                                       'Locks',
                                                       'txID'
                                                     ]
                                       }, 'csv' ),
                       'wall' => bless( {
                                          'updatetime' => 1000000,
                                          'checks' => [
                                                        'PID',
                                                        'User',
                                                        'WAL',
                                                        'BlkAcc',
                                                        'TotRows',
                                                        'Locks',
                                                        'MaxBlt',
                                                        'I/U/D',
                                                        'S/I'
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
                                                      ],
                                          'updatetime' => 1000000
                                        }, 'json' )
                     },
             'cache' => {
                          'Locks' => [],
                          'User' => [],
                          'TheTime' => [],
                          'MaxBlt' => [],
                          'TotRows' => [],
                          'WAL' => [],
                          'I/U/D' => [],
                          'txID' => [],
                          'BlkAcc' => []
                        },
             'defaultui' => 'wall',
             'Reattachable' => 1,
             'magicnumber' => '41c429b9cfcb6e1703854fdf2124bb16'
           };
$config1->{'checks'}{'Locks'}{'config'} = $config1;
$config1->{'checks'}{'Locks'}{'metric'} = $config1->{'checks'}{'Locks'}{'oldmetric'};
$config1->{'checks'}{'AnlzAge'}{'config'} = $config1;
$config1->{'checks'}{'S/I'}{'config'} = $config1;
$config1->{'checks'}{'PID'}{'config'} = $config1;
$config1->{'checks'}{'I/U/D'}{'oldmetric'} = $config1->{'checks'}{'I/U/D'}{'metric'};
$config1->{'checks'}{'I/U/D'}{'config'} = $config1;
$config1->{'checks'}{'txID'}{'oldmetric'} = $config1->{'checks'}{'txID'}{'metric'};
$config1->{'checks'}{'txID'}{'config'} = $config1;
$config1->{'checks'}{'TotRows'}{'oldmetric'} = $config1->{'checks'}{'TotRows'}{'metric'};
$config1->{'checks'}{'TotRows'}{'config'} = $config1;
$config1->{'checks'}{'Random'}{'config'} = $config1;
$config1->{'checks'}{'WAL'}{'config'} = $config1;
$config1->{'checks'}{'WAL'}{'oldmetric'} = $config1->{'checks'}{'WAL'}{'metric'};
$config1->{'checks'}{'User'}{'config'} = $config1;
$config1->{'checks'}{'User'}{'oldmetric'} = $config1->{'checks'}{'User'}{'metric'};
$config1->{'checks'}{'MaxBlt'}{'oldmetric'} = $config1->{'checks'}{'MaxBlt'}{'metric'};
$config1->{'checks'}{'MaxBlt'}{'config'} = $config1;
$config1->{'checks'}{'TheTime'}{'config'} = $config1;
$config1->{'checks'}{'TheTime'}{'metric'} = $config1->{'checks'}{'TheTime'}{'oldmetric'};
$config1->{'checks'}{'BlkAcc'}{'config'} = $config1;
$config1->{'checks'}{'BlkAcc'}{'metric'} = $config1->{'checks'}{'BlkAcc'}{'oldmetric'};
$config1->{'checks'}{'hosttime'}{'config'} = $config1;
$config1->{'checks'}{'RTupI'}{'config'} = $config1;
$config1->{'checks'}{'RTupT'}{'config'} = $config1;
$config1->{'cache'}{'Locks'} = $config1->{'checks'}{'Locks'}{'oldmetric'};
$config1->{'cache'}{'User'} = $config1->{'checks'}{'User'}{'metric'};
$config1->{'cache'}{'TheTime'} = $config1->{'checks'}{'TheTime'}{'oldmetric'};
$config1->{'cache'}{'MaxBlt'} = $config1->{'checks'}{'MaxBlt'}{'metric'};
$config1->{'cache'}{'TotRows'} = $config1->{'checks'}{'TotRows'}{'metric'};
$config1->{'cache'}{'WAL'} = $config1->{'checks'}{'WAL'}{'metric'};
$config1->{'cache'}{'I/U/D'} = $config1->{'checks'}{'I/U/D'}{'metric'};
$config1->{'cache'}{'txID'} = $config1->{'checks'}{'txID'}{'metric'};
$config1->{'cache'}{'BlkAcc'} = $config1->{'checks'}{'BlkAcc'}{'oldmetric'};

