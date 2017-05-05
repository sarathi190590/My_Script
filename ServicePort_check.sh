#!/bin/bash
#
# Server Service Status Check
# @uther : serveradmins@glenwoodsystems.com
#
HOST=$(hostname -s | tr 'a-z' 'A-Z');
TIME=$(date +%k);
rm -f /tmp/UnwantedPortno.txt
rm -f /tmp/UnwantedChkconfig.txt
PortList=(`cat /tmp/ServicePortNo_Web.txt`)
KillStauts=(`cat /tmp/ServerKill.txt`)
ChkconfigList=(`cat /tmp/Chkconfig_Web.txt`)
netstat -ntpl | grep -v ":::" |  grep -v "rpc.statd" | grep -i "/"  | awk '{print $4}' |  cut -d ':'  -f2 | grep -v  'Local'   > /tmp/CurrenPort.txt
CurrenList=(`cat /tmp/CurrenPort.txt`);
#For Chkconfig Var
systemctl list-unit-files   | grep  enable  |  awk '{print $1}' > /tmp/Chkconfig_InServer.txt
ChkListInServer=(`cat /tmp/Chkconfig_InServer.txt`)
#********************************************************************************************************************
VARGET ()
{
wget -k  https://sso.glaceemr.com/jsp/LocalServerPort.txt  --output-document=/tmp/ServicePortNo_Web.txt
PortList=(`cat /tmp/ServicePortNo_Web.txt`)
wget -k  https://sso.glaceemr.com/jsp/ServerKill.txt --output-document=/tmp/ServerKill.txt
KillStauts=(`cat /tmp/ServerKill.txt`)
wget -k  https://sso.glaceemr.com/jsp/LocalServerchkconfig7.txt  --output-document=/tmp/Chkconfig_Web.txt
ChkconfigList=(`cat /tmp/Chkconfig_Web.txt`)
}
#********************************************************************************************************************
SERVICE ()
{
case "$KillStauts" in
   NO )  for ((i = 0  ; i < "${#CurrenList[*]}" ; i++)) do
         flag=0;
          for ((j = 0  ; j < "${#PortList[*]}" ; j++)) do
             if [ ${CurrenList[$i]} -eq ${PortList[$j]} ] ; then
               flag=1;break;
             fi;done;
                     if [ $flag -eq 0 ] ; then
                      echo  "${CurrenList[$i]}" >> /tmp/UnwantedPortno.txt;
                      echo  "${CurrenList[$i]}"
                     fi
      done;
            if [ ! -f /tmp/UnwantedPortno.txt ]; then
           echo "File not found!"
         else
              sendEmail  -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com,techsupport@glenwoodsystems.com -cc sam@glenwoodsystems.com -u $HOST Port Report -m  Please check $HOST server Extra Port is running. -a /tmp/UnwantedPortno.txt
        fi
          ;;
esac
}
#********************************************************************************************************************
CHKCONFIG ()
{
for ((i = 0  ; i < "${#ChkListInServer[*]}" ; i++)) do
         flag=0;
          for ((j = 0  ; j < "${#ChkconfigList[*]}" ; j++)) do
             if [ ${ChkListInServer[$i]} == ${ChkconfigList[$j]} ] ; then
               flag=1;break;
             fi;done;
                     if [ $flag -eq 0 ] ; then
                      echo  "${ChkListInServer[$i]}" >> /tmp/UnwantedChkconfig.txt;
                      echo  "${ChkListInServer[$i]}"
                     fi
      done;
            if [ ! -f /tmp/UnwantedChkconfig.txt ]; then
           echo "File not found!"
            else
              sendEmail  -s waterbury.glaceemr.net:2500 -f donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com,techsupport@glenwoodsystems.com -cc sam@glenwoodsystems.com  -u $HOST chkconfig Report -m  Please check $HOST server Extra Service is running. -a /tmp/UnwantedChkconfig.txt
        fi

}

#********************************************************************************************************************
LOCALCHECKSEV ()
{
if [ $TIME -eq 6 ]
          then
for ((i = 0  ; i < "${#LocalService[*]}" ; i++)) do
         flag=0;
          for ((j = 0  ; j < "${#PortList[*]}" ; j++)) do
             if [ ${LocalService[$i]} == ${PortList[$j]} ] ; then
               flag=1;break;
             fi;done;
                     if [ $flag -eq 0 ] ; then
                      echo  "${LocalService[$i]}" >> /tmp/ServicePortNo_Web.txt
                     fi
      done;fi;

}
#********************************************************************************************************************
LOCALCHECKCHK ()
{
if [ $TIME -eq 6 ]
          then
for ((i = 0  ; i < "${#LocalChk[*]}" ; i++)) do
         flag=0;
          for ((j = 0  ; j < "${#ChkconfigList[*]}" ; j++)) do
             if [ ${LocalChk[$i]} == ${ChkconfigList[$j]} ] ; then
               flag=1;break;
             fi;done;
                     if [ $flag -eq 0 ] ; then
                      echo  "${LocalChk[$i]}" >> /tmp/Chkconfig_Web.txt
                      fi
      done;fi;

}
#********************************************************************************************************************
FUN_MAIN ()
{
       if [ ! -f /var/shellscript/localservice.txt ]; then
   echo "File not found in main function!"
       else
         LocalService=(`cat /var/shellscript/localservice.txt`);
         LOCALCHECKSEV
       fi
       if [ ! -f /var/shellscript/localservice.txt ]; then
       echo "File not found in main function!"
        else
         LocalChk=(`cat /var/shellscript/localchkconfig.txt`)
         LOCALCHECKCHK
        fi
    if [ $TIME -eq 6 ]
          then
                 VARGET
         SERVICE
                 CHKCONFIG
        else
                SERVICE
                 CHKCONFIG
        fi

}
#********************************************************************************************************************
FUN_MAIN
