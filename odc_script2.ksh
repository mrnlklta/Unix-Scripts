#!/usr/bin/ksh
###################################################################################################################################################
# Script        : odc_script2.ksh
# Description   : ODC between a production checksum file and a branch in eme (when production object size is not provided)
# Notes         :
# Usage         : ksh odc_script.ksh
###################################################################################################################################################
# Change History
# Date          Author          Version         Description
# 08/06/2016    Mrinal Kalita   0.2             Initial Version
###################################################################################################################################################

if [ $# -ne 0 ]
then
        echo " Invalid number of parameters.
               The script doesn't need any parameters
               Usage: ksh odc_script.ksh"
        exit 1
fi

echo "Please enter the project path till sandbox name:"
read PROJECT_PATH_TILL_SANDBOX_NAME
echo "Pleae provide the sandbox name:"
read SANDBOX_NAME
echo "Please enter the full path of the production checksum file:"
read PROD_CKSUM_FILE
echo "Please provide the branch name with which ODC needs to be done:"
read BRANCH_NAME

> $HOME/branch_cksum_matches_with_prod_$SANDBOX_NAME.dat
> $HOME/branch_cksum_not_matches_with_prod_$SANDBOX_NAME.dat
> $HOME/objects_not_in_dev_$SANDBOX_NAME.dat

COUNT=1
for OBJECT_NAME in $(cat $PROD_CKSUM_FILE | awk '{print $2}')					#Get object name from production file
do
	OBJECT_NAME=`sed -n "$COUNT"p $PROD_CKSUM_FILE | awk '{print $2}'`		#Get complete eme path by appending $OBJECT_NAME to $PROJECT_PATH_TILL_SANDBOX_NAME
	OBJECT_EME_PATH=$PROJECT_PATH_TILL_SANDBOX_NAME$OBJECT_NAME				#Get Production Checksum values from production file
	PROD_CKSUM=`sed -n "$COUNT"p $PROD_CKSUM_FILE | awk '{print $1}'`
#	PROD_SIZE=`sed -n "$COUNT"p $PROD_CKSUM_FILE | awk '{print $2}'`

	air -branch $BRANCH_NAME ls $OBJECT_EME_PATH
	if [[ $? == 0 ]]
	then
		EME_CHECKSUM=`air -branch $BRANCH_NAME cat $OBJECT_EME_PATH | cksum | awk '{print $1}'`	#Getting eme checksum values from eme with air command
#		EME_SIZE=`air -branch $BRANCH_NAME cat $OBJECT_EME_PATH | cksum | awk '{print $2}'`
		if [[ $EME_CHECKSUM == $PROD_CKSUM ]]
		then
			echo "$PROD_CKSUM $OBJECT_EME_PATH" >> $HOME/branch_cksum_matches_with_prod_$SANDBOX_NAME.dat
		else
			echo "$PROD_CKSUM $OBJECT_EME_PATH" >> $HOME/branch_cksum_not_matches_with_prod_$SANDBOX_NAME.dat
		fi
	else
		echo "$PROD_CKSUM $OBJECT_EME_PATH" >> $HOME/objects_not_in_dev_$SANDBOX_NAME.dat
	fi

	COUNT=`expr $COUNT + 1`
done
