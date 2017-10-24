#!/usr/bin/ksh
###################################################################################################################################################
# Script                :       ODC_local_of_two_branches.ksh
# Description           :       Find the checksum differences of objects of two branches(local paths) and provides respective outputs.
# Usage                 :       ksh ODC_of_two_branches.ksh <BRANCH1_LOCAL_PATH> <BRANCH2_LOCAL_PATH>
# Notes                 :       1. object_ODC.dat file should contain the list of objects to be checked. Format: './mp/graph1.mp'
#                               2. Three output files will be produced. Details of the output files are mentioned as comment inside the script.
#                               3. This script will check cksum of local objects, not eme objects
###################################################################################################################################################
# Change History
# Date          Author          Version         Description
# 27/03/2017    Mrinal Kalita   0.1             Initial version for the script
###################################################################################################################################################


if [ $# -ne 2 ]
then
	echo "Invalid number of parameters:
	The scipt takes two parameters:
	1. Full local path of first branch, eg /home/users/mrinal/Projects/lesson1/
	2. Full local path of second branch, eg /home/users/mrinal/Projects/lesson2/
	Usage: ksh ODC_of_two_branches.ksh <BRANCH1_LOCAL_PATH> <BRANCH2_LOCAL_PATH>"
	exit 1
fi

BRANCH1_PATH=$1
BRANCH2_PATH=$2

> object_ODC.dat
> same_cksum.txt
> object_missing.txt
> different_cksum.txt

ls $BRANCH2_PATH
if [ $? -ne 0 ]
then
	echo "Branch2 local path doesnot exists. Please check the path again."
	exit 1
fi

cd $BRANCH1_PATH
if [ $? -ne 0 ]
then
	echo "Branch1 local path doesnot exists. Please check the path again."
	exit 1
else
	for j in `find -type f -print0 | xargs -0 ls -t`; do    #This will get the list of local objects of Branch1 to match checksum with Branch2 local objects:
		echo "$j" >> object_ODC.dat
	done
fi

cd -
mv $BRANCH1_PATH/object_ODC.dat $PWD/object_ODC.dat
for i in `cat object_ODC.dat`
do
	x=`cksum $BRANCH1_PATH$i | cut -d' ' -f1`
	ls $BRANCH2_PATH$i
	if [ $? -ne 0 ]
	then
		echo "$i" >> object_missing.txt        # object_missing.txt will contain objects which are not present in the 2nd branch.
	else
		y=`cksum $BRANCH2_PATH$i | cut -d' ' -f1`
		if [ $x = $y ]
		then
			echo "$i" >> same_cksum.txt        # same_cksum.txt will contain objects for which checksum matches.
		else
			echo "$i" >> different_cksum.txt   # different_cksum.txt will contain objects for which checksum difference is there.
		fi
	fi
done

