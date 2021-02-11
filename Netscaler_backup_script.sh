#!/bin/bash
# -----------------------------------------------------------------------------------------------#
####Defining CVS file for data
current_date=$(date +%d-%b-%H_%M)
echo " Backup of Netscaler date: $current_date"

#if file exist output_currentdat.csv 
#empty file echo "ip, error message" > output.csv
#INPUT=InputFile.csv
INPUT=InputFile.csv
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

####Collecting data from CVS file

while read Username Paassword IpAdd NetscalerName
do

    echo "First Checking if System is Live and Runging"

        ##IP address and Password check with SSH "echo Taking Backup of; " 
        if sshpass -p $Paassword ssh -n $Username@$IpAdd 'shell ifconfig | grep "inet " | grep -v 127.0.0.1'>> output_currentdat.csv #remove ping
        then

            ##Creating Backup on remote machine
            sshpass -p $Paassword ssh -n $Username@$IpAdd create system backup $NetscalerName.$current_date -level full
            echo "Backup Done"
            ##copying Backup to local machine
            sshpass -p $Paassword scp $Username@$IpAdd:/var/ns_sys_backup/$NetscalerName.$current_date.tgz /home/irfanakbar/Desktop 
            #echo "Backup copy to local Machine Done"
            backupnewname=$NetscalerName.$current_date'.tgz'
            ##Deleting Old backups
            sshpass -p $Paassword ssh -n $Username@$IpAdd rm system backup $backupnewname
                            



        ##if statment is false
        else echo "User Name or Password is incorrect Or Ip changed"
        >> output_currentdat.csv echo "User Name or Password is incorrect Or Ip changed IP Addr: "$IpAdd #if failed give ip info, ip, and message out put csv
        fi

done <$INPUT
IFS=$OLDIFS
