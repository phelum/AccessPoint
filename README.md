    hap4mb

The name comes from hostapd for mobile broadband.  These scripts
enable the device to be an access point with the upstream link
via a mobile phone or a mobile broadband dongle.

The main script files are mon4hap, hap4mb_mon, and hap4mb_ctl.

mon4hap monitors the wifi and link interfaces and will start
the wifi in station mode and then react when an upstream link
appears.  This occurs when the device is plugged in and udev
creates the interface file.

hap4mb_mon starts/stops hap4mb_ctl when interfaces change.  This
means the device will be in wifi station mode until an upstream link
is enabled.

hap4mb_ctl runs an access point session.  It kills the wifi interface
and then runs hostapd until a terminating event occurs.

The recommended setup is to start mon4hap at startup (e.g. from
rc.local) so it can react to interface changes and cause the device
to either be in wifi station mode or access point mode.  The rc.local
command is "setsid -f /usr/local/bin/mon4hap > /var/log/mon4hap.log".
For testing it would be better to start mon4hap manually (perhaps with
the "-d" switch) and view the screen output.

    Installation.

All the /ulb files and bash_ip4.sh should be in /usr/local/bin.
Customising mon4hap.conf and hap4mb.conf will be required for your
network details and interfaces.

The eth1 and usb0 files are from my network interfaces.
Obviously they will require customising for other machines.
Which interface gets created for the dongle depends on the dongle.
Smart dongles with DHCP server capability often appear as eth*
devices while simpler devices (e.g. dumbphones) appear as usb*.
I now use udev rules so the interfaces are given special names
based on their MAC address.  This allows entries in the script
files to enable/disable certain features based on the upstream
interface name.  These upstream interfaces should not be "auto"
or "allow-hotplug" as mon4hap will start them as appropriate.


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

mon4hap.conf specifies your wifi and dongle interface names.

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
the log output.  If the interface file doesn't include the post-up
option then mon4hap will use the default.

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
    setsid -f /usr/local/bin/mon4hap > /var/log/mon4hap.log

    /etc/network/interfaces must contain an iface called manual
    that is "inet manual" and specifies the "wpa-conf", e.g.
    iface manual inet manual
    wpa-conf    /wpa/all.conf

    To minimise startup time the wifi interface should be:
    #allow-hotplug
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
    Starting dhclient before a connection is established is pointless.

2024-11-02
    mon4hap now kills any wifi dhclient when starting an upstream
    interface.  This stops pointless requests when wifi is in access
    point mode.
    mon4hap now check the interfaces files and will run the required
    pre-up, post-up, and post-down tasks if not mentioned in the
    interface entry.  This avoids having to modify the interface
    files.
    The example interfaces files are now in the interfaces directory.
    The /usr/local/bin files are now in the ulb directory.
    

