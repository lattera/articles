# Creating a Completely Tor-ified Home Network

One thing I've always wanted to do is support Tor by running a public
relay. However, I didn't have a machine to dedicate to it. All of my
normal systems hold data I don't want to expose to Tor (ssh keys,
browser sessions, etc.) Now that FreeBSD has initial support for the
Raspberry Pi 3, I can now run an inexpensive Tor relay. At the same
time, I could use it to create a special Tor network at home. All data
transmitted over the network destined for the public Internet would go
through Tor first.

Since I prefer HardenedBSD over normal FreeBSD, that's what we'll be
setting up in this article. Though this article focuses on using the
HardenedBSD on the RPI3, the concepts apply equally to FreeBSD or
HardenedBSD on any architecture.

## Important OPSEC Note

Please note that this article is one of a technical nature. It will
show you how to do things. However, this article does NOT teach proper
OPSEC. Please keep that in mind if you experiment. 

Remember to never divulge sensitive or personal information over Tor
if you're using it purely for anonymity. This includes even storing
personal or revealing information on devices connected to the
Tor-ified network.

Here's some great articles on OPSEC:

* https://medium.com/@thegrugq/twitter-activist-security-7c806bae9cb0#.8uxhsymdl
* http://www.slideshare.net/grugq/opsec-for-hackers
* https://medium.com/@thegrugq/real-talk-on-reality-cf07cbb78530

Please also see these two emails from the tor-relays mailing list:

1. https://lists.torproject.org/pipermail/tor-relays/2014-October/005541.html
1. https://lists.torproject.org/pipermail/tor-relays/2014-October/005544.html

## Requirements

These are the things I used:

1. Raspberry Pi 3 Model B Rev 1.2 (aka, RPI3)
1. Serial console cable for the RPI3
1. Belkin F4U047 USB Ethernet Dongle
1. Insignia NS-CR2021 USB 2.0 SD/MMC Memory Card Reader
1. 32GB SanDisk Ultra PLUS MicroSDHC
1. A separate system, running FreeBSD or HardenedBSD
1. HardenedBSD image for the RPI3
1. An external drive to be formatted
1. A MicroUSB cable to power the RPI3
1. Two network cables
1. Optional: Edimax N150 EW-7811Un Wireless USB
1. Basic knowledge of vi

As of the time of this writing, the HardenedBSD images for the rpi3
be found here:
https://hardenedbsd.org/~shawn/rpi3/

## Preparation

First, download, uncompress, and flash the HardenedBSD RPI3 image to
the SD card. Replace the $usb veriable with the path to the sdcard device entry.

This bit assumes you're using a build from 2017-05-23. However, you'll
probably want to use a newer build. Adjust the commands accordingly.

```
$ usb=/dev/da0
$ fetch https://hardenedbsd.org/~shawn/rpi3/2017-05-23/HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-NODEBUG-5b2b82548001.img.xz
$ unxz HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-NODEBUG-5b2b82548001.img.xz
$ sudo dd if=HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-NODEBUG-5b2b82548001.img of=$usb bs=64k
```

Attach the serial console to your RPI3 and plug the USB side to your
system. Now open a new terminal and connect to the console:

```
$ sudo cu -s 115200 -l /dev/cuaU0
```

Plug in the MicroUSB cable to the RPI3 and watch it boot up to the
login screen. By default, there's a non-root account with the
username/password of hbsd/hbsd. The root account has no password.

## Initial Setup

Now that we have HardenedBSD flashed, we'll want to do the initial
setup tasks.

Grow the root filesystem to fill the full SD card:

```
$ sudo service growfs onestart
```

Edit /boot/loader.conf to look like this:

```
geom_label_load="YES"           # File system labels (see glabel(8))
if_ure_load="YES"
pf_load="YES"
```

Edit /etc/rc.conf to look like this:

```
hostname="torified"
ifconfig_ue0="DHCP"
ifconfig_ue1="inet 192.168.5.1 netmask 255.255.255.0"
sshd_enable="YES"

powerd_enable="YES"

# Nice if you have a network, else annoying.
#ntpd_enable="YES"
ntpd_sync_on_start="YES"

# Uncomment to disable common services (more memory)
#cron_enable="NO"
#syslogd_enable="NO"
sendmail_enable="NONE"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
ntpd_enable="YES"

tor_enable="YES"
pf_enable="YES"
dhcpd_enable="YES"
```

Edit /etc/make.conf to look like this:

```
MAKE_JOBS_NUMBER=2
```

## Installing Packages

Previously, this section was about installing the following packages
via the ports tree. Now that HardenedBSD maintains a signed package
repo for 12-CURRENT/arm64, that is no longer needed. Using packages is
now the preferred method for this article.

Required packages:

1. ports-mgmt/pkg
1. security/tor
1. net/isc-dhcp43-server

```
$ sudo pkg install -y tor isc-dhcp43-server
```

The first time you run ```pkg install```, it will install
```ports-mgmt/pkg``` for you. Thus, you only need to install tor and
isc-dhcp43-server.

## Configuring pf

Tor has native support for pf, so that's what we'll use for the
transparent proxy part.

In my setup, the onboard NIC (ue0) is connected to the normal LAN and
the USB NIC (ue1) is the NIC we'll want the tor-ified devices to
connect to. ue0 has an DHCP address in the 192.168.1.0/24 network and
ue1 has a static IP of 192.168.5.1/24.

Edit /etc/pf.conf to look like this:

```
wan_if="ue0"
lan_if="ue1"

non_tor = "{ 192.168.5.0/24 }"
trans_port = "9040"
dns_port = "1053"

scrub in

no rdr on { $lan_if } inet proto tcp to port 23
no rdr on { $lan_if } inet proto tcp to port 25
no rdr on { $lan_if } inet proto tcp to port 53
no rdr on { $lan_if } inet proto tcp to port 88
no rdr on { $lan_if } inet proto tcp to port 138
no rdr on { $lan_if } inet proto tcp to port 139
no rdr on { $lan_if } inet proto tcp to port 143
no rdr on { $lan_if } inet proto tcp to port 213

rdr pass on $lan_if inet proto tcp to !($lan_if) -> 127.0.0.1 port $trans_port
rdr pass on $lan_if inet proto udp to port domain -> 127.0.0.1 port $dns_port

pass quick proto tcp from $lan_if:network to $lan_if:network
block return quick proto tcp from { $lan_if:network } to any

pass quick on { lo0 $wan_if } keep state
pass out quick route-to $lan_if inet proto udp to port $dns_port keep state
pass out quick inet to $non_tor keep state
pass out route-to lo0 inet proto tcp all flags S/SA modulate state
```

Append the following line to /etc/devfs.conf:

```
own pf _tor:_tor
```

At this point, I would actually reboot. That way, pf gets loaded at
boot and devfs picks up the new ownership of /dev/pf.

## Configuring tor

This is what my /usr/local/etc/tor/torrc file looks like. I also have
a local SOCKS proxy enabled so I can still connect to Tor simply using
another system that isn't fully behind the Tor-ified network.

```
SOCKSPort 0.0.0.0:9050
SOCKSPolicy accept 192.168.1.0/24
SOCKSPolicy accept 192.168.5.0/24
SOCKSPolicy reject *
Log notice file /var/log/tor-notices.log

VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 1053
```

Tor is now fully set up to be both a public relay and a transparent
proxy for the network!

## Configuring dhcpd

This part is optional. If you don't want to offer DHCP on your
Torified network, skip this section. You'll simply need to use static
IPs and set both the default gateway and default nameserver to
192.168.5.1.

Edit your /usr/local/etc/dhcpd.conf file to look like this:

```
subnet 192.168.1.0 netmask 255.255.255.0 {
}

subnet 192.168.5.0 netmask 255.255.255.0 {
        range 192.168.5.100 192.168.5.250;
        option routers 192.168.5.1;
        option domain-name-servers 192.168.5.1;
        option domain-name "torified.dev";
}
```

Perform one more reboot to make sure everything comes up nicely.

We're now all done! You should now be fully, 100% set up as a Torified
network. Happy onioning!

## Optional: Wireless Client

In case you can't plugin to an ethernet port (like, guest wifi at a
coffee shop), you can use a USB wireless dongle. I recommend the
Edimax N150 EW-7811Un adapter, since that's natively supported via the
rtwn(4) driver in FreeBSD.

You will need to edit your /etc/pf.conf file to set ```lan_if``` to
"wlan0".

If you're connecting to an open wireless network that does NOT have a
captive portal, setting up wireless is rather easy:

```
$ sudo ifconfig wlan0 create wlandev rtwn0 ssid name_of_wireless_ssid up
$ sudo dhclient wlan0
```

If you're connecting to a WPA-secured network that does NOT also have
a captive portal, you'll need to edit your /etc/wpa_supplicant.conf
file. Mine looks something like this:

```
network={
	ssid="some ssid here"
	psk="network wpa2 password here"
}
```

Then, in /etc/rc.conf, I would have:

```
wlans_rtwn0="wlan0"
ifconfig_wlan0="WPA DHCP"
```

I've not yet tried connecting to a network with a captive portal. Once
I encounter a captive portal setup, I'll update this article with
instructions on how to login to it.

## Optional: Wireless AP

I'm going to go pretty quick with this section, since having read all
of the above, you should be familiar with what's going on. On my RPI3,
I now have two USB Wireless NICs: wlan0 and wlan1. wlan0 is to act as
a wireless client and wlan1 as a wireless AP. 

In my ```/etc/rc.conf``` file, I have:

```
wlans_rtwn1="wlan1"
create_args_wlan1="wlanmode hostap"
ifconfig_wlan1="inet 192.168.12.1 netmask 255.255.255.0 ssid tornet mode 11g"
```

In my ```/etc/pf.conf``` file, I have:

```
wan_if="wlan0"
lan_if="igb1"
wlan_if="wlan1"

non_tor = "{ 192.168.11.0/24, 192.168.12.0/24 }"
trans_port = "9040"
dns_port = "1053"

scrub in

no rdr on { $lan_if, $wlan_if } inet proto tcp to port 23
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 25
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 53
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 88
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 138
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 139
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 143
no rdr on { $lan_if, $wlan_if } inet proto tcp to port 213

rdr pass on $wlan_if inet proto tcp to !($wlan_if) -> 127.0.0.1 port $trans_port
rdr pass on $wlan_if inet proto udp to port domain -> 127.0.0.1 port $dns_port

rdr pass on $lan_if inet proto tcp to !($lan_if) -> 127.0.0.1 port $trans_port
rdr pass on $lan_if inet proto udp to port domain -> 127.0.0.1 port $dns_port

pass quick proto tcp from $lan_if:network to $lan_if:network
block return quick proto tcp from { $lan_if:network, $wlan_if:network } to any

pass quick on { lo0 $wan_if } keep state
pass out quick route-to $lan_if inet proto udp to port $dns_port keep state
pass out quick route-to $wlan_if inet proto udp to port $dns_port keep state
pass out quick inet to $non_tor keep state
pass out route-to lo0 inet proto tcp all flags S/SA modulate state
```

In my ```/usr/local/etc/dhcpd.conf``` file, I have:

```
subnet 192.168.1.0 netmask 255.255.255.0 {
}

subnet 192.168.11.0 netmask 255.255.255.0 {
        range 192.168.11.100 192.168.11.250;
        option routers 192.168.11.1;
        option domain-name-servers 192.168.11.1;
        option domain-name "torified.dev";
}

subnet 192.168.12.0 netmask 255.255.255.0 {
        range 192.168.12.100 192.168.12.250;
        option routers 192.168.12.1;
        option domain-name-servers 192.168.12.1;
        option domain-name "torifiedwifi.dev";
}
```

## Connecting to a captive portal network

Connecting to a network that uses a captive portal is tricky, since
connecting to Tor will most likely be blocked until you authenticate
with the captive portal.

Additionally, since the RPI3 isn't running a GUI with a web browser,
the RPI3 itself cannot perform the authentication step.

**NOTE**: The following steps have the potential to leak info. Those
who want to be extra careful likely will want to find another network
not secured by a captive portal.

In order to authenticate, you'll need to perform the following steps:

1. Stop Tor on the RPI3
1. Set up NAT on the RPI3
1. Connect a device to the RPI3's network you set up above (wired or
   wireless).
1. Open a web browser, and browse to some internet-facing IP address
   (I plugged in 8.8.8.8, Google's public DNS server).

Stopping Tor is as easy as running the following command as root:

```
$ sudo service tor stop
```

Setting up NAT will require you to have a new pf configuration file,
which I conveniently placed at ```/etc/pf.conf.nat```:

```
nat on wlan0 from any to any -> (wlan0)
pass in all
pass out all
```

In this case, wlan0 is the NIC connected to the captive portal
network. You'll also need to set the ```net.inet.ip.forwarding```
sysctl node to ```1``` and load the new pf ruleset:


```
$ sudo sysctl net.inet.ip.fowarding=1
$ sudo pfctl -f /etc/pf.conf.nat
```

Once that's done, you can now use your device to browse to the
internet-facing IP address. You should be redirected to the captive
portal authentication page.

Once authenticated, you can undo the pf ruleset change, the IP forward
mode, and start Tor back up:

```
$ sudo pfctl -f /etc/pf.conf
$ sudo sysctl net.inet.ip.fowarding=0
$ sudo service tor start
```

You should now be good to go to start using your Tor-ified network.
Again, performing these steps does have the possibility of leaking
personally identifying information to either the public internet or
the local network. Please keep that in mind prior to following these
steps.
