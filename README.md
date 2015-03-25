# pg_YAPT
Yet another postgres top

![alt tag](https://github.com/zesoup/pg_YAPT/blob/master/preview.png)


##Install:
Install dependencies for debian(jessie):

    apt-get install libgetopt-long-descriptive-perl libconfig-inifiles-perl libdbd-pg-perl libterm-readkey-perl libcurses-ui-perl


##Usage:
Update the connectionstring in config.pm or provide one via -d
Run the tool.

    perl pg_YAPT.pl


If there's no DB at hand, set '-T' for dry-run mode.
The tool will now cease to connect to a DB and preconfigured values are returned.

