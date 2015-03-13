# pg_YAPT
Yet another postgres top

![alt tag](https://github.com/zesoup/pg_YAPT/blob/master/preview.png)


##Install:
Install dependencies for debian(jessie):

    apt-get install libgetopt-long-descriptive-perl libconfig-inifiles-perl


Some checks are built for special postgres addons.
QTime for example uses pg_stat_statements. Consult -lv for each checks documentation.

##Usage:
Update the connectionstring in config.pm or provide one via -d
Run the tool.

    perl pg_YAPT.pl


If there's no DB at hand, set 'tests=>1' in config.
The tool will now cease to connect to a DB and preconfigured values are returned.

pg_YAPT utilizes streams to ensure a clean top-view. For Example:

    ./pg_YAPT -t0 2>>log.err

It will now stream all Errors to log.err and -t0 will log ALL check-durations into stderr.

If the graphical display is not required a data-UI can be chosen to easily work with the data. For example JSON or CSV.

