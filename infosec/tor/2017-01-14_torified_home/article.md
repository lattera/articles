Creating a Completely Tor-ified Home Network
============================================

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

Requirements
------------

These are the things I used:

1. Raspberry Pi 3 Model B Rev 1.2 (aka, RPI3)
1. Serial console cable for the RPI3
1. Belkin F4U047 USB Ethernet Dongle
1. Insignia NS-CR2021 USB 2.0 SD/MMC Memory Card Reader
1. 32GB SanDisk Ultra PLUS MicroSDHC
1. A separate system, running FreeBSD or HardenedBSD
1. HardenedBSD clang 4.0.0 image for the RPI3
1. An external drive to be formatted
1. A MicroUSB cable to power the RPI3
1. Two network cables
1. Optional: Edimax N150 EW-7811Un Wireless USB
1. Basic knowledge of vi

As of the time of this writing, the HardenedBSD clang 4.0.0 image can
be found here:
https://hardenedbsd.org/~shawn/rpi3/clang400-2017-01-11/HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-774b588d523.img.xz

Preparation
-----------

First, download, uncompress, and flash the HardenedBSD RPI3 image to
the SD card. Replace the $usb veriable with the path to the sdcard device entry.

```
$ usb=/dev/da0
$ fetch https://hardenedbsd.org/~shawn/rpi3/clang400-2017-01-11/HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-774b588d523.img.xz
$ unxz HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-774b588d523.img.xz
$ sudo dd if=HardenedBSD-RaspberryPi3-aarch64-12.0-HARDENEDBSD-774b588d523.img.xz of=$usb bs=64k
```

Attach the serial console to your RPI3 and plug the USB side to your
system. Now open a new terminal and connect to the console:

```
$ sudo cu -s 115200 -l /dev/cuaU0
```

Plug in the MicroUSB cable to the RPI3 and watch it boot up to the
login screen. By default, there's a non-root account with the
username/password of hbsd/hbsd. The root account has no password.

Initial Setup
-------------

Now that we have HardenedBSD flashed, we'll want to do the initial
setup tasks.

Grow the root filesystem to fill the full SD card:

```
# service growfs onestart
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

Installing Ports
----------------

Required ports:

1. ports-mgmt/pkg
1. security/tor
1. net/isc-dhcp43-server

I used iscsi for this, since powering the RPI3 over USB is kinda iffy.
Powering both the RPI3 and a USB drive attached to it can cause
issues. I'll leave figuring out iscsi to the reader, but this is how
you would do it if you attached a USB drive.

DO **NOT** try building ports directly on the SD card. You'll wear it
out. Trust me; I've learned from experience on this one.

First, we'll reformat and mount the drive to /usr/ports.

```
# newfs /dev/da0
# mkdir /usr/ports
# mount /dev/da0 /usr/ports
```

Now download the HardenedBSD ports tree:

```
# cd $HOME
# fetch --no-verify-peer https://github.com/HardenedBSD/hardenedbsd-ports/archive/master.tar.gz
# tar -xf master.tar.gz -C /usr/ports --strip-components 1
```

Now compile and install the required ports. If a process segfaults,
simply restart the build. FreeBSD's support for the RPI3 is still very
much a work-in-progress and occasional random segfaults happen.

```
# cd /usr/ports/ports-mgmt/pkg
# make install BATCH=1
# cd /usr/ports/security/tor
# make install BATCH=1
# cd /usr/ports/net/isc-dhcp43-server
# make install BATCH=1
```

This process may take a while. Due to the potential for random
segfaults, the process needs to be babysat. But grab a drink, watch an
episode or two of Mr Robot, make yourself comfortable.

Configuring pf
--------------

Tor has native support for pf, so that's what we'll use for the
transparent proxy part.

In my setup, the onboard NIC (ue0) is connected to the normal LAN and
the USB NIC (ue1) is the NIC we'll want the tor-ified devices to
connect to. ue0 has an DHCP address in the 192.168.1.0/24 network and
ue1 has a static IP of 192.168.5.1/24.

Edit /etc/pf.conf to look like this:

```
lan_if = "ue0"
tor_if = "ue1"

non_tor = "{ 192.168.1.0/24 }"

trans_port = "9040"

scrub in

rdr pass on $tor_if inet proto tcp to !($tor_if) -> 127.0.0.1 port $trans_port
rdr pass on $tor_if inet proto udp to port domain -> 127.0.0.1 port 1053

pass quick on { lo0 $lan_if } keep state
pass out quick route-to $tor_if inet proto udp to port 1053 keep state
pass out quick inet to $non_tor keep state
pass out route-to lo0 inet proto tcp all flags S/SA modulate state
```

Append the following line to /etc/devfs.conf:

```
own pf _tor:_tor
```

At this point, I would actually reboot. That way, pf gets loaded at
boot and devfs picks up the new ownership of /dev/pf.

Configuring tor
---------------

This is what my /usr/local/etc/tor/torrc file looks like. I also have
a local SOCKS proxy enabled so I can still connect to Tor simply using
another system that isn't fully behind the Tor-ified network.

```
SOCKSPort 0.0.0.0:9050
SOCKSPolicy accept 192.168.1.0/24
SOCKSPolicy accept 192.168.5.0/24
SOCKSPolicy reject *
Log notice file /var/log/tor-notices.log

ORPort 9001
ExitPolicy reject *:*
nickname tornop
ContactInfo torified@example.com

VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 1053
```

Tor is now fully set up to be both a public relay and a transparent
proxy for the network!

Configuring dhcpd
-----------------

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

Optional: Wireless Client
-------------------------

In case you can't plugin to an ethernet port (like, guest wifi at a
coffee shop), you can use a USB wireless dongle. I recommend the
Edimax N150 EW-7811Un adapter, since that's natively supported via the
rtwn(4) driver in FreeBSD.

You will need to edit your /etc/pf.conf file to set ```lan_if``` to
"wlan0".

If you're connecting to an open wireless network that does NOT have a
captive portal, setting up wireless is rather easy:

```
# ifconfig wlan0 create wlandev rtwn0 ssid name_of_wireless_ssid up
# dhclient wlan0
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

TODO
----

1. Logging into a captive portal
1. Setting up a wireless AP
