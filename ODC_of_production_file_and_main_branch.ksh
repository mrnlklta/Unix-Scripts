#!/usr/bin/ksh
###################################################################################################################################################
# Script                :       ODC_of_production_file_and_main_branch.ksh
# Description           :       Find the checksum differences of objects of production file and local objects in development and provides respective outputs.
# Usage                 :       ksh ODC_of_production_file_and_main_branch.ksh <BRANCH2_LOCAL_PATH>
# Notes                 :       1. object_ODC.dat file should contain the list of objects to be checked. Format: './mp/graph1.mp'
#                               2. Three output files will be produced. Details of the output files are mentioned as comment inside the script.
#                               3. This script will check cksum of local objects, not eme objects
###################################################################################################################################################
# Change History
# Date          Author          Version         Description
# 27/03/2017    Mrinal Kalita   0.1             Initial version for the script
###################################################################################################################################################


echo "Give the full path of the production checksum file: "
read FILE

> same_cksum.txt
> object_missing.txt
> different_cksum.txt


for i in `cat $FILE`
do
	cksum_val=`cat $i | cut -d' ' -f1`
	cksum_obj=`cat $i | cut -d' ' -f3`
	ls /home/users/mrinal/path$cksum_obj			#Change this to the required path
	if [ $? -ne 0 ]
	then
		echo "$i" >> object_missing.txt             # object_missing.txt will contain objects which are not present in the 2nd branch.
	else
		y=`cksum /home/users/005z19g/Main$i | cut -d' ' -f1`
		if [ $cksum_val = $y ]
		then
			echo "$i" >> same_cksum.txt             # same_cksum.txt will contain objects for which checksum matches.
		else
			echo "$i" >> different_cksum.txt        # different_cksum.txt will contain objects for which checksum difference is there.
		fi
	fi
done
