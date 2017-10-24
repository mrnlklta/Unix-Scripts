#!/bin/ksh
#########################################################################################
#  Script Name  - memory_usage.ksh
#  Usage        - ksh memory_usage.ksh
#  Purpose      - This script list the memory usage of users in their home directories.
#                 It has flexibility to pass number of top users whom we want in report.
#                 it can send email as well attaching the generated report.
#  Version      - 0.1
##########################################################################################
clear
echo "Please mention number of Top memory consumers to be listed. Default is 20."
read topcount
if [ $topcount -gt 0 ]
then
     topcount=$topcount
else
     topcount=20
fi
echo "Do you want the memory usage report in email? (y/n)"
read mail_option

if [ "$mail_option" = "y" ] || [ "$mail_option" = "Y" ]; then
        echo "Enter the E-mail Id."
        read emailid
else
        echo "Great!! That will ease my work. Thanks."
fi

cd /home/users
echo "Deleting old files.."
rm $HOME/memory_usage.dat 2>/dev/null
sleep 3
echo "Memory(MB),User, User_Name" >$HOME/memory_usage.dat
echo "Running loop for finding disk usage.."

for i in `ls -1`
do
       du -sk $i >> $HOME/memory_usage_temp1.dat 2>/dev/null
done

sort -n $HOME/memory_usage_temp1.dat|tail -$topcount 1>$HOME/memory_usage_temp2.dat

count=`wc -l $HOME/memory_usage_temp2.dat|cut -d" " -f1`

echo "Finalizing top consumers list.."
sleep 2
for line in {1..$count}
do
        i=`head -$line $HOME/memory_usage_temp2.dat|tail -1`
        mem=`echo $i|cut -d" " -f1`
        memory=`echo $(($mem/1024)) MB`
        user=`echo $i|cut -d" " -f2`
        username=`getent passwd $user`
        userid=`echo $username|cut -d":" -f1`
        name=`echo $username|cut -d":" -f5|cut -d"," -f2-`
        echo "$memory,   $userid,  $name" >> $HOME/memory_usage.dat
done
sleep 2
echo "Removing Temporary Files.."
rm $HOME/memory_usage_temp1.dat
rm $HOME/memory_usage_temp2.dat
sleep 2
if [ "$mail_option" = "y" ] || [ "$mail_option" = "Y" ]; then
        mailx -r "no-reply" -s "Space Usage Report" $emailid -c "mrnlkalita@gmail.com"  < $HOME/memory_usage.dat
        echo "Report has been sent in e-mail to - \"$emailid\"."
        rm $HOME/memory_usage.dat
else
        echo "Script Finished. Summary File is created as - \"$HOME/memory_usage.dat\"."
fi
