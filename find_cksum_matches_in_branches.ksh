#!/bin/ksh
################################################################################################################
#Script name    : find_cksum_matches_in_branches.ksh
#Description    : This script is to check for objects in different branches whose checksum matches with production checksum.
#Notes          : The input file should have production checksum and size values and eme object path.
#               : The output 'checksum_found.dat' will contain the matched objects(object name and in which branch it finds the match.)
#               : The output 'checksum_not_matched.dat' will contain the list of objects whose checksums didnot match with any of the branches.
#Usage          : ksh find_cksum_matches_in_branches.ksh <BRANCH1> <BRANCH2> ...
###############################################################################################################
# Change History
# Date          Author          Version         Description
# 28/06/2016    Mrinal Kalita   0.1             Initial version for the script
###################################################################################################################################################

if [ $# -lt 1 ]
then
	echo " Invalid number of parameters.
		The script takes at least one parameter.
		Usage: ./find_cksum_matches_in_branches.ksh <BRANCH1> <BRANCH2> ..."
	exit 1
fi

IFS=$'\n'

echo "Please provide the full path of the file containing object list with checksum: "
read FILE

>$HOME/checksum_found_temp.dat
>$HOME/checksum_found.dat
>$HOME/checksum_not_matched.dat

for BRANCH_NAME in "$@"		#Getting names of all the branches that are mentioned as argument to the script
	do
	for OBJ in $(cat $FILE)
		do
		PROD_CKSUM=`echo $OBJ | awk '{print $1}'`
		PROD_SIZE=`echo $OBJ | awk '{print $2}'`
		OBJ_NAME=`echo $OBJ | awk '{print $3}'`
		BR_CKSUM=`air -branch $BRANCH_NAME cat $OBJ_NAME | cksum | cut -d' ' -f1`
		if [ $PROD_CKSUM == $BR_CKSUM ]
		then
			echo "$OBJ is present in $BRANCH_NAME" >> $HOME/checksum_found_temp.dat		#For matched checksums, object details with branch name will go to this file
		fi
	done
done

sort $HOME/checksum_found_temp.dat >> $HOME/checksum_found.dat
if [ $? -eq 0 ]
	then rm -rf $HOME/checksum_found_temp.dat
fi

sort $FILE >> $HOME/temp1.dat	#Sorted production object list put in temp1.dat
cat $HOME/checksum_found.dat | cut -d' ' -f1,2,3 | uniq >> $HOME/temp2.dat		#Objects which were found to have matching checksums, are sorted and uniqued and put in temp2.dat
comm -32 $HOME/temp1.dat $HOME/temp2.dat >> $HOME/checksum_not_matched.dat		#Lines unique to temp1.dat will be objects whose checksums couldnot be found
if [ $? -eq 0 ]
	then rm -rf $HOME/temp1.dat $HOME/temp2.dat
fi
