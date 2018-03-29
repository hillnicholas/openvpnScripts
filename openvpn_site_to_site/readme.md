This script assists in setting up a site-to-site layer 2 VPN using OpenVPN. This script requires ethernet bridging. This script is currently written for openvswitch exclusively, but a script utilizing bridge-utils can be created quite easily by switching some commands around. 

usage:
	./vpn_bridge.sh [start|stop] [OpenVPN client config]


required software packages (Ubuntu 16.04):
openvswitch-switch
openvpn


