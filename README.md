    hap4mb

Name comes from hostapd for mobile broadband.


    Installation.

All the hap* files and bash_ip4.sh should be in /usr/local/bin.
Customising hap4mb.conf is required for your network details
and interfaces.

The eth1 and usb0 files are from my network interfaces.
Obviously they will require customising for other machines.
Which interface gets created for the dongle depends on the dongle.
Smart dongles with DHCP server capability often appear as eth*
devices while simpler devices (e.g. dumbphones) appear as usb*.
Both these interfaces should be "allow-hotplug".
The key change is that pre-up, post-up, and post-down call the
monitor script (/usr/local/bin/hap4mb_mon).


    Packages Required.

arping
bridge-utils
dnsmasq
hostapd
iproute2
iputils-ping
nftables
setsid

    Configuration.

Configuration options are in hap4mb.conf.
WLAN_SSID and WLAN_PASS must be loaded to suit the system.
WLAN_IFACE must be loaded to suit the system.

Although HAP_BRIDGE is an option it should always be selected.
HAP_DNSMASQ and HAP_MASQUERADE are optional.

If you need dnsmasq here you probably need masquerade as well.
If the upstream host is a DCHP server you probably don't need either.

If you need Samba to work here then smb.conf must either allow
all interfaces or at least have the relevant interfaces listed
in the bind-interfaces list.  nmbd complaining about no network
interfaces is the clue here (check syslog).

The default log file (/var/log/hap4mb.log) is specified in the
post-up option in the /etc/network/interfaces entry for the
upstream interface.  Enabling HAP_DEBUG will considerably increase
the log output.

There is a periodical ping option in the monitor script.  This
helps keep mobile broadband connections alive when otherwise idle.
However, some IPv6 connections die after a period apparently
decided by the upstream router regardless of any actvity.  This has
me puzzled because the router advertisement does not specify such
a limit (e.g. 1800 seconds).


    Feedback.

Please report any issues or improvements to me via my details here
at github.

Thanks,
Steven

2024-08-02  Original release.

2024-08-05
    Wait max 10 seconds for IPv4 address on upstream link.
    Change periodical ping to use default route.

2024-08-09
    Change to hide password in hostapd conf temp file.

2024-08-31
    Changed route entries to enable access of access point
    and stations on Wi-Fi LAN.

2024-09-01
    Changed mon4hap so link interfaces are tried before
    defaulting to station mode.

    The /etc/rc.local patch to start this monitor is:
    setsid -f /usr/local/bin/mon4hap > /var/log/mon.log

    /etc/network/interfaces must contain an iface called manual
    that is "inet manual" and specifies the "wpa-conf", e.g.
    iface manual inet manual
    wpa-conf    /wpa/all.conf

    To minimise startup time the wifi interface should be:
    allow-hotplug
    iface <wifi name> inet manual
    wpa-conf <desired conf file>

2024-09-02
    Added mon4hap.conf so interface details don't have
    to be modified in mon4hap.

2024-09-27
    Improved mon4hap so system correctly changes from host
    to AP mode each time the upstream dongle is inserted and
    reverts to host mode when the dongle is removed.  Problem
    was that status file used by ifup is not updated when an
    enabled dongle is removed.

2024-10-10
    Changed mon4hap so dhclient for wifi not started when no carrier.
    Previous approach (testA && testB || action) didn't work.

