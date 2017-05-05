#!/bin/bash
ICOUNT=6;DAY=`/bin/date +%A`;DATE=$(/bin/date +%Y-%m-%d);
OLDDAY=$(/bin/date +%a -d '1 day ago');YEAR=$(/bin/date +%Y-%m-%d -d '1 day ago');OLDDATE=$(/bin/date +%F -d '1 day ago')
PATH=(Instance1 Instance2 Instance3 Instance4 Instance5 Instance6);
LOG()
{
echo "########################-Script Starts AT $DAY $DATE -###########################";
for ((i = 0 ; i < $ICOUNT ; i++)) do
echo "Count $i";
/bin/chmod -Rf 777 /usr/share/tomcatInstances/instancesHome/${PATH[$i]}/logs
/bin/chown -Rf tomcat.tomcat /usr/share/tomcatInstances/instancesHome/${PATH[$i]}/logs
cd /usr/share/tomcatInstances/instancesHome/${PATH[$i]}/logs
/bin/cp -af catalina.out catalina-$OLDDAY.out
/bin/cat /dev/null > catalina.out 
/bin/chown tomcat.tomcat catalina-$OLDDAY.out
/bin/cp -af localhost.$OLDDATE.log     localhost.$OLDDAY.log
/bin/cp -af localhost_access_log.$OLDDATE.txt   localhost_access_log.$OLDDAY.txt
/bin/cp -af catalina.$OLDDATE.log     catalinaservice.$OLDDAY.log
/bin/rm -f  localhost.$OLDDATE.log  localhost_access_log.$OLDDATE.txt  catalina.$OLDDATE.log

done

echo "########################-Script Starts AT $DAY $DATE -###########################";
}

LOG1()
{
echo "########################-Tomcat Script Starts AT $DAY $DATE -###########################";

FILE=(tomcat8_Instance1 tomcat8_Instance2 tomcat8_Instance3 tomcat8_Instance4 tomcat8_Instance5 tomcat8_Instance6)
COPY=1;

for ((i = 0 ; i < $ICOUNT ; i++)) do
echo "Count $i";
echo "COPY = $COPY"
cd /var/backup/tomcat/${PATH[$i]}
pid=(`/usr/bin/ps -ef | /usr/bin/grep java | /usr/bin/grep -i server.port=${COPY} | /usr/bin/awk '{print $2}'`);
echo "process id $pid"; kill -9 $pid

/sbin/service ${FILE[$i]} restart

/bin/cp -af tomcat_access_log.$YEAR.txt  tomcat_access-$OLDDAY.txt
/bin/rm -f tomcat_access_log.$YEAR.txt tomcat_access.txt
/bin/ln -s tomcat_access_log.`/bin/date +%Y-%m-%d`.txt  tomcat_access.txt
if [ $? -eq 0 ]; then
COPY=$((COPY+1));
fi

done
echo "########################-Tomcat Script End AT $DAY $DATE -###########################";
}

LOG
LOG1

