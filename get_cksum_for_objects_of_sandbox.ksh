#!/bin/bash
# Description   : To get checksum values for all objects present in a sandbox area.
# Notes			: Run the script from the Project directory path of the sandbox. It will create cksum.txt file which will contain the checksum values
# USAGE         : ksh <SCRIPT_NAME>

rm -f cksum.txt

for i in `find -type f -print0 | xargs -0 ls -t`; do
  cksum  "$i" >> cksum.txt
done
