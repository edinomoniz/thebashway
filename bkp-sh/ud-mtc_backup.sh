#!/usr/bin/env bash
# File     : backup.sh
# Author   : Edino "Anakin" <em@mailudc.com>
# Created  : <2019-04-05 Fri 10:08 BST>
# Modified : 
# Sypnosis : Backup MT-TB-RB for VUE sites.


# sleep 20 - to solve issues regarding, mtc service taking too long to sleep, and backup failing.


# Uncomment next line to cat out everything but eth0 block on the interfaces file
# cat /etc/network/interfaces | grep -A5 -v 'eth0' >> /home/rosetta/eth1_interfaces

# Error logging
#exec &> /home/rosetta/backup_error_$(date)_log

#Stops the mtc service before backup starts 
service mtc stop
service ts stop
service rosettaserver stop 

sleep 20

# Defining variables
unique="/opt/servers/distribution"

backupFiles="$unique/mtc/db/ $unique/mtc/conf/transit.properties $unique/ts/conf/config.ini /etc/resolv.conf /etc/network/interfaces /home/rosettaserver/RosettaBridge/*"

destination="/home/rosetta/backup"

day=$(date +%a.%d.%m.%Y)
hostname=$(hostname -s)
archiveFile="$hostname-$day.tar.gz"

# Print start status message.
echo "Backing up $backupFiles to $destination/$archiveFile"
#date
#echo

# Checks if folder backup exists. If folder does not exist it will create it
if [ ! -d "/home/rosetta/backup" ] ;
then
    mkdir "/home/rosetta/backup" ;
fi


# Backup the files using tar.
tar czf $destination/$archiveFile $backupFiles

service mtc start
service ts start 
service rosettaserver stop
sleep 10

#if {
#	statement # in case start service fails 
#	...
#}
