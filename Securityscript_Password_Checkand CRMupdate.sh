echo "<-----Server Script Started On `date +%Y-%m-%d_%H:%M:%S`------->"
#!/bin/bash
#Checking users list in server
A=28;
FILES=("/bin/rm" "/bin/ls" "/bin/ps" "/bin/netstat");
SIZES=("62816" "117616" "100048" "154968");
COUNT=${#FILES[*]};INDEX=0;
HOST=$(hostname -s | tr 'a-z' 'A-Z');
VAL=( "FSR" "FSD" "FSS" "BKP" "USR" "HOME" "FST" );
VALD=( "/" "/var/database/" "/var/shared" "/var/backup" "/usr" "/home" "/tmp" );
FSR=$(df -B1  /              | awk '$3 ~ /[0-9]+/ { print $4 }');
FSD=$(df -B1  /var/database  | awk '$3 ~ /[0-9]+/ { print $4 }' );
FSS=$(df -B1  /var/shared    | awk '$3 ~ /[0-9]+/ { print $4 }' );
BKP=$(df -B1  /var/backup    | awk '$3 ~ /[0-9]+/ { print $4 }' );
USR=$(df -B1  /usr           | awk '$3 ~ /[0-9]+/ { print $4 }' );
HOME=$(df -B1 /home          | awk '$3 ~ /[0-9]+/ { print $4 }' );
FST=$(df -B1  /tmp           | awk '$3 ~ /[0-9]+/ { print $4 }' );
FM=$(cat /proc/meminfo  | grep MemFree | awk '/[0-9]+/ { print $2 }' );
FS=$(cat /proc/meminfo  | grep MemFree | awk '/[0-9]+/ { print $2 }' );
CTS=$(netstat -np | grep 8443 | wc -l );
CDC=$(ps -ef  | grep post | grep "127.0.0.1" | wc -l );
CPC=$(ps -elFL | wc -l );
UC=$(cat /etc/passwd | wc -l);
OS=$(cat  /etc/redhat-release ); 
ACR=$(uname -r );
UT=$(uptime  | awk -F, '{ print $1 $2 }' );
SID=("56d2d9c9-2e95-42e6-9953-ff41bc5de64f")



CHK_UNWANTEDUSER () {

if [ $A -ne $UC ]; then
echo -e  "\nThe Unwanted user added in your server" "\n check /etc/passwd "
sleep 1 
sendEmail -v -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com sam@glenwoodsystems.com -u "Security Exception: $HOST Server additional users" -m "Please check /etc/passwd in this server; Oldcountuser=$A Newcountuser=$UC"
fi

}

CHK_FILESIZE () {

echo "$COUNT"
while [ $INDEX -ne $COUNT ]; do
echo "${FILES[$INDEX]}"
echo "${SIZES[$INDEX]}"
let k="$(stat -c %s ${FILES[$INDEX]})";
let d="${SIZES[$INDEX]}";
echo "$k";
echo "$d";
if [  "$k" -ne "$d"  ]
then 
echo -e "\nCheck the filesize in your server" "\ncheck size of ${FILES[$INDEX]}"
sleep 1
sendEmail -v -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com sam@glenwoodsystems.com -u "Security Exception: $HOST Server file size mismatch" -m "Please check size of ${FILES[$INDEX]}"
fi
let INDEX++;
done

}

CRM_STATUS () {

echo "curl -d sid=$SID -d fsr=$FSR  -d fsd=$FSD -d fss=$FSS -d  bkp=$UCKP -d usr=$USR -d home=$HOME -d fst=$FST -d fm=$FM -d fs=$FS -d cts=$CTS -d cdc=$CDC -d cpc=$CPC -d uc=$UC -d os="$OS $ACR" -d ut="$UT"  https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=UpdateStatusDetails "
curl -d sid=$SID -d fsr=$FSR  -d fsd=$FSD -d fss=$FSS -d  bkp=$UCKP -d usr=$USR -d home=$HOME -d fst=$FST -d fm=$FM -d fs=$FS -d cts=$CTS -d cdc=$CDC -d cpc=$CPC -d uc=$UC -d os="$OS $ACR" -d ut="$UT"  https://crm.glaceemr.com/Adaptor/CRMServerStatusUpdate.ashx?Action=UpdateStatusDetails

for ((i = 0 ; i < "${#VAL[*]}" ; i++)) do
   VALC=${VAL[$i]}; 
   let VALIF=${VALC};
   if [ "$VALIF" -eq 0 ];  then
   VALDM=${VALD[$i]};
 sendEmail -v -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com sam@glenwoodsystems.com -u Please check $HOST server -m $VALDM IS 100%.Please Check.   
  else
  VALDM=${VALD[$i]};
   echo " NO PROBLEM IN $VALDM ";
    fi; done;

echo "<------LINK POSTED TO CRM SERVER------->"

}

CRM_STATUS;
CHK_UNWANTEDUSER;
CHK_FILESIZE;

echo "<-----Script End `date +%Y-%m-%d_%H:%M:%S` ------->"
