DAY=`date +%A`;
BKP_EXTNS=".7z"
NUMBERVALUE=(2 2 1);
COPY=0;
BKP_COPY=( "wilkes_$DAY$BKP_EXTNS" "ukhan_$DAY$BKP_EXTNS" "wilkesshared" "UkhanShared" "GlaceR14" )
BKP_DEST=( "/var/backup/DBBACKUPS/" "/var/shared/" "/var/version/" );
NAS_DETA=( "glace@kaulhome.dyndns.org::Backup/"  "/var/version/script/pwd.txt" )
CRMBKUPIDR=( "7450fdc2-f700-490f-b6dd-0f9e2902620f" "18b2248e-2da9-4304-a51f-90114bdf9096" "5effe4a4-1da9-4f09-a5fb-3ceb8a4be077" "18c745cb-2b70-4915-9a2e-73328c5f23b9" "66c6c811-f0e3-4e82-b6e4-2ff33dba777d" );
LOGFILE="/var/version/script/logs/NASLOGFILE.log";
cat /dev/null > ${LOGFILE}
#--------------------------------------------------------------------------------------------------------
trace () 
        {
        stamp=`date +%Y-%m-%d_%H:%M:%S`
        echo  "$stamp: $* " >> ${LOGFILE}
	}
#--------------------------------------------------------------------------------------------------------
NAS_TRN ()
{
echo "NAS VERSION AND SHARED FOLDER PROGRAME IS STARTED";
echo " ---------------------------------" >> ${LOGFILE}
trace " NAS VERSION AND SHARED FOLDER PROGRAME ";
echo " ---------------------------------" >> ${LOGFILE}
for ((i = 0 ; i < 3 ; i++)) do
for ((j = 0 ; j < "${NUMBERVALUE[i]}" ; j++)) do
echo $COPY
echo "rsync --progress --password-file=${NAS_DETA[1]} -arzv   ${BKP_DEST[i]}${BKP_COPY[COPY]}  ${NAS_DETA[0]}" ;
rsync --progress  --password-file=/var/version/script/pwd.txt -arzv   ${BKP_DEST[i]}${BKP_COPY[COPY]}        ${NAS_DETA[0]}  ;
if [ $? -eq 0 ]; then
BID=${CRMBKUPIDR[COPY]}; echo $BID
FN=${BKP_COPY[COPY]}; echo $FN;
FS=$(du -bs  ${BKP_DEST[i]}${BKP_COPY[COPY]} | awk '{ print $1}'); echo $FS;
FDS=$(du -bs  ${BKP_DEST[i]} | awk '{ print $1}'); echo $FDS

echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "
curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
trace "${BKP_COPY[$COPY]} FOLDER IS COMPLETED";
COPY=$((COPY+1));
else
echo "curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=1 -d ic=1 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus "
curl -d aid=57 -d bid=$BID -d fn=$FN -d fs=$FS -d fds=$FDS -d status=0 -d ic=0 https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus
trace "-xxxxxxxxxxx- THE ${BKP_COPY[$i]} FOLDER ERROR PLS CHECK !! -xxxxxxxxxxx-";
SUB="${BKP_COPY[$i]} FOLDER ERROR"
COPY=$((COPY+1));
fi ; done; done;
echo -e "\n\n" >> ${LOGFILE}
echo "NAS  VERSION AND SHARED FOLDER PROGRAME IS FINISHED";
}
#--------------------------------------------------------------------------------------------------------------
NAS_TRN;

