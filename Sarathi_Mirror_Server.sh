BKP_EXTNS=".7z" ;DAY=`date +%A`;
varDATABASE=(wilkes ukhan);
FILE=Failure.txt;
varTONEED=( wilkesshared UkhanShared GlaceR14 conf script confUkhan Login Login1 )
varNUMBER=( 2 6 ) 
COPY=0;
HOST=WILKESMIRROR;  Date=`date +%Y-%m-%d_%H:%M:%S`;
varGETPATH=( "/var/shared/" "/var/version/" "/var/backup/"  )
varMIRROR=( "10.52.0.12" "/var/shared/" "/var/version/" "/var/backup/" )
CRMBKUPID=("df1a1a4c-21c8-4233-a80c-2fda9e8173a7" "9d1f95a1-1ba4-4b82-8e62-ed62c1aaea1e" "71285bcf-cd51-4f0a-825d-2a34038ec82a");
varDATABID=("6b3c2ffe-9641-4672-b028-5d3adce659c7" "65f5a859-5bde-4ca2-8b0f-7cffaa5ef262" );
DAILYLOGFILE="/var/version/script/logs/mirrordaily.log"; LOGFILE="/var/version/script/logs/mirrorbkp.log"
#-------------------------------------------------------------------------------------------------------------
cat /dev/null > ${DAILYLOGFILE}
echo "$HOST BKP STARTED AT $DATE" >> ${DAILYLOGFILE}
trace () 
        {
        stamp=`date +%Y-%m-%d_%H:%M:%S`
        echo  "$stamp: $* " >> ${DAILYLOGFILE}
	}
#--------------------------------------------------------------------------------------------------------------
MIRROR_TRN ()
{
echo "MIRROR VERSION AND SHARED FOLDER PROGRAME IS STARTED";
echo " ---------------------------------" >> ${DAILYLOGFILE}
trace " MIRROR VERSION AND SHARED FOLDER PROGRAME ";
echo " ---------------------------------" >> ${DAILYLOGFILE}
for ((i = 0 ; i < 2 ; i++)) do
for ((j = 0 ; j < "${varNUMBER[i]}" ; j++)) do
echo $COPY
echo "rsync --progress -arzv   ${varGETPATH[i]}${varTONEED[COPY]}  ${varMIRROR[0]}:${varGETPATH[i]}" ;
rsync --progress -arzv   ${varGETPATH[i]}${varTONEED[COPY]}  ${varMIRROR[0]}:${varGETPATH[i]};
if [ $? -eq 0 ]; then
BID=${CRMBKUPID[COPY]}; echo $BID
FN=${varTONEED[COPY]}; echo $FN;
FS=$(ssh ${varMIRROR} "du -bs  ${varGETPATH[i]}${varTONEED[COPY]}" |awk '{ print $1 }'); echo $FS;
FDS=$(ssh ${varMIRROR} "du -bs  ${varGETPATH[i]}" | awk '{ print $1 }' );echo $FSD;

echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "
curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
trace "${varTONEED[$COPY]} FOLDER IS COMPLETED";
COPY=$((COPY+1));
else
echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "

curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=0 -d ic=0 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
trace "-xxxxxxxxxxx- THE ${MIRROR[$i]} FOLDER ERROR PLS CHECK !! -xxxxxxxxxxx-";
SUB="${varTONEED[$i]} FOLDER ERROR"
COPY=$((COPY+1));
fi ; done; done;
echo -e "\n\n" >> ${DAILYLOGFILE}
echo "MIRROR  VERSION AND SHARED FOLDER PROGRAME IS FINISHED";
}
#----------------------------------------------------------------------------------------------------------------
DATAFOLDER ()
{
echo "MIRROR DATAFOLDER FILE PROGRAME IS STARTED";
echo " ---------------------------------" >> ${DAILYLOGFILE}
trace " MIRROR DATAFOLDER FILE PROGRAME ";
echo " ---------------------------------" >> ${DAILYLOGFILE}
#cd /var/version/masterslaveclenup/
#javac -cp .:postgresql-9.1-901.jdbc4.jar MasterSlaveDB.java
for ((i = 0 ; i < "${#varDATABASE[*]}" ; i++)) do
#java -cp .:postgresql-9.1-901.jdbc4.jar MasterSlaveDB 10.52.0.10 5432 ${varDATABASE[i]} 192.168.1.10 5432 ${varDATABASE[i]}
FS=$(sudo -u glace psql -c "SELECT pg_database_size('${varDATABASE[i]}');"  -d common | awk 'FNR == 3 {print $1} ');
FN=${varDATABASE[i]};
BID=${varDATABID[i]};
FDS=$(ssh ${varMIRROR} "du -bs  /var/database" | awk '{ print $1 }');
if [ -f $FILE ];
then
echo "File $FILE exists"
echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=0 -d ic=0 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "
curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=0 -d ic=0 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
mv Failure.txt Failure_${varDATABASE[0]}.txt
else
echo "File $FILE does not exists"
echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "
curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
fi;done;
cat "$DAILYLOGFILE" >> $LOGFILE
}


#----------------------------------------------------------------------------------------------------------------
CONFIG_FILES ()
{
echo "MIRROR CONFIG FILE PROGRAME IS STARTED";
echo " ---------------------------------" >> ${DAILYLOGFILE}
trace " MIRROR CONFIG FILE PROGRAME ";
echo " ---------------------------------" >> ${DAILYLOGFILE}
rsync --progress -arzv  /etc/sysconfig/iptables  ${varMIRROR[0]}:/etc/sysconfig/iptables
rsync --progress -arzv  /etc/crontab             ${varMIRROR[0]}:/etc/crontab
rsync --progress -arzv  /var/backup/script       ${varMIRROR[0]}:/var/backup/
rsync --progress -arzv --delete   /var/database/pgsql9.1/   192.168.1.10:/var/database/pgsql9.1_BACKUP/
rsync --progress -arzv  /var/backup/DBBACKUPS/*$DAY$BKP_EXTNS       ${varMIRROR[0]}:/var/backup/DBBACKUPS/
trace "MIRROR CONFIG FILE IS COMPLETED";
echo "MIRROR CONFIG FILE IS COMPLETED";
}
#-----------------------------------------------------------------------------------------------------------------
MIRROR_TRN
CONFIG_FILES
