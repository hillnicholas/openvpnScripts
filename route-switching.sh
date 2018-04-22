#!/bin/bash 




VERBOSE=false


function rotate {
	# get current tunnel device
	local tun_dev=$( ip route | sed -ne "s/0\.0\.0\.0\/1\svia\s[0-9\.]\+\sdev\s\(tun[0-9]\+\)/\1/p"  )
	# get the number associated with the tun device
	local tun_num=${tun_dev//tun/}
	# increment the tunnel device
	local new_tun_num=$( expr \( $tun_num + 1 \) % $( ls -d /proc/sys/net/ipv4/conf/tun* | wc  -l ) )
	# increment the tunnel device 
	local new_tun_dev="tun${new_tun_num}"
	local new_tun_gateway=$( netstat -rn | sed -ne "/$new_tun_dev/ s/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*/\1.1/p")
	# capture old route 
	local old_route=$( ip route | grep ^0\.0\.0\.0 )

	verbose "new tun dev: $new_tun_dev"
	verbose "new_tun_gateway: $new_tun_gateway"
	verbose "adding the following route: 0.0.0.0/1 via $new_tun_gateway dev $new_tun_dev"
	verbose "removing route: $old_route"

	# delete old route if exists
	if [ ! -z  "$old_route" ]; then
		verbose "deleting route"
		ip route del $old_route
	fi

	# add new route
	ip route add 0.0.0.0/1 via $new_tun_gateway dev $new_tun_dev	
}


function verbose {
	if $VERBOSE; then
		echo $1 
	fi
}


function runtest {
	VERBOSE=true
	while true; do
		rotate
		sleep 5
	done
}



if [ $# -gt 0 ]; then 
	case $1 in 
	--verbose | -v )
		VERBOSE=true
		;;
	
	--test| -t )
		runtest
		;;
	*)
		echo "Argument \"$1\" not understood"
		exit
	esac
fi
rotate

