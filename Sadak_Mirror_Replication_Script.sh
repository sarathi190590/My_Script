Slave="192.168.1.10";
MSpath=$(ps -ef | grep post | awk  '{print $12}' | grep data)/;
IP=$(ifconfig em1 |grep 'inet addr:'|cut -d : -f2 |awk '{print $1}');
SLpath="/var/database/pgsql9.1/data/";
Conffile="postgresql.conf";
LOGFILE="/var/version/script/mirrorlog.txt";
MY_ERR_FLAG=0;



MIRROR (){
ssh $Slave "service postgresql-9.1 stop"
sudo -u postgres psql -c "SELECT pg_start_backup('label', true)"
ssh $Slave "mv $SLpath/recovery.conf   /tmp"
sudo -u postgres rsync -a -v --delete -e ssh  $MSpath  $Slave:$SLpath --exclude postmaster.pid
sudo -u postgres psql -c "SELECT pg_stop_backup()"
ssh $Slave "sed -i '210s/#hot_standby = off/hot_standby = on/g' $SLpath/$Conffile"
ssh $Slave "echo 'host    all  all $IP  $IP  trust' >> $SLpath/pg_hba.conf"
ssh $Slave "mv /tmp/recovery.conf $SLpath"
ssh $Slave "service postgresql-9.1 start"
sleep 20
STREAMCHECK;
}

ERR_TEST () {
    if [ "$?" -ne 0 ]; then
                  MY_ERR_FLAG=1;
    HEAD="NO STREAMING GOING ON"
                else
                MY_ERR_FLAG=0;
  fi
}

STREAMCHECK (){
ps -ef | grep post | grep streaming
ERR_TEST;
}


echo "Streaming check started on ##################`date`#############################" > $LOGFILE;
STREAMCHECK  >> $LOGFILE;
if [ $MY_ERR_FLAG -eq 1 ]
then
MIRROR;
else
HEAD="Streaming is going on to $Slave";
fi
echo "$HEAD" >> $LOGFILE;
echo "Streaming check Stopped on ################`date`###############################" >> $LOGFILE;
mutt -s "Wilkes server Streaming Report- $HEAD"  sadakathulla@glenwoodsystems.com < $LOGFILE;

