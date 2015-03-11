# pg_YAPT
Yet another postgres top

![alt tag](https://github.com/zesoup/pg_YAPT/blob/master/preview.png)

##Install:
Install dependencies for debian(jessie):

    apt-get install libfile-slurp-perl libgetopt-long-descriptive-perl libconfig-inifiles-perl


Some checks are built for special postgres addons.
QTime for example uses pg_stat_statements.

##Usage:
Update the connectionstring in config.pm.
Run the tool via

    perl pg_YAPT.pl


If there's no DB at hand, set 'tests=>1' in config.
The tool will now cease to connect to a DB and preconfigured values are returned.

pg_YAPT utilizes streams to ensure a clean top-view. For Example:

    ./pg_YAPT -t0 2>>log.err

It will now stream all Errors to log.err and -t0 will log ALL check-durations into stderr.
