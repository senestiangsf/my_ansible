#! /bin/sh

# Colors
Yellow='\033[1;33m'
NC='\033[0m'

echo "";
echo "";
echo "";
printf "${Yellow}Output van die scipt SCAN_Disk-per-slot.sh${NC}\n"

echo "";
# Spacing
Spacing='%10s%10s%6s%7s%30s%15s%10s%30s%15s%15s\n'

# Header
echo -e "*********************************************************************************************************************"
printf $Spacing "" "" "" "" "" "" "" 
printf $Spacing "Disk" "Posisie" "Slot" "OSD" "Disk ID" "Serial" "Service"
printf $Spacing "" "" "" "" "" "" ""

tel=0;

for drivePath in /dev/sd[a-z] /dev/sd[a-z][a-z]; do
	drive=$(echo $drivePath | cut -d "/" -f3);
	arr+=( "$drive" )
	
done;

# Length of array
DiskTotaal=${#arr[@]};
DiskOS=0;
DiskOnbekend=0;
ServerNaam=$(hostname);
FileExt=".txt";

for disk in "${arr[@]}"
   do
	slotOS=$(ls -ld /sys/block/sd*/device | grep -w $disk  | awk '{ print $11 }' | cut -d "/" -f4 | cut -d ":" -f1);
	slotOSD=$(ls -ld /sys/block/$disk | cut -d'>' -f 2 | awk -F '/target' '{print $1}' | awk -F 'end_device-0:' '{print $2}');
	osd=$(df -h | grep $disk | awk '{ print $6 }' | cut -d "-" -f2);
	
	if [ $slotOS == "0" ]
		then
			if [ -z "$osd" ]
				then
					message=" ";
					((DiskOnbekend++));
					diskID=$(ls -l /dev/disk/by-id | grep "scsi-" | grep -v "part" | grep -w $disk | grep -v "SATA" | grep -v "SHGST" | awk '{ print $9 }');
					serial=$(udevadm info --query=all --name=/dev/$disk | grep SCSI_IDENT_SERIAL= | cut -d'=' -f 2);
				else
					message="$osd";
					diskID=$(ls -l /dev/disk/by-id | grep "scsi-" | grep -v "part" | grep -w $disk | grep -v "SATA" | grep -v "SHGST" | awk '{ print $9 }');
					serial=$(udevadm info --query=all --name=/dev/$disk | grep SCSI_IDENT_SERIAL= | cut -d'=' -f 2);
			fi

			# Toets of slot voor of agter is
		        SlotVar1=$(echo $slotOSD | cut -d':' -f 1);
			SlotVar2=$(echo $slotOSD | cut -d':' -f 2);
	
			if [ $SlotVar1 == "0" ]
				then
					SlotPos1="Voor";
			elif [ $SlotVar1 == "1" ]
				then
					SlotPos1="Agter";
			fi

			else
				message="Raid";
				diskID="   ";
				serial="   ";
				((DiskOS++));
				SlotPos1=" ";
				SlotVar2=" ";
				ServiceStatus="";
	fi

	# Is the service running of nie?
	ServiceStatus=$(systemctl status ceph-osd@$osd 2>/dev/null | grep Active | awk '{ print $2}');
	
	printf $Spacing "$disk" "$SlotPos1" "$SlotVar2" "$message" "$diskID" "$serial" "$ServiceStatus"


	#echo -e "$disk \t $SlotPos1 \t Slot: $SlotVar2 \t $message \t $diskID \t $serial \t $ServiceStatus";
	
   done


printf $Spacing "" "" "" "" "" "" "" ""
echo -e "*********************************************************************************************************************"
echo "";
echo "";
