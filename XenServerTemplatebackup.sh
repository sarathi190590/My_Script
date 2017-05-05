 #!/bin/bash 
# Put this script on Xenserver master and execute with root privilege
# Change VM UUID(s) and the location to export
# VMs: a list of VM uuid, separated by comma
# ExportPath: the mount path to store exported xva file
# step1: iterate specified VM UUID(s) and create a snapshot for each
# step2: backup the snapshots to specified location
# step3: delete temporary snapshot created in step 1
# [Note]
# please make sure you have enough disk space for ExportPath, or backup will fail
# on error, script will print the reason, and proceed to handle next VM 
# backed up file format: vm_label + "backup" + day of snapshot, i.e, win71_backup_2013-12-31_17-11-47.xva
#Author: parthasarathi[at]glenwoodsystems.com
#-----------------------------------------------------------------------------------------------------------------------------
VMs="b75a81a6-6cd1-3c47-f9a3-a399a74d2e5d,8ab4df2f-41d4-4acb-f942-403debfe98ff,8ab4df2f-41d4-4acb-f942-403debfe98ff,8ab4df2f-41d4-4acb-f942-403debfe98ff,df27c5ff-fb2f-3bce-78d1-d9aa0e955a2b"
ExportPath="/var/backup/NWBKP"
day=$(date +%A)
vm_array=(${VMs//,/ })
ret_code=0
snapshot_uuid_array=
snapshot_name_array=
backup_ext=".xva"
#-----------------------------------------------------------------------------------------------------------------------------
BACKUP()
{
echo "Starting to backup at `date` ..."
echo "VM list: ${vm_array[@]}"
echo "ExportPath: ${ExportPath}"
 
if [[ "$ExportPath" != */ ]]; then
    ExportPath="$ExportPath/"
fi
 
for i in "${!vm_array[@]}"; do
    uuid=${vm_array[$i]}
    vm_label_raw=`xe vm-param-get param-name=name-label uuid=$uuid` # Taking Label of VM.
    if [ $? -ne 0 ]; then
        echo "failed to get VM label uuid = $uuid"
        ret_code=1
        continue
    fi
    vm_label=`echo "$vm_label_raw" | tr ' ' _ | tr -d '(' | tr -d ')'` 
    snapshot_name=$vm_label"_backup_"$day
 
    # Snapshot vm
    snapshot_uuid=`xe vm-snapshot uuid=$uuid new-name-label=$snapshot_name` # Executing the comand to take Snapshot.
    if [ $? -ne 0 ]; then
        echo "failed to snapshot VM uuid = $uuid"
        ret_code=1
        continue
    fi
    snapshot_uuid_array[$i]=$snapshot_uuid
    snapshot_name_array[$i]=$snapshot_name
    vm_labels[$i]=$vm_label
    
    echo=`xe template-param-set is-a-template=false uuid=$snapshot_uuid`  # Remove is-a-template attribute from snapshot.
    if [ $? -ne 0 ]; then
        echo "failed to remove template attribute from VM uuid = $uuid"
        ret_code=1
    fi
done
# Backup each VM to specified path and delete
#--------------------------------------------
for i in "${!snapshot_uuid_array[@]}"; do
    snapshot_uuid=${snapshot_uuid_array[$i]}
    snapshot_name=${snapshot_name_array[$i]}
    vm_label=${vm_labels[$i]}
 
    echo "Start backup $snapshot_name export to NAS `date`..."
    cd $ExportPath
    mkdir $vm_label
    chmod 777 $ExportPath$vm_label
    cd $ExportPath$vm_label
    pwd
    rm -f $snapshot_name$backup_ext
    echo=`xe vm-export uuid=$snapshot_uuid filename="$snapshot_name$backup_ext"`  # Export the Snapshot to backup path.
    if [ $? -ne 0 ]; then
        echo "failed to export snapshot name = $snapshot_name$backup_ext"
        ret_code=1
    else    
        echo "Successfully backup $snapshot_name to $ExportPath$snapshot_name at `date`"
    fi
 
    echo=`xe vm-uninstall force=true uuid=$snapshot_uuid`    # Remote the Snapshot.
    if [ $? -ne 0 ]; then
        echo "failed to remove temporary snapshot name = $snapshot_name"
        ret_code=1 
    fi
done
exit $ret_code 
}
#-----------------------------------------------------------------------------------------------------------------------------
MOUNT()
{
for i in `xe snapshot-list --minimal | sed -e 's/,/\ /g'` ; do
echo $i ;
xe snapshot-uninstall snapshot-uuid="$i" force=true
done
mkdir /var/backup/NWBKP
umount -l /var/backup/NWBKP
mount   172.18.36.1:/volume1/Xen_Backup     /var/backup/NWBKP
mount | grep /var/backup/NWBKP
if [ $? -eq 0 ]
then 
echo "Drive is Mounted "
BACKUP
else 
sendEmail -v -s waterbury.glaceemr.net:2500 -f  donotreply@glenwoodsystems.com -t serveradmins@glenwoodsystems.com  -u PROBLEM IN `hostname` server -m Backup Devive Not Mounted. Please Check.
echo "Drive is Not Mounted"
fi

}
#-----------------------------------------------------------------------------------------------------------------------------
MOUNT

