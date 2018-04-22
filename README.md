# openvpnScripts
Shell scripts for OpenVPN. More scripts will be created.

### vpn-site-to-site
Creates virtual private lan service to bind two LANs together. Requires the client-to-client option to be enabled on the server.

#### Usage: 
```
./vpn_bridge.sh [start|stop] [OpenVPN client config]
```

#### Required Software Packages
(Ubuntu 16.04): openvswitch-switch openvpn


### route-switching.sh
This will increment the default tunneling device and auto-configure the routing. Requires multiple tunnels to be open.
