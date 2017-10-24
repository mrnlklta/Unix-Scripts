#!/usr/bin/ksh
###################################################################################################################################################
# Script		: find_locked_objects.ksh
# Description   : Lists down all the locked objects of an user for all the branches present in eme
# Notes         : 
# Usage         : ksh find_locked_objects.ksh
###################################################################################################################################################
# Change History
# Date          Author          Version         Description
# 08/03/2017    Mrinal Kalita   0.1             Initial version for the script
###################################################################################################################################################

echo "Please mention your unix user id:"
read id
echo -e ""
echo "Following objects are locked by user $id :"
for i in `air branch ls | cut -d' ' -f1 | tail -n +2`
do
	a=`air -branch $i lock show -user $id | wc -l`
	if [ $a -gt 1 ]
		then echo $i
		IFS=$'\n'
		for j in `air -branch $i lock show -user $id | tail -n +2`
		do
			echo $j
		done
	fi
done
