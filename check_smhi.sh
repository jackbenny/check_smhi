#!/bin/bash

################################################################################
#                                                                              #
#  Copyright (C) 2014 Jack-Benny Persson <jack-benny@cyberinfo.se>             #
#                                                                              #
#   This program is free software; you can redistribute it and/or modify       #
#   it under the terms of the GNU General Public License as published by       #
#   the Free Software Foundation; either version 2 of the License, or          #
#   (at your option) any later version.                                        #
#                                                                              #
#   This program is distributed in the hope that it will be useful,            #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#   GNU General Public License for more details.                               #
#                                                                              #
#   You should have received a copy of the GNU General Public License          #
#   along with this program; if not, write to the Free Software                #
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  #
#                                                                              #
################################################################################

# check_smhi
Version="0.1"
Author="Jack-Benny Persson (jack-benny@cyberinfo.se)"

# Binaries
Which="/usr/bin/which"
# Binaries entered in the list will be avalible to the script as variables with
# the first letter uppercase
Binaries=(sed awk egrep printf curl)

# Variables
District=""
State_ok=0
State_warning=1
State_critical=2
State_unknown=3
AvailDistricts=(
"Skagerack"
"Vänern"
"Kattegatt"
"Bälten"
"Sydvästra Östersjön"
"Södra Östersjön"
"Sydöstra Östersjön"
"Mellersta Östersjön"
"Mellersta Östersjön"
"Norra Östersjön"
"Rigabukten"
"Finska viken"
"Skärgårdshavet"
"Södra Bottenhavet"
"Norra Bottenhavet"
"Norra Kvarken"
"Bottenviken"
"Dalarnas län, Dalafjällen"
"Jämtlands län, Härjedalsfjällen"
"Jämtlands län, Jämtlandsfjällen"
"Västerbottens län, södra Lapplandsfjällen"
"Norrbottens län, norra Lapplandsfjällen"
"Skåne län utom österlen"
"Skåne län, österlen"
"Blekinge län"
"Hallands län"
"Kronobergs län, västra delen"
"Kronobergs län, östra delen"
"Kalmar län, öland"
"Gotlands län"
"Jönköpings län, västra delen utom syd om Vättern"
"Jönköpings län, östra delen"
"Kalmar län utom öland"
"Jönköpings län, syd om Vättern"
"Västra Götalands län, Sjuhäradsbygden och Göta älv"
"Västra Götalands län, Bohuslän och Göteborg"
"Västra Götalands län, inre Dalsland"
"Västra Götalands län, sydväst Vänern"
"Västra Götalands län, norra Västergötland"
"Värmlands län"
"Södermanlands län"
"Stockholms län utom Roslagskusten."
"Västmanlands län"
"Uppsala län utom Upplandskusten"
"Stockholms län, Roslagskusten"
"Uppsala län, Upplandskusten"
"Dalarnas län utom Dalafjällen"
"Gävleborgs län kustland"
"Gävleborgs län inland"
"Västernorrlands län"
"Jämtlands län utom fjällen"
"Västerbottens län kustland"
"Västerbottens län inland"
"Norrbottens län kustland"
"Norrbottens län inland"
)

### Functions ###

# Print version information
print_version()
{
        $Printf "\n$0 - $Version\n"
}

# Print help information
print_help()
{
        print_version
        $Printf "$Author\n"
        $Printf "check_smhi\n"
	/bin/cat <<-EOT

	Options:
	-D
	   District to check for wheather alerts.
	   NOTE: Districts must be quoted, such as "Skåne län utom österlen"
	-P
	   Print a list with all the avaliable districts.
	-h
	   Print detailed help screen.
	-V
	   Print version information.
	EOT
}

# Create variables with absolute path to binaries and check
# if we can execute it (binaries will be avaliable in 
# variables with first character uppercase, such as Grep)
Count=0
for i in ${Binaries[@]}; do
	$Which $i &> /dev/null
	if [ $? -eq 0 ]; then
		declare $(echo ${Binaries[$Count]^}=`${Which} $i`)
		((Count++))
	else
		echo "It seems you don't have ${Binaries[$Count]} installed"
		exit 1
	fi
done

# Sanity check (options and arguments)
if [ $# -eq 0 ]; then
	echo "$0 requires an option"
	print_help
	exit $State_unknown

elif [ $# -ge 1 ]; then
	echo "$1" | $Egrep -q "\-."
	if [ $? -ne 0 ]; then
		echo "$0 requires an option"
		print_help
		exit $State_unknown
	fi
fi

# Parse command line options and arguments
while getopts D:hVP Opt; do
       	case "$Opt" in
	D) District="$OPTARG"
	   ;;
       	h) print_help
   	   exit $State_ok
       	   ;;
       	V) print_version
   	   exit $State_ok
       	   ;;
	P) Total=${#AvailDistricts[@]} 
	   Num=0
	   while [ $Num -lt $Total ]; do
		echo "${AvailDistricts[$Num]}"
		((Num++))
	   done
	   exit $State_ok
	   ;;
       	*) print_help
       	   exit $State_unknown
       	   ;;
       	esac
done

# Check if the disctrict exists
Tot=${#AvailDistricts[@]}
Index=0
Match=0

while [ $Index -lt $Tot ]; do
	echo ${AvailDistricts[$Index]} | $Egrep -x "$District" &> /dev/null
	if [ $? -eq 0 ]; then
		Match=1
		break
	fi
	((Index++))
done

if [ $Match -eq 0 ]; then
	echo "District $District does not exist"
	print_help
fi


### Main ###

# Fetch the warning page
Data=`$Curl -s http://www.smhi.se/vadret/vadret-i-sverige/Varningar/varning_tabell_n1_sv.htm`

# First we must replace all åäö with their HTML equivalent
HtmlDist=`echo $District | $Sed '{
s/å/\&aring\;/g
s/Å/\&Aring\;/g
s/ä/\&auml\;/g
s/Ä/\&Auml\;/g
s/ö/\&ouml\;/g
s/Ö/\&Ouml\;/g
}'`

# Get the line number for the current district in the HTML-file and add one line to it
LineNr=`echo "$Data" | $Sed -n "/$HtmlDist/="`
((LineNr++))

# Read the warning message (for example kuling, orkan, åska)
WarnMsg=`echo "$Data" | $Sed -n "${LineNr}p" | $Egrep -o "Varning klass [0-3] .*" | \
$Sed 's/\(.*\).........../\1/' | \
$Awk '{print substr($0, index($0,$4))}'` 

# Get the current warning class (1, 2 and 3)
Class=`echo "$Data" | $Sed -n "${LineNr}p" | $Egrep -o "Varning klass [0-3]" \
| $Awk '{ print $3 }'`

# Chech the current warning class issued for the district
if [ -z $Class ]; then
	echo "No warnings issued for $District"
	exit $State_ok
elif [ $Class -eq 1 ]; then
	echo "Class ${Class} warning issued for $District: $WarnMsg"
	exit $State_warning
elif [ $Class -eq 2 ]; then
	echo "Class ${Class} warning issued for $District: $WarnMsg"
	exit $State_critical
elif [ $Class -eq 3 ]; then
	echo "Class ${Class} warning issued for $District: $WarnMsg"
	exit $State_critical
else
	echo "Unknown data from SHMI"
	exit $State_unknown
fi

# Catch all unknown errors (if we got this far, something went terribly wrong)
echo "Something went wrong with $0"
exit $State_unknown
