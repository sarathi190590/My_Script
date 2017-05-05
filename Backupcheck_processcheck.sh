#!/bin/bash
#
# Server Service Status Check
# @uther : sarathi@glenwoodsystems.com
#
#********************************************************************************************************************
HOST=`hostname -s | sed -r 's/\<./\U&/g'`;
#********************************************************************************************************************
BACKUPCEK()
{
/usr/bin/ps -ef  |  grep -i script  | grep sh | grep -i Backup | grep -v check | grep -v grep 
    if [ $? -eq 0 ]; then
        EMAIL
    else
          echo "No Problem...."
    fi
/usr/bin/ps -ef | grep rsync  | grep -v grep
    if [ $? -eq 0 ]; then
        EMAIL
    else
         echo "No Problem...."
    fi
/usr/bin/ps -ef  | grep 7za | grep -v grep
    if [ $? -eq 0 ]; then
        EMAIL
    else
         echo "No Problem...."
    fi
/usr/bin/ps -ef  | grep pg_dump | grep -v grep
    if [ $? -eq 0 ]; then
        EMAIL
    else
         echo "No Problem...."
    fi
}
#********************************************************************************************************************
EMAIL()
{
sendEmail -s waterbury.glaceemr.net:2500 -v -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com sam@@glenwoodsystems.com -u "$HOST Backup is in Process" -m Please check the Server.
}
#********************************************************************************************************************
BACKUPCEK

