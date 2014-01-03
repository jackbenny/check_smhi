# check\_smhi #
A Nagios plugin that checks the SMHI (Sveriges Meteorologiska och Hydrologiska 
Institut) webpage for wheather alerts for a specfic region. If no alerts are
issued for the specified region or district the plugin exits with a STATE\_OK
(0) exit code. If a class 1 warning (lowest on the scale) is issued for the
region the plugin exits with a STATE\_WARNING (1). For class 2 and class 3
wheater alerts the plugin exits with a STATE\_CRITICAL (2) exit code.

## Usage ##
```
-D
   District to check for wheather alerts.
   NOTE: Districts must be quoted, such as "Skåne län utom österlen"
-P
   Print a list with all the avaliable districts.
-h
   Print detailed help screen.
-V
   Print version information.
``` 

Note from above that regions/districts must be quoted as a string!

## Contributions ##
All contriubtions are welcome! Fork the repository, make your changes, push it
back up and send me a pull request. Once I've checked out the code and accepted
it I will add you to the THANKS file and update the CHANGELOG.

## Copyright ##
This plugin is released under the GNU GPL license, version 2. Note that this
plugin may fail at any time! So DON'T rely on this plugin to protect life or
property!

__Note that I am NOT in any way affiliated with SMHI.__ I wrote this plugin on
my own on and my own spare time.
This plugin fetches it's data from [SMHI](http://www.smhi.se) so please use the
plugin with respect for SMHI. For example use a check interval of something like
30 minutes instead of every single minute.
