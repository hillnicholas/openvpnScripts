#!/bin/bash

# ETH is the device you want to bridge to the VPN. 
# this cannot be the device you connect to the internet with. 
ETH="enp0s25"

# This is the name of the bridge we will create.
VPN_BRIDGE="vpnbr0"

# This is the name of the TAP device created by the OpenVpn client.
TAP="tap0"

# set to true if you want to connect the host to the VPN 
CONNECT_BRIDGE_HOST=false
# if you set the above to true, you must define the DHCP 
# client command (Ubuntu 16.04 is dhclient)
#dhcp_client=dhclient

# check for bad number of arguments
if [ $# -ne 2 ]; then
	echo "Error: this script takes only two arguments."
	exit
fi


# config file declared by command
CONFIG="$2"

function start_bridge {
	# start the openvpn service if not already started, exit on failure
	systemctl restart openvpn@$1 || exit 1

	# wait for tap device to show up
	while [ -z "$( cat /proc/net/dev | grep $TAP: )" ]; do
		sleep 1
	done

	# create the virtual switch
	ovs-vsctl --may-exist add-br $VPN_BRIDGE 
	ovs-vsctl --may-exist add-port $VPN_BRIDGE $ETH 
	ovs-vsctl --may-exist add-port $VPN_BRIDGE $TAP

	# flush any existing IP addresses 
	ip addr flush dev $TAP
	ip addr flush dev $ETH

	# configure the bridge ports 
	ip link set dev $TAP up promisc on 
	ip link set dev $ETH up 
	
	if ($CONNECT_BRIDGE_HOST); then
		$dhcp_client $VPN_BRIDGE
	fi
}

# Commands needed to stop the OpenVpn bridge
function stop_bridge {
	# stop the openvpn tap device
	systemctl stop openvpn@$1

	# delete the bridge 
	ovs-vsctl --if-exists del-br $VPN_BRIDGE

	# set ethernet back to not promiscuous 
	ip link set dev $ETH promisc off
}



# handle the commands
if [ "$1" == "start" ]; then
	start_bridge $CONFIG

elif [ "$1" == "stop" ]; then
	stop_bridge $CONFIG

fi

