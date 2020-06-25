#!/bin/bash
dhcp=""
filename="config.yaml"
#filename="50-cloud-init.yaml"

# Assign values to the variables

ip=""
gateway=""
dns=""
device=""
devices=$(ls /sys/class/net/)

DIALOG${DIALOG=dialog}
$DIALOG --title "Netplan TUI" --clear \
--defaultno --yesno "Do you want to use DHCP? (Usually no)" 10 45

case $? in
	0)
	device=$(dialog --title "Netplan TUI" --backtitle "Netplan TUI" \
		 --inputbox "Device: " 8 60 \
	 3>&1 1>&2 2>&3 3>&-)
	echo -e "network:\n\t version: 2\n\t renderer: networkd\n\t ethernets:\n\t\t $device:\n\t\t dhcp4: true" > /etc/netplan/$filename && netplan apply && clear && echo "Sucessfully changed Network Settings!" && exit;;

	1)
	 dhcp="no";;
esac



 #open fd
exec 3>&1

# Store data to $VALUES variable
VALUES=$(dialog --ok-label "Submit" \
	  --backtitle "Netplan TUI" \
	  --title "Netplan TUI" \
	  --form "Netplan TUI" \
15 50 0 \
	"IP/CIDR:" 1 1	"$ip" 	1 10 40 0 \
	"Gateway"    2 1	"$gateway"  	2 10 40 0 \
	"DNS:"    3 1	"$dns"  	3 10 40 0 \
	"Device:"     4 1	"$device" 	4 10 40 0 \
2>&1 1>&3)

 #close fd
exec 3>&-

clear

ipaddr=`echo $VALUES | cut -d ' ' -f 1`
dgateway=`echo $VALUES | cut -d ' ' -f 2`
ddns=`echo $VALUES | cut -d ' ' -f 3`
ddevice=`echo $VALUES | cut -d ' ' -f 4`

# Write to file

echo -e "network:\n\t version: 2\n\t renderer: networkd\n\t ethernets:\n\t\t $ddevice:\n\t\t dhcp4: $dhcp\n\t\t addresses:\n\t\t\t - $ipaddr\n\t\t gateway4: $dgateway\n\t\t nameservers:\n\t\t\t addresses: [$ddns]" > /etc/netplan/$filename

netplan apply
echo "Sucessfully changed Network Config!"
