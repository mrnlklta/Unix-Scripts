#!/usr/bin/ksh
# Description		:	To run an SQL script with CHANGE_NUMBER which is present in abinitio environment
# Usage				:	ksh <SCRIPT_PATH> <CHANGE_NUMBER> <HOST_ADDR> <SOURCE_DB> <USER_ID> <PASSWD> <PROJECT_DIR> <SQL_FILE>
###################################################################################################################################################

if [ $# -ne 7 ]		#Checking if required parameters are passed
	then
		echo "Invalid number of parameters.
			The script takes 7 parameters
			1. CHANGE NUMBER
			2. HOST ADDRESS
			3. SOURCE DATABASE
			4. USER ID
			5. PASSWORD
			6. PROJECT_DIR
			7. SQL FILE
			Usage: ./<SCRIPT_NAME> <CHANGE_NUMBER> <HOST_ADDR> <SOURCE_DB> <USER_ID> <PASSWD> <PROJECT_DIR> <SQL_FILE>"
	exit 1
fi

export CHANGE_NO=$1
export HOST_ADDR=$2
export SOURCE_DB=$3
export USER_ID=$4
export PASSWD=$5
export PROJECT_DIR=$6
export SQL_FILE=$7

cd $PROJECT_DIR		#Setting-up project in ab initio environment
. ./ab_project_setup.ksh .
if [ $? -ne 0 ]
	then echo "Project Set-up failed. Check PROJECT_DIR path."
	exit 1
fi

SCRIPT_NAME=`basename $0`
CURRENT_DATE=`date +"%Y%m%d%H%M%S"`

export BASENAME_TEMP_SQL=`basename ${SQL_FILE}`		
export TEMP_SQL=/var/tmp/${BASENAME_TEMP_SQL}.tmp	#Creating a temporary SQL file

echo "Executing the SQL "$SQL_FILE" with change_number "$CHANGE_NO"... "
sed s/"CHANGE_NO"/$CHANGE_NO/g ${SQL_FILE} > ${TEMP_SQL}		#Replacing "CHANGE_NO" in the temporary SQL file with the change number value passed to the shell script

nzsql -host $HOST_ADDR -d $SOURCE_DB -u $USER_ID -pw $PASSWD -f ${TEMP_SQL}		#Running the temporary SQL script

rm -f ${TEMP_SQL}		#Removing the temporary SQL file after executing it