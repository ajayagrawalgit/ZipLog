#!/bin/bash

#HEADER SECTION
clear
echo -e "
───────────────────────────────────────────────────────────────────────────────────────────
─██████████████████─██████████─██████████████─██████─────────██████████████─██████████████─
─██░░░░░░░░░░░░░░██─██░░░░░░██─██░░░░░░░░░░██─██░░██─────────██░░░░░░░░░░██─██░░░░░░░░░░██─
─████████████░░░░██─████░░████─██░░██████░░██─██░░██─────────██░░██████░░██─██░░██████████─
─────────████░░████───██░░██───██░░██──██░░██─██░░██─────────██░░██──██░░██─██░░██─────────
───────████░░████─────██░░██───██░░██████░░██─██░░██─────────██░░██──██░░██─██░░██─────────
─────████░░████───────██░░██───██░░░░░░░░░░██─██░░██─────────██░░██──██░░██─██░░██──██████─
───████░░████─────────██░░██───██░░██████████─██░░██─────────██░░██──██░░██─██░░██──██░░██─
─████░░████───────────██░░██───██░░██─────────██░░██─────────██░░██──██░░██─██░░██──██░░██─
─██░░░░████████████─████░░████─██░░██─────────██░░██████████─██░░██████░░██─██░░██████░░██─
─██░░░░░░░░░░░░░░██─██░░░░░░██─██░░██─────────██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─
─██████████████████─██████████─██████─────────██████████████─██████████████─██████████████─
───────────────────────────────────────────────────────────────────────────────────────────

-----------------------------------------------------------------------------------------------------
 A N   O P E N   S O U R C E   P R O J E C T   |   D E V E L O P E D   B Y   A J A Y   A G R A W A L
-----------------------------------------------------------------------------------------------------


"

######################################################################################################

#USER INPUTS
read -p "Enter the COMPLETE PATH where your logs are stored: " LOGPATH
read -p "Enter the No. of DAYS before which you want the logs to be zipped: " NOSDays

######################################################################################################

#VATIABLE DECLARATIONS
MKDIRNAME="AGEDLOGS_$(date "+%d-%m-%Y_%H-%M")"
LOGCOUNT=$(ls -ltr | grep \.log$ | wc -l)
AGING_LOGS=$(find $LOGPATH -mtime +"$NOSDays" -type f -iname "*.log" | wc -l)

######################################################################################################

echo "TOTAL No. OF LOGS PRESENT IN $LOGPATH = $LOGCOUNT"
echo "Out of which, $AGING_LOGS is the number of log(s) updated $NOSDays DAYS ago"

######################################################################################################

#LOGIC
if [[ $AGING_LOGS -eq 0 ]]
then
	echo -e "Hence, there are no log files present in $LOGPATH which are older than $NOSDays , You don't need to run this utility here in this path."
else
	echo -e "Redirecting the names of Aged logs to templist.txt."
	echo -e "Don't Worry! This file will be removed as soon as you exit this utility."
	find $LOGPATH -mtime +$NOSDays -type f -iname "*.log" > templist.txt
	echo -e ""
	echo -e "templist.txt is now created and it has the names of all the Aged logs."
	echo -e "Below is the list of all the logs which are older than $NOSDays Days ->"
	cat templist.txt
	echo -e ""
	echo -e ""
	echo -e "----------------------------------------------------------------------------------------------------------"
	echo -e "Moving all the logs older than $NOSDays present in $LOGPATH to $MKDIRNAME.tar.gz in the same location now."
	echo -e "----------------------------------------------------------------------------------------------------------"
	mkdir $LOGPATH/$MKDIRNAME
	while read -r file; do mv "$file" $LOGPATH/$MKDIRNAME ; done < templist.txt
	echo -e ""
	tar -cvzf $MKDIRNAME.tar.gz $MKDIRNAME
	cat /dev/null > templist.txt
	rm -f templist.txt
	rm -rf $LOGPATH/$MKDIRNAME
	echo -e ""
	echo -e ""
	echo -e "All the logs older than $NOSDays Days have been ZIPLOGGED now ;) Please find the details below: "
	echo -e "Name of ZIPLOG: $MKDIRNAME.tar.gz"
	echo -e "Path where ZIPLOG is stored: $LOGPATH"
	echo -e "& Hence, the Absolute Path of the ZIPLOG is: $LOGPATH/$MKDIRNAME.tar.gz"
fi

echo -e ""
echo -e ""
echo -e "Thanks for using ZIPLOG. Stay Happy and Stay Motivated :)"
echo -e "Take Care"
echo -e ""
echo -e ""

###############################################################################################
######################################## END OF SCRIPT ########################################
###############################################################################################