#!/bin/ksh
# Description   : To get the list of mrinal_YYYYMMDD.dat.gz files from $HOME directory that are older than specific days
# USAGE         : ksh <SCRIPT_NAME> <NUMBER_OF_DAYS>
###################################################################################################################################################

if [ $# -ne 1 ]
then
	echo "Invalid number of parameters.
	Usage $0 <NUMBER_OF_DAYS>"
	exit 1
fi

export NUMBER_OF_DAYS=$1

> $HOME/files_list
rm -f $HOME/error_list

last_date=`date --date "$NUMBER_OF_DAYS days ago" +%Y%m%d`  # last_date will hold the date which was $NUMBER_OF_DAYS ago compared to current date
for fullfile in `ls -1rt $HOME/mrinal_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].dat.gz 2>error_list`	#File is present in $HOME directory with structure mrinal_YYYYMMDD.dat.gz
do
	filename=`basename $fullfile`
	file_date=`awk -v b="$filename" 'BEGIN{print substr(b,11,8)}'`
	if [ $file_date -ge $last_date ]
	then
		echo $fullfile >> $HOME/files_list
	fi
done

if [ -f $HOME/error_list ]		#Checking if error_list exists in $HOME directory
then
	exit 1
else
	cat $HOME/files_list
fi