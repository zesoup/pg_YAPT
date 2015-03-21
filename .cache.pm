$VAR1 = {
          'Time' => {
                      'doc' => 'check the local time. usefull if compared with db-host',
                      'name' => 'Time',
                      'plugin' => 'thetime'
                    },
          'txID' => {
                      'query' => 'select txid_current();',
                      'plugin' => 'querycheck',
                      'units' => [],
                      'querytest' => [
                                       [
                                         0
                                       ]
                                     ],
                      'name' => 'txID',
                      'txID' => {
                                  'oldmetric' => [
                                                   [
                                                     88307
                                                   ]
                                                 ],
                                  'initstamp' => '1426712763.80173',
                                  'endstamp' => '1426712763.80193',
                                  'returnVal' => [
                                                   [
                                                     [
                                                       112,
                                                       0
                                                     ]
                                                   ]
                                                 ],
                                  'metric' => [
                                                [
                                                  88307
                                                ]
                                              ]
                                }
                    },
          'QTime' => {
                       'name' => 'QTime',
                       'querytest' => [
                                        [
                                          0
                                        ]
                                      ],
                       'plugin' => 'querycheck',
                       'units' => [
                                    's'
                                  ],
                       'query' => 'SELECT sum( total_time ) FROM pg_stat_statements',
                       'doc' => 'Total time of querys. Part of pg_stat_statements!'
                     },
          'User' => {
                      'querytest' => [
                                       [
                                         0,
                                         0,
                                         0
                                       ]
                                     ],
                      'plugin' => 'querycheck',
                      'units' => [],
                      'User' => {
                                  'metric' => [
                                                [
                                                  '2',
                                                  '0',
                                                  '100'
                                                ]
                                              ],
                                  'returnVal' => [
                                                   [
                                                     [
                                                       '2',
                                                       0
                                                     ],
                                                     [
                                                       '0',
                                                       0
                                                     ],
                                                     [
                                                       '100',
                                                       0
                                                     ]
                                                   ]
                                                 ],
                                  'oldmetric' => [
                                                   [
                                                     '2',
                                                     '0',
                                                     '100'
                                                   ]
                                                 ],
                                  'endstamp' => '1426712763.7856',
                                  'initstamp' => '1426712763.7838'
                                },
                      'name' => 'User',
                      'query' => 'select (select count(*) from pg_stat_activity),(select count(*) from pg_stat_activity where waiting=\'t\'), (select setting from pg_settings where name =\'max_connections\');'
                    },
          'Locks' => {
                       'querytest' => [
                                        [
                                          0,
                                          0
                                        ]
                                      ],
                       'plugin' => 'querycheck',
                       'units' => [],
                       'name' => 'Locks',
                       'Locks' => {
                                    'metric' => [
                                                  [
                                                    '24',
                                                    0
                                                  ]
                                                ],
                                    'returnVal' => [
                                                     [
                                                       [
                                                         '24/0',
                                                         '0'
                                                       ]
                                                     ]
                                                   ],
                                    'endstamp' => '1426712763.80172',
                                    'initstamp' => '1426712763.80114',
                                    'oldmetric' => [
                                                     [
                                                       '24',
                                                       0
                                                     ]
                                                   ]
                                  },
                       'query' => '
SELECT * FROM 
(select count(*) from pg_locks )as locks 
JOIN
(select count(*) from pg_locks where not granted) as notgranted 
on true;',
                       'doc' => 'Total count of locks [Total count of waiting locks].'
                     },
          'ServerAddr' => {
                            'query' => 'select inet_server_addr(),inet_server_port();',
                            'querytest' => [
                                             [
                                               0,
                                               0
                                             ]
                                           ],
                            'plugin' => 'querycheck',
                            'name' => 'ServerAddr'
                          },
          'UpTime' => {
                        'name' => 'UpTime',
                        'units' => [
                                     'h'
                                   ],
                        'plugin' => 'querycheck',
                        'querytest' => [
                                         [
                                           0
                                         ]
                                       ],
                        'query' => 'SELECT round((extract(epoch from  now() - pg_postmaster_start_time() )/(60*60))::numeric,1)',
                        'UpTime' => {
                                      'returnVal' => [
                                                       [
                                                         [
                                                           '0.5',
                                                           0
                                                         ]
                                                       ]
                                                     ],
                                      'metric' => [
                                                    [
                                                      '0.5'
                                                    ]
                                                  ],
                                      'endstamp' => '1426712763.78608',
                                      'initstamp' => '1426712763.78561',
                                      'oldmetric' => [
                                                       [
                                                         '0.5'
                                                       ]
                                                     ]
                                    }
                      },
          'RTupT' => {
                       'doc' => 'Read and Fetched Tuples from Table',
                       'isDelta' => 1,
                       'query' => 'SELECT 
 sum( coalesce(idx_tup_fetch,0)+coalesce(seq_tup_read,0) )  
FROM pg_stat_user_tables ',
                       'name' => 'RTupT',
                       'units' => [
                                    ''
                                  ],
                       'plugin' => 'querycheck',
                       'querytest' => [
                                        [
                                          0
                                        ]
                                      ]
                     },
          'TotRows' => {
                         'query' => 'select sum(coalesce(reltuples,0) ) from pg_class;',
                         'doc' => 'estimate of total existing tuples',
                         'TotRows' => {
                                        'metric' => [
                                                      [
                                                        '2.05936e+06'
                                                      ]
                                                    ],
                                        'returnVal' => [
                                                         [
                                                           [
                                                             '2.1',
                                                             0
                                                           ]
                                                         ]
                                                       ],
                                        'oldmetric' => [
                                                         [
                                                           '2.05936e+06'
                                                         ]
                                                       ],
                                        'initstamp' => '1426712763.80081',
                                        'endstamp' => '1426712763.80113'
                                      },
                         'name' => 'TotRows',
                         'querytest' => [
                                          [
                                            0
                                          ]
                                        ],
                         'units' => [
                                      'm'
                                    ],
                         'plugin' => 'querycheck'
                       },
          'ReturnN' => {
                         'plugin' => 'querycheck',
                         'name' => 'ReturnN',
                         'query' => 'SELECT ? ;',
                         'doc' => 'Returns a given number'
                       },
          'BlkAcc' => {
                        'name' => 'BlkAcc',
                        'querytest' => [
                                         [
                                           0
                                         ]
                                       ],
                        'BlkAcc' => {
                                      'oldmetric' => [
                                                       [
                                                         61378
                                                       ]
                                                     ],
                                      'initstamp' => '1426712763.79837',
                                      'endstamp' => '1426712763.8008',
                                      'metric' => [
                                                    [
                                                      61378
                                                    ]
                                                  ],
                                      'returnVal' => [
                                                       [
                                                         [
                                                           '76',
                                                           0
                                                         ]
                                                       ]
                                                     ]
                                    },
                        'plugin' => 'querycheck',
                        'units' => [
                                     'MB'
                                   ],
                        'query' => 'SELECT 
sum( coalesce(heap_blks_read,0)
+coalesce(heap_blks_hit,0)
+coalesce( idx_blks_hit, 0)
+coalesce( idx_blks_hit, 0)
+coalesce(toast_blks_read, 0)
+coalesce(toast_blks_hit,0)
+coalesce(tidx_blks_hit,0)
+coalesce(tidx_blks_hit,0)
) as reads 
FROM pg_statio_user_tables ;',
                        'doc' => 'shmem accessed for usertables in MB'
                      },
          'blkhitread' => {
                            'doc' => 'blocks hit and blocks fetched from io',
                            'isDelta' => 1,
                            'query' => 'select sum(blks_hit), sum(blks_read), 220000 from pg_stat_database;',
                            'plugin' => 'querycheck',
                            'querytest' => [
                                             [
                                               0,
                                               0,
                                               0
                                             ]
                                           ],
                            'name' => 'blkhitread'
                          },
          'SIZE' => {
                      'query' => 'select round(sum(pg_database_size(datname))/(1024*1024*1024),1) from pg_database;',
                      'plugin' => 'querycheck',
                      'units' => [
                                   'GB'
                                 ],
                      'querytest' => [
                                       [
                                         0
                                       ]
                                     ],
                      'name' => 'SIZE'
                    },
          'AnlzAge' => {
                         'doc' => 'Age of oldest Analyze',
                         'query' => 'select extract(epoch from now() -min(last_analyze))::integer from pg_stat_user_tables ;',
                         'name' => 'AnlzAge',
                         'plugin' => 'querycheck',
                         'querytest' => [
                                          [
                                            0
                                          ]
                                        ]
                       },
          'Act' => {
                     'units' => [],
                     'plugin' => 'querycheck',
                     'name' => 'Act',
                     'query' => 'select datname,usename,
CASE WHEN state = \'idle in transaction\' THEN \'IIT\' ELSE state END

state, pid, application_name, waiting, round(extract(epoch from now() -query_start)) from pg_stat_activity order by state_change, waiting desc;'
                   },
          'I/U/D' => {
                       'querytest' => [
                                        [
                                          0,
                                          0,
                                          0,
                                          0,
                                          0
                                        ]
                                      ],
                       'plugin' => 'querycheck',
                       'name' => 'I/U/D',
                       'query' => 'select sum(tup_returned), sum(tup_fetched), sum(tup_inserted), sum(tup_updated), sum(tup_deleted) from pg_stat_database;',
                       'doc' => '(Inserts / Updates / Deletes) *Scaling'
                     },
          'WAL' => {
                     'WAL' => {
                                'returnVal' => [
                                                 [
                                                   [
                                                     '0|1',
                                                     0
                                                   ]
                                                 ]
                                               ],
                                'metric' => [
                                              [
                                                '0/177BA3B0',
                                                '000000010000000000000017'
                                              ]
                                            ],
                                'oldmetric' => [
                                                 [
                                                   '0/177BA3B0',
                                                   '000000010000000000000017'
                                                 ]
                                               ],
                                'endstamp' => '1426712763.78378',
                                'initstamp' => '1426712763.78353'
                              },
                     'doc' => 'New WAL-Files | Wal written in MB',
                     'query' => 'select pg_current_xlog_location(), pg_xlogfile_name(pg_current_xlog_location() );',
                     'units' => [
                                  'MB'
                                ],
                     'plugin' => 'querycheck',
                     'name' => 'WAL',
                     'isDelta' => 1,
                     'querytest' => [
                                      [
                                        '6/8FA66AE0',
                                        '00000001000000060000008F'
                                      ]
                                    ]
                   },
          'S/I' => {
                     'query' => 'SELECT coalesce(sum(seq_scan),0), coalesce(sum(idx_scan),0) from pg_stat_user_tables;',
                     'doc' => 'SeqScans vs IndexScans on Usertables',
                     'querytest' => [
                                      [
                                        0,
                                        0
                                      ]
                                    ],
                     'plugin' => 'querycheck',
                     'name' => 'S/I'
                   },
          'SysBlk' => {
                        'query' => 'select sum( coalesce(heap_blks_read,0)+coalesce(heap_blks_hit,0)+coalesce( idx_blks_hit, 0)+coalesce( idx_blks_hit, 0)+ coalesce(toast_blks_read, 0)+coalesce(toast_blks_hit,0)+coalesce(tidx_blks_hit,0)+coalesce(tidx_blks_hit,0) ) as reads from pg_statio_sys_tables ;',
                        'doc' => 'shmem accessed for systables in MB',
                        'name' => 'SysBlk',
                        'querytest' => [
                                         [
                                           0
                                         ]
                                       ],
                        'units' => [
                                     'MB'
                                   ],
                        'plugin' => 'querycheck'
                      },
          'MaxBlt' => {
                        'querytest' => [
                                         [
                                           '_tellers/50%'
                                         ]
                                       ],
                        'MaxBlt' => {
                                      'returnVal' => [
                                                       [
                                                         [
                                                           'branches/99%',
                                                           0
                                                         ]
                                                       ]
                                                     ],
                                      'metric' => [
                                                    [
                                                      'branches/99%'
                                                    ]
                                                  ],
                                      'oldmetric' => [
                                                       [
                                                         'branches/99%'
                                                       ]
                                                     ],
                                      'initstamp' => '1426712763.78609',
                                      'endstamp' => '1426712763.79835'
                                    },
                        'plugin' => 'querycheck',
                        'units' => [],
                        'name' => 'MaxBlt',
                        'query' => 'select substring(relname,length(relname)-7)||\'/\'||round((coalesce(n_dead_tup,0)/(coalesce(n_dead_tup::numeric,1)+coalesce(n_live_tup::numeric,1) ))*100,0)::text||\'%\' from pg_stat_user_tables where n_live_tup > 0 order by n_dead_tup / n_live_tup desc limit 1 ;',
                        'doc' => 'show the bloatest table'
                      },
          'PID' => {
                     'query' => 'SELECT pg_backend_pid();',
                     'doc' => 'returns the current backendPID of the checking process. ',
                     'querytest' => [
                                      [
                                        0
                                      ]
                                    ],
                     'plugin' => 'querycheck',
                     'name' => 'PID'
                   },
          'Random' => {
                        'querytest' => [
                                         [
                                           0
                                         ]
                                       ],
                        'plugin' => 'querycheck',
                        'name' => 'Random',
                        'query' => 'select random()*20'
                      },
          'RTupI' => {
                       'units' => [
                                    ''
                                  ],
                       'plugin' => 'querycheck',
                       'querytest' => [
                                        [
                                          0
                                        ]
                                      ],
                       'name' => 'RTupI',
                       'doc' => 'Read and Fetched Tuples from Indices',
                       'isDelta' => 1,
                       'query' => 'SELECT coalesce(sum( coalesce(idx_tup_fetch,0)+coalesce(idx_tup_read,0) ),0) FROM pg_stat_user_indexes'
                     }
        };

