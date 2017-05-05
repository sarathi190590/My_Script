DATABASES=( wilkes ukhan );DBCOUNT=2;
varTARNAME=( GlaceR14 wilkesshared UkhanShared );
varTOCOPY=( wilkes ukhan  GlaceR14 wilkesshared UkhanShared);
varTARSOURCE=( "/var/version/GlaceR14"   "/var/shared/wilkesshared" "/var/shared/UkhanShared")
#varBKPTYPE=("local" "shared" "week" "month"  "external" "readynas" "rsync.net" );
varBKPTYPE=("local" "" "" "" "" "");
varLOCALPATH=("/var/backup/DBBACKUPS/" ""  "" "" "" );
varNETPATH=("/var/backup/NWBKP/" "/var/backup/NWBKP/week/" "/var/backup/NWBKP/month/" "")
varSERVER=("//192.168.1.13/Public" "glace@xns.org::backup/" "4319@usw-s004.rsync.net:/data2/home/4319/" "");
varUSERNAME=("username=glace" "readyNASUSERNAME" "rsyncusername" "" "");
varPWD=("password=redbury" "REadyNASPWD" "rsync.netpwd" "");
BKPTYPE_COUNT=${#varBKPTYPE[*]};  DB_INDX=0;  DAY=`date +%A`; BKP_EXTNS=".7z"; DATE=`date +%Y-%m-%d`;
SUB="BACKUP BKP REPORT"; HOST=$(hostname -s | tr 'a-z' 'A-Z'); DAILYLOGFILE="/var/backup/script/bkpdaily.log"
LOGFILE="/var/backup/script/wholelog.log"
CRMBKUPIDC=("4e42e0ab-c8e4-4d23-9002-e53f8c4d64d6" "c4a826ea-6918-40e3-81b9-a6a2a8cc976b" "01872c29-fa43-4f1b-b5ec-a4d4ece413c7"  "cb058757-6bb3-44d2-a913-e2fea9c412bd" "95a94af2-83d9-4909-8105-f28ecffe457e" );
CRMBKUPIDM=("4bad7833-3241-4922-a3f0-75feb1e6869e" "2c6a5cce-7bdb-411a-8af1-5562f8e8825a" "5549a9e9-2453-4999-8559-29cf3736fb6f"  "4ff9c75a-bc6d-4941-a2fa-49b5ff88f206" "2914ea8c-4d74-42cb-bf17-922227ba8656" );
CRMBKUPIDT=("352adee7-52e1-402b-8077-a75cce5f5e65" "a538cafc-aa3a-4c5d-936c-f298329a9473" "6489796f-6fb0-4ca2-8aca-df22ef53e694"  "06484b4e-0922-4027-aab7-121a325ac884" "286f18fd-a546-40e2-a510-698dc96f598f" );
PORT=5432;CONN=1;j=1;
BID="";FN="";FS="";FDS="";IC="";
ZIPCMD="7za a -pJam3sG0s1ing -mhe=on -r -m0=lzma -mx=9 -mfb=64 -md=32m";
SHRDIRTONW=1; #0-Directly to NW ,1-Local and copy to NW
MON=`date +%b`;MONTH=`date +%m`;YEAR=`date +%Y`;YESDAY=$(date --date 'yesterday' +%A);
MONTHCHK=$(cal  $MONTH $YEAR | awk 'NF==7 && !/^Su/{print $1;exit}');
#-------------------------------------------------------------------------------
cat /dev/null > ${DAILYLOGFILE}
echo "$HOST BKP STARTED AT $DATE" >> ${DAILYLOGFILE}
trace () 
        {
        stamp=`date +%Y-%m-%d_%H:%M:%S`
        echo  "$stamp: $* " >> ${DAILYLOGFILE}
	}
#-------------------------------------------------------------------------------
ERR_TEST () {

if [ "$?" -ne 0 ]; then
trace " The ERR IS FOUND @ $* " ;  else trace "$* BKP PROCESS IS COMPLETED ";  fi
 }
#-------------------------------------------------------------------------------
WGETCALL ()
{
echo $BID
WGETCRM="https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus&aid=57&bid=$BID&fn=$FN&fs=$FS&fds=$FDS&status=1&ic=$CONN";
echo $WGETCRM
wget --spider  -k  $WGETCRM
}
#-------------------------------------------------------------------------------
WGETCALLE ()
{
WGETCRM="https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=SaveStatus&aid=57&bid=$BID&fn=$FN&fs=$FS&fds=$FDS&status=0&ic=0";
echo $WGETCRM
wget --spider  -k  $WGETCRM
}
#-------------------------------------------------------------------------------
DB_BKP ()
{
echo "DATABASE DUMP PROGRAME IS STARTED";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        DATABASE DUMP PROGRAME ";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
MOUNT
IC=$CONN; echo $CONN
for ((i = 0 ; i < "${#DATABASES[*]}" ; i++)) do
cd $1
echo "cd $1"
BID=${CRMBKUPIDC[$i]};echo $BID
FN="${DATABASES[$i]}_$DAY$BKP_EXTNS";
FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $4 }');
echo "rm -f $1${DATABASES[$i]}_$DAY$BKP_EXTNS"
rm -f $1${DATABASES[$i]}_$DAY$BKP_EXTNS
echo "sudo -u glace pg_dump -p $PORT -v -Fc  ${DATABASES[$i]} | $ZIPCMD -si ${DATABASES[$i]}_$DAY$BKP_EXTNS"
sudo -u glace pg_dump -p $PORT -v -Fc  ${DATABASES[$i]} | $ZIPCMD -si ${DATABASES[$i]}_$DAY$BKP_EXTNS
if [ $? -eq 0 ];  then
FS=$(ls -ll $FN | awk '{ print $5}');
WGETCALL 
trace "${DATABASES[$i]} IS COMPLETED";
else 
FS=$(ls -ll $FN | awk '{ print $5}');
WGETCALLE
trace "-xxxxxxxxxxx- THE ${DATABASES[$i]} DUMP ERROR PLS CHECK !! -xxxxxxxxxxx-";
fi ; done;  
rsync --progress -arzv  /var/backup/DBBACKUPS/*$DAY$BKP_EXTNS       192.168.1.10:/var/backup/DBBACKUPS/
echo -e "\n\n" >> ${DAILYLOGFILE}
echo "DATABASE DUMP PROGRAME IS FINISHED";
}

#-------------------------------------------------------------------------------
TESTING()
{
echo "TESTING 7ZA-Backup BKP IS STARTED";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        TESTING BACKUP ";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
for ((i = 0 ; i < "${#varTOCOPY[*]}" ; i++)) do
  BID=${CRMBKUPIDT[$i]};
  FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $4 }');
    if [ $i -lt $DBCOUNT ]; then
      FN="$1${varTOCOPY[i]}_$YESDAY$BKP_EXTNS";
      echo "$FN"
      echo "DATABASE";
      echo "7za t -pJam3sG0s1ing $1${varTOCOPY[$i]}_$YESDAY$BKP_EXTNS "
      7za t -pJam3sG0s1ing $1${varTOCOPY[$i]}_$YESDAY$BKP_EXTNS     
      if [ $? -eq 0 ]; then 
      FS=$(ls -ll $FN | awk '{ print $5}');
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALL 
      trace "${varTOCOPY[$i]} IS COMPLETED";
      else  
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALLE
      trace "-xxxxxxxxxxx- TESTING BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
      fi;
    else 
      FN="$1${varTOCOPY[i]}$BKP_EXTNS";
      echo "$FN"
      echo "7za t -pJam3sG0s1ing $1${varTOCOPY[$i]}$BKP_EXTNS "
       7za t   -pJam3sG0s1ing $1${varTOCOPY[$i]}$BKP_EXTNS     
      if [ $? -eq 0 ]; then 
      FS=$(ls -ll $FN | awk '{ print $5}');
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALL 
      trace "${varTOCOPY[$i]} IS COMPLETED";
      else  
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALLE
      trace "-xxxxxxxxxxx- TESTING BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
      fi;
   fi;done;
   echo -e "\n\n" >> ${DAILYLOGFILE}
   echo "TESTING 7ZA-Backup BKP IS FINISHED";
}
#-------------------------------------------------------------------------------
MONTH()
{
echo "MONTHLY 7ZA-Backup BKP IS STARTED";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        MONTHLY BACKUP ";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
rm -rf $2$MON
mkdir $2$MON
for ((i = 0 ; i < "${#varTOCOPY[*]}" ; i++)) do
  BID=${CRMBKUPIDM[$i]};
  FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $4 }');
    if [ $i -lt $DBCOUNT ]; then
      FN="${varTOCOPY[i]}_$DAY$BKP_EXTNS";
      echo "$FN"
      echo "DATABASE";
      echo "rsync --progress -rzv    $1${varTOCOPY[$i]}_$DAY$BKP_EXTNS     $2$MON"
      rsync --progress -rzv    $1${varTOCOPY[$i]}_$DAY$BKP_EXTNS     $2$MON
      if [ $? -eq 0 ]; then 
      FS=$(ls -ll $FN | awk '{ print $5}');
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALL 
      trace "${varTOCOPY[$i]} IS COMPLETED";
      else  
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALLE
      trace "-xxxxxxxxxxx- MONTHLY BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
      fi;
    else 
      FN="${varTOCOPY[i]}$BKP_EXTNS";
      echo "$FN"
      echo "rsync --progress -rzv    $1${varTOCOPY[$i]}$BKP_EXTNS     $2$MON"
      rsync --progress -rzv    $1${varTOCOPY[$i]}$BKP_EXTNS     $2$MON
      if [ $? -eq 0 ]; then 
      FS=$(ls -ll $FN | awk '{ print $5}');
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALL 
      trace "${varTOCOPY[$i]} IS COMPLETED";
      else  
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALLE
      trace "-xxxxxxxxxxx- MONTHLY BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
      fi;
   fi;done;
   echo -e "\n\n" >> ${DAILYLOGFILE}
   echo "MONTHLY 7ZA-Backup BKP IS FINISHED";
}

#-------------------------------------------------------------------------------
WEEK()
{
echo "WEEKLY 7ZA-Backup BKP IS STARTED";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        WEEKLY BACKUP ";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
rm -rf $2$DAY
mkdir $2$DAY
for ((i = 0 ; i < "${#varTOCOPY[*]}" ; i++)) do
   if [ $i -lt  $DBCOUNT ]; then
    echo "rsync --progress -rzv    $1${varTOCOPY[$i]}_$DAY$BKP_EXTNS     $2$DAY"
    rsync --progress -rzv    $1${varTOCOPY[$i]}_$DAY$BKP_EXTNS     $2$DAY
    ERR_TEST "${varTOCOPY[$i]}  DB IS COMPLETED" ;
    else 
    echo "rsync --progress -rzv    $1${varTOCOPY[$i]}$BKP_EXTNS     $2$DAY"
    rsync --progress -rzv    $1${varTOCOPY[$i]}$BKP_EXTNS     $2$DAY
    ERR_TEST "${varTOCOPY[$i]}  FOLDER IS COMPLETED" ;
    fi;done;
  echo -e "\n\n" >> ${DAILYLOGFILE}
  echo "WEEKLY 7ZA-Backup BKP IS FINISHED";
}

#-------------------------------------------------------------------------------
SHARED()
{
echo  "SHARED AND CODEBASE BKP IS STARTED"; 
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        SHARED AND CODEBASE PROGRAME "; 
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
if [ $SHRDIRTONW -eq 1 ];then
MOUNT
IC=$CONN; echo $CONN
for ((i = 0 ; i < "${#varTARNAME[*]}" ; i++)) do
j=$((j+1));
FILE=${varTARNAME[$i]}$BKP_EXTNS
BID=${CRMBKUPIDC[$j]};echo "---------------------------$BID-----------------";
FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $4 }');
cd $1
if [ -f $FILE ]; then
         if [ $DAY == 'Sunday' ]; then
		rm -f $1${varTARNAME[$i]}$BKP_EXTNS
		trace "TODAY IS SUNDAY FILE ${varTARNAME[$i]}$BKP_EXTNS DELETED";
		echo " sunday $ZIPCMD '-x!temp'  ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]}; "
		$ZIPCMD '-x!temp'  ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
		   if [ $? -eq 0 ]; then 
                   FN="${varTARNAME[i]}$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALL 
                   trace "${varTARNAME[$i]} IS COMPLETED";
                   else  
                   FN="${varTARNAME[i]}_$DAY$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALLE
                   trace "-xxxxxxxxxxx-  ${varTARNAME[$i]} BKP ERROR -xxxxxxxxxxx-";
                fi;
         else
             echo " update 7za u -pJam3sG0s1ing -mhe=on -r -m0=lzma -mx=9 -mfb=64 -md=32m '-x!temp' ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]}; "
             7za u -pJam3sG0s1ing -mhe=on -r -m0=lzma -mx=9 -mfb=64 -md=32m '-x!temp' ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
             if [ $? -eq 0 ]; then 
                   FN="${varTARNAME[i]}$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALL 
                   trace "${varTARNAME[$i]} IS COMPLETED";
                   else  
                   FN="${varTARNAME[i]}$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALLE
                   trace "-xxxxxxxxxxx-  ${varTARNAME[$i]} BKP UPDATE ERROR -xxxxxxxxxxx-";
	fi;    fi;	  
	else
        echo "add new $ZIPCMD  '-x!temp' ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};"
        $ZIPCMD '-x!temp'  ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
	if [ $? -eq 0 ]; then 
                   FN="${varTARNAME[i]}$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALL 
                   trace "${varTARNAME[$i]} IS COMPLETED";
                   else  
                   FN="${varTARNAME[i]}$BKP_EXTNS";
                   echo "$FN"
                   FS=$(ls -ll $FN | awk '{ print $5}');
                   WGETCALLE
                   trace "-xxxxxxxxxxx-  ${varTARNAME[$i]} BKP ADD NEW FILE ERROR -xxxxxxxxxxx-";
	fi;	
        fi;done;
echo -e "\n\n" >> ${DAILYLOGFILE}
echo  "SHARED AND CODEBASE BKP IS FINISHED"; 
else
MOUNT
IC=$CONN; echo $CONN
if [ $CONN -eq 1 ];  then
for ((i = 0 ; i < "${#varTARNAME[*]}" ; i++)) do
j=$((j+1));
cd $2
BID=${CRMBKUPIDC[$j]};
FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $4 }');
FN="${varTARNAME[0]}$BKP_EXTNS";
echo "$FN"
if [ -f $FILE ]; then
   if [ $DAY == 'Sunday' ]; then
    rm -f $1${varTARNAME[$i]}$BKP_EXTNS
    trace "TODAY IS SUNDAY FILE ${varTARNAME[$i]}$BKP_EXTNS DELETED";
    $ZIPCMD '-x!temp' ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
      if [ $? -eq 0 ]; then 
      FS=$(ls -ll $FN | awk '{ print $5}');
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
      WGETCALL
      trace "${varTOCOPY[$i]} IS COMPLETED";
      else  
      FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
     WGETCALLE
      trace "-xxxxxxxxxxx- WEEKLY BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
      fi;
      else
      7za u -pJam3sG0s1ing -mhe=on -r -m0=lzma -mx=9 -mfb=64 -md=32m '-x!temp'  ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
        if [ $? -eq 0 ]; then 
        FS=$(ls -ll $FN | awk '{ print $5}');
	FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
	WGETCALL
	trace "${varTOCOPY[$i]} IS COMPLETED";
	else  
	FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
	WGETCALLE
	trace "-xxxxxxxxxxx- WEEKLY BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
	fi;fi;
	else
        $ZIPCMD '-x!temp'  ${varTARNAME[$i]}$BKP_EXTNS  ${varTARSOURCE[$i]};
        if [ $? -eq 0 ]; then 
        FS=$(ls -ll $FN | awk '{ print $5}');
        FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
	WGETCALL
	trace "${varTOCOPY[$i]} IS COMPLETED";
	else  
	FDS=$(df -m /var/backup/NWBKP/ | awk '$3 ~ /[0-9]+/ { print $3 }');
	WGETCALLE
	trace "-xxxxxxxxxxx- WEEKLY BKP ${varTOCOPY[$i]} ERROR -xxxxxxxxxxx-";
	fi;fi;done;fi;
echo -e "\n\n" >> ${DAILYLOGFILE}
echo  "SHARED AND CODEBASE BKP IS FINISHED"; 
fi;
}
#--------------------------------------------------------------------------------
COFIGFILES()
{
echo  "COFIGFILES  BKP IS STARTED"; 
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "        COFIGFILES  PROGRAME IS STARTED "; 
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
rm -rf /var/backup/configfiles/
rm -f  $1$DAY/configfiles_$DAY$BKP_EXTNS
mkdir -p  /var/backup/configfile
mkdir -p /var/backup/configfiles/conf/
mkdir -p /var/backup/configfiles/confUkhan/
mkdir -p /var/backup/configfiles/scriptversion/
mkdir -p /var/backup/configfiles/scriptversion/
cp     /etc/sysconfig/iptables   /var/backup/configfiles/
cp     /etc/crontab              /var/backup/configfiles/
cp -r  /var/version/conf         /var/backup/configfiles/conf/
cp -r  /var/version/confUkhan    /var/backup/configfiles/conf/
cp -r  /var/version/script       /var/backup/configfiles/scriptversion/
cp -r  /var/backup/script        /var/backup/configfiles/scriptbackup/
cd $1$DAY
$ZIPCMD  configfiles_$DAY$BKP_EXTNS /var/backup/configfiles/;

}
#--------------------------------------------------------------------------------
RSYNCDOT()
{
echo  "RsyncDOTnet BKP IS STARTED";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
trace "       RsyncDOTnet PROGRAME ";
echo "                     ---------------------------------" >> ${DAILYLOGFILE}
rsync -arz --progress  /var/shared/chughtaishared -e ssh   10211@ch-s010.rsync.net:/data1/home/10211/Shared/
rsync -arz --progress /var/version/GlaceR12/                      10211@ch-s010.rsync.net:/data1/home/10211/CodeBase/
rsync -arz --progress /var/backup/DBBACKUPS/*_$DAY$BKP_EXTNS  10211@ch-s010.rsync.net:/data1/home/10211/DB/
echo -e "\n\n" >> ${DAILYLOGFILE}
echo  "RsyncDOTnet BKP IS FINISHED";
}
#-------------------------------------------------------------------------------
MOUNT()
{
                        umount ${varNETPATH[0]} 
                        if mount -t cifs ${varSERVER[0]} ${varNETPATH[0]} -o ${varUSERNAME[0]},${varPWD[0]} ; then
			CONN=1;
		        trace "  MOUNT Successfully"
				else 
				CONN=0;
				trace "-xxxxxxxx NETWORK DEVICE IS NOT MOUNTED SO BACKUP DOESN'T RUN PLS CHECK ONCE xxxxxxxxxx-";
                                SUB="NETWORK BKP ERROR"
			fi
}
#-------------------------------------------------------------------------------
SERVER_RESTART()
{
HOST=`hostname -s | sed -r 's/\<./\U&/g'`;
currTime=`date +%H%M`
if [ $currTime -gt 0600 -a $currTime -lt 2300 ]; then
        echo "Time is between 6 AM and 10 PM. Aborting."
        sendEmail -s waterbury.glaceemr.net:2500 -v -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com -u "$HOST server tried to reboot  between 6 AM and 10 PM" -m Please check the Server.
        return
fi;
        echo "Time is after 10 PM and before 6 AM. Server is going to reboot"
reboot
}
#-------------------------------------------------------------------------------
FUN_MAIN(){
echo "-----------------------------------------------------------------------------------------------------------------" >> ${DAILYLOGFILE}
trace "7ZA-Backup BACKUP PROGRAM STARTED !! " ;
echo "-----------------------------------------------------------------------------------------------------------------" >> ${DAILYLOGFILE}

while [ $DB_INDX -ne $BKPTYPE_COUNT ]; do
case "${varBKPTYPE[$DB_INDX]}" in
         local) DB_BKP ${varLOCALPATH[0]} 
		        ;;
		shared)SHARED ${varLOCALPATH[0]} ${varNETPATH[0]} 
                        ;;		
		week) umount ${varNETPATH[0]} 
                        if mount -t cifs ${varSERVER[0]} ${varNETPATH[0]} -o ${varUSERNAME[0]},${varPWD[0]} ; then
		        if [ $(date +%d) -eq $MONTHCHK ]; then
				MONTH ${varLOCALPATH[0]} ${varNETPATH[2]} 
				WEEK   ${varLOCALPATH[0]} ${varNETPATH[1]}
                                COFIGFILES ${varNETPATH[1]}
				else
				WEEK   ${varLOCALPATH[0]} ${varNETPATH[1]}
                                COFIGFILES ${varNETPATH[1]}
				fi
				else 
				trace "-xxxxxxxx NETWORK DEVICE IS NOT MOUNTED SO 7ZA-Backup WONT RUN PLS CHECK ONCE xxxxxxxxxx-";
				fi
		         ;;
	   	  testing)if [ $DAY == 'Sunday' ]; then
                              TESTING  ${varLOCALPATH[0]}
                       fi
                   ;;
	   	  external)   EX_BKP 
                  ;;
	          mirror)   MIRROR 
                  ;;
		  readyNAS) NASBKP 
                  ;;
                  rsyncNET) RSYNCDOT                  
                  ;;
		   esac
let DB_INDX++;
done
echo "" >> ${DAILYLOGFILE}
  df -h >> ${DAILYLOGFILE}
echo "" >> ${DAILYLOGFILE}
echo "-----------------------------------------------------------------------------------------------------------------" >> ${DAILYLOGFILE}
trace "7ZA-Backup BKP PROGRAME COMPLETED    ";
echo "-----------------------------------------------------------------------------------------------------------------" >> ${DAILYLOGFILE}
}
FUN_MAIN;
cat "$DAILYLOGFILE" >> $LOGFILE
#SERVER_RESTART;
