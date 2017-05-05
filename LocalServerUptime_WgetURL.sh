SERVERS=(`cat /opt/sarathi/LocalUPTimeServer.txt` );
rm -f /tmp/LocalServerUPTime.txt 
DBFIX()
{
for ((i = 0  ; i < "${#SERVERS[*]}" ; i++)) do
echo "$i) ${SERVERS[$i]} ";
wget "${SERVERS[$i]}" -O /tmp/LocalUpTime.txt
sed -i '/^\s*$/d'     /tmp/LocalUpTime.txt
sed -i 's|<br />||g'  /tmp/LocalUpTime.txt
cat /tmp/LocalUpTime.txt 
cat /tmp/LocalUpTime.txt >> /tmp/LocalServerUPTime.txt
done
}
DBFIX
cat  /tmp/LocalServerUPTime.txt
/usr/java/jdk1.8.0_51/bin/java -jar /var/shellscript/RebootTimeSortLocalServer.jar  /tmp/LocalServerUPTime.txt
sendEmail -v -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com,sam@glenwoodsystems.com -u  Local Server Last Reboot Time  -m "`cat /tmp/JunkTables/Reboot-LocalServer.html`"

