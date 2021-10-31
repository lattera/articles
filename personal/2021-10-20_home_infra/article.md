# October 2021 Home Infrastructure Status

Last modified: 31 Oct 2021, 08:26 EDT

Please note that this is a living document. I plan to evolve this
article in step with the infrastructure. If you're interested in
following the evolution of this document, please look at the git
commit history.

My infrastructure at home is slowly growing. Now that I'm working from
home 99% of the time, I want to make sure that my home network is as
locked down as I can get it.

I also use my home network as a playground for both HardenedBSD's and
my work's production networks.

## About the Home

FiOS' fiber line is terminated at my home with an ethernet cable going
from the fiber termination in to the home. So I can just directly
connect my HawkSense firewall rather than use their crappy, insecure
"modem." The bulk of the infrastructure is located in my messy
unfinised basement since the ethernet termination point is there.

My home office is right next to where the equipment sits.
Unfortunately, our HVAC doesn't service the basement, so my home
office got up to 89F this summer.

However, the Wireless AP (WAP) is on the main floor. We have three
floors: the basement, the main floor, and the upper floor. Our house
is built as if it were a townhouse, though it's not classified as a
townhouse.

I have a CAT6 cable running between the floors. I have a TP-LINK L3
managed switch on the main floor, and a Cisco SG350 in the basement.
The CAT6 cable connects both switches. I regret buying the TP-LINK
switch as it doesn't support nearly the same features as I have on the
SG350 (for example: remote syslog support).

Where possible, all systems are connected via ethernet. I try to keep
the number of active wireless devices to an absolute minimum.

## Core Infrastructure

I'm eating my own dogfood by running the proprietary fork of OPNsense
(called [HawkSense](https://blackhawknest.com/features/)) I'm working
on at my ${DAYJOB} as my perimeter firewall. While OPNsense is moving
back towards FreeBSD, HawkSense will remain on HardenedBSD.

I use Hurricane Electric's [TunnelBroker](https://tunnelbroker.net/)
service for IPv6. Even if Verizon FiOS residential service supported
IPv6 (their business service does), I'd still want to use TunnelBroker
so that I can maintain my own static /48.

As far as hardware is concerned, the perimeter firewall is a
[Protectli](https://protectli.com/) FW6C with 32GB RAM, a 128GB
system drive and a 1TB data drive. It's a full ZFS install, so no UFS.

For wireless, I use HardenedBSD 13-STABLE on a
[PC Engines APU2](https://pcengines.ch/apu2.htm) using the WLE200NX.

At each transitive point (WAP, Switch, Firewall, etc.), a SPAN port is
enabled. So I can gain different kinds of visibility within the
network. I can easily isolate wireless packets from core
infrastructure packets by virtue of which SPAN port I'm connected to.

For example, the HawkSense firewall has a NIC dedicated for SPAN. The
WAP itself, too, has a NIC dedicated for SPAN. Each of the two L3
switches has a port in SPAN mode.

I suck at ASCII drawings, so here's my horrid attempt at creating a
representation of the setup:

```
+----------+
| Internet | <=> HawkSense <=> Cisco SG350 <=> [ Laptops, NAS, etc ]
+----------+               |  \
                           |   \
			   |    -=> TP-LINK <=> WAP
			   |
			   +===> Tor-ified Network <=> [ burner phones, R&D laptop, etc. ]
```

## Firewall

As mentioned before, HawkSense is my firewall. It's a proprietary fork
of OPNsense I've been working on at ${DAYJOB} for now a little over a
year.

I have a very strict set of egress rules, using allowlists to filter
traffic.

Suricata is enabled in IPS mode, using a good number of the ET Open
rulesets.

## syslog

I have an APU2 running syslog-ng on HardenedBSD. I have it set up to
listen on both TCP and UDP, on both IPv4 and IPv6. When a syslog
message is sent from a remote host, a host-level directory is created
in `/var/log/network`.

So if my DNS server, hostname of `dns-01.ip6.home.lan` sends a
message, then the logs for that server are in
`/var/log/network/dns-01.ip6.home.lan/`.

syslog-ng itself isn't running directly on the APU2. It's running in a
HardenedBSD jail. This way, I can take automated periodic snapshots of
the underlying ZFS dataset for the jail. If an attacker compromises
the jail, the attacker can only undo up to fourteen minutes, fifty-nine
seconds worth of log entries (depending on when the
every-fifteen-minute cronjob was last run).

NFSv4 ACLs provide the capability to limit modifications to a file as
append-only. However, I found that FreeBSD doesn't seem to honor the
append-only ACL entry I set. I was able to run `truncate -s 0
/path/to/file` even when the only ACL for the file was append-only (so
everything else should've been denied). I'm able to emulate the
append-only behavior somewhat by virtue of automated ZFS snapshots
in the host, outside of the jailed context.

I assume each and every message could itself be malicious. I treat
inspecting the log files with care. If any system was compromised, an
attacker could theoretically pivot to other systems via carefully
crafted malicious syslog messages. Would anyone do this? I doubt it.
But it's still within my own threat model. At this moment, I'd like to
thank the sarcasm gods for terminal escape codes. I mainly mention
this to demonstrate how I approach data I don't fully trust--I
naturally distrust even the data I generate.

To further harden the server, I've set the following sysctl nodes in
`/etc/sysctl.conf`

```
hardening.pax.aslr.status=3
hardening.pax.mprotect.status=3
hardening.pax.pageexec.status=3
hardening.pax.segvguard.status=3
```

In `/etc/rc.conf`, I've set securelevel to 3:

```
kern_securelevel_enable="YES"
kern_securelevel="3"
```

Every system in my infrastructure that can log to syslog have their
syslog messages forwarded to this syslog server. As a rule: if the
device can send syslog messages, it will.

Also, it looks like syslog messages compress very, very well:

```
syslog-01[shawn]:/home/shawn $ zfs get compressratio,used,logicalused rpool/var/log/network
NAME                   PROPERTY       VALUE  SOURCE
rpool/var/log/network  compressratio  20.73x  -
rpool/var/log/network  used           723M   -
rpool/var/log/network  logicalused    14.4G  -
```

## DNS

I have an APU2 running HardenedBSD, Unbound, and void-zones-tools. In
similar vein, void-zones-tools gives me the same core functionality of
the PiHole. Since this is a home network, I don't worry about having
redundant DNS servers. I ride solo.

All DNS requests are logged to syslog. I don't log the responses.

I have cron set up to run every night at 01:02 to reload the void
zones rules.

In `/etc/crontab`, I have:

```
2	1	*	*	*	root /usr/local/bin/void-zones-update.sh
```

Unbound is acting is a caching and validating recursive name server. I
enforce DNSSEC. I also use the DoT/DoH canary domain to instruct
devices not to use DoH/DoT. I want all DNS requests for all devices on
my network to use my DNS server.

On the firewall side, I disallow any device except for my DNS server
from performing outbound DNS rquests. I have a transparent redirect
rule to redirect outbound requests to my DNS server.

I apply the same hardening techniques in my DNS server as I do the
syslog server.

## NAS

My NAS is the first ever crowdfunded build server for HardenedBSD.
It's still used primarily for HardenedBSD--to give my laptop more
storage for VMs. My Cross-DSO CFI development VM's backing storage is
on the NAS.

The NAS runs HardenedBSD 13-STABLE. I don't use NFS or SMB/CIFS. I
primarily use iSCSI. I expose ZFS volumes via iSCSI.

Once the iSCSI volume is connected to my laptop, I use geli to
transparently encrypt the volume. Then, I use ZFS on top of geli as
the underlying filesystem.

So, to think of it this way: ZFS -> iSCSI -> geli -> ZFS

That means that the data is fully encrypted on the wire and at rest.
And compromising the NAS still wouldn't reveal the data, even if it's
currently being used. You'd also need to compromise my laptop (which,
to be honest, is 1000x easier than my NAS. Thank you, web browsers.)

Part of this section is to say: seven years later, the very first
HardenedBSD build server is still running strong, serving
HardenedBSD's interests.

## ARM64 Systems

The two SoftIron OverDrive 1000 are a few years old now. One is for
testing HardenedBSD on arm64 and the other acts as my dedicated IRC
system. I also run a jail on that for tt-rss.

These two systems don't see much love, primarily because of how long
it takes to build HardenedBSD on them: five hours. Serious and
performant development arm64 hardware is still lacking. I'd love to be
able to build world in thirty minutes like I can on other amd64
systems.

## HardenedBSD Development Laptop

My primary laptop is the one I use for HardenedBSD development. It's a
2020 Dell Precision 7550. Of course, the laptop runs HardenedBSD on
bare metal. I use i3wm as my window manager, Firefox for my browser.
Sakura is my terminal emulator, tmux my terminal multiplexer.

For virtualization, I use bhyve. I used to run bhyve in a jail, but I
don't anymore. I may go back to that at some point.

For email, I use jailed neomutt. I have one jail for each of my email
accounts: one for HardenedBSD, one for personal email, another for
work email. Each neomutt jail is NATed and uses vnet.

This laptop is treated more of a desktop. My work laptop, a Dell
Precision 7540, is set up the exact same way.

## HardenedBSD Mobility Laptop

I have bunches and bunches of health issues. The health issue I talk
about most is migraines since I get them so often. I occasionally
spend a bit of time in bed or otherwise not at my office desk. My
primary laptop (the aforementioned HardenedBSD Development Laptop)
doesn't do wireless, and even if it did, I'd still need it connected
to the wired interface due to network usage constraints.

Generally, when I'm exhibiting symptoms, I'm still able to work, but
in a more limited capacity. That's where this laptop comes into play.
This laptop (a Thinkpad T410) runs HardenedBSD 13-STABLE. I've set it
up with lagg so that I can transition seamlessly from wired to
wireless without having to worry about terminating any connections.

## Tor-ified Network

I [wrote](https://git.hardenedbsd.org/shawn.webb/articles/-/blob/master/infosec/tor/2017-01-14_torified_home/article.md)
a few years back about how to create a fully Tor-ified network. I use
it for research purposes. Any device that connects to that network
will have all of its network traffic routed through Tor, without that
device even knowing.

The APU2 acting as the Tor-ified network firewall/router connects
directly to one of the ports on the HawkSense firewall. I have that
traffic fully segregated without possibility of hopping onto my
production network.

## Inventory

* HardenedBSD development laptop
* HardenedBSD mobility laptop
* Work laptop, running HardenedBSD
* HardenedBSD NAS
* Several development VMs running on both laptops and the NAS
* HardenedBSD Wireless AP
* Chromebook
* HardenedBSD APU2 acting as work VPN gateway
* HardenedBSD APU2 acting as a test deployment system for ${DAYJOB}
* HardenedBSD APU2 acting as a DNS server
* HardenedBSD APU2 acting as a syslog-ng syslog server
* HardenedBSD APU2 acting as my fully Tor-ified network
* Debian VM for Splunk
  firewall/router
* Two L3 managed switches
* Two SoftIron OverDrive 1000 systems

## TODO

Here are some things I'd like to experiment with:

1. Setting up Unbound on all HardenedBSD systems to support DoT to my
   local DNS server.
1. Set up TLS for all syslog-ng hosts. Start with DNS so that the
   logged queries logged by devices with DoT-enabled devices remain
   encrypted.
1. Figure out if/how to ship Windows Event Logs to syslog.
1. Add a second NIC to the NAS, and use lagg LACP to bond multiple
   interfaces, doubling the effective bandwidth of the NAS.
1. Attempt to set up kerberos/LDAP authentication, preferring to use
   in-base applications only, but fallback to Samba4 if needed.
1. Teach syslog-ng about the sappnd/uappnd file flags (see
   `chflags(1)`).

## Appendix A - Unbound Config

```
server:
	logfile: "unbound.log"
	verbosity: 1
	interface: 0.0.0.0
	interface: ::0
	#logfile: "unbound.log"
	use-syslog: yes
	log-identity: "dns-01.ip6.home.lan_unbound"
	log-queries: yes
	access-control: 192.168.99.0/24 allow
	access-control: 2001:470:e1e1::/48 allow

	###########################
	#### Generic hardening ####
	###########################
	harden-algo-downgrade: yes
	harden-glue: yes
	harden-referral-path: yes
	harden-short-bufsize: yes
	hide-identity: yes
	hide-version: yes
	use-caps-for-id: no
	ignore-cd-flag: yes

	###################################
	#### Validator-based hardening ####
	###################################
	val-clean-additional: yes
	val-permissive-mode: no

	#################################################################
	#### Prevent DNS rebinding attacks by stripping private IPs #####
	#################################################################
	private-address: 10.0.0.0/8
	private-address: 172.16.0.0/12
	private-address: 192.168.0.0/16
	private-address: 169.254.0.0/16
	private-address: fd00::/8
	private-address: fe80::/10
	private-address: ::ffff:0:0/96

	unwanted-reply-threshold: 10000000

	module-config: "validator iterator"
	auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"

include: /var/unbound/local-void.zones

# Disable DoH/DoT
local-zone: "use-application-dns.net." static

# Note: I'm intentionally leaving out the home.lan file.
include: /usr/local/etc/unbound/zones/home.lan
```

## Appendix B - syslog-ng Server-Side Config

```
@version:3.33
@include "scl.conf"

options {
	chain_hostnames(yes);
	flush_lines(0);
	threaded(yes);
	create-dirs(yes);
	dir-perm(0755);
	perm(0644);
};

source src_network {
	network(
		transport("tcp")
		ip("::")
		ip-protocol(6)
	);
	network(
		transport("tcp")
		ip("0.0.0.0")
	);
	network(
		transport("udp")
		ip("::")
		ip-protocol(6)
	);
	network(
		transport("udp")
		ip("0.0.0.0")
	);
};
source src { system();
	     internal(); };

destination messages { file("/var/log/messages"); };
destination security { file("/var/log/security"); };
destination authlog { file("/var/log/auth.log"); };
destination maillog { file("/var/log/maillog"); };
destination lpd-errs { file("/var/log/lpd-errs"); };
destination xferlog { file("/var/log/xferlog"); };
destination cron { file("/var/log/cron"); };
destination debuglog { file("/var/log/debug.log"); };
destination consolelog { file("/var/log/console.log"); };
destination all { file("/var/log/all.log"); };
destination newscrit { file("/var/log/news/news.crit"); };
destination newserr { file("/var/log/news/news.err"); };
destination newsnotice { file("/var/log/news/news.notice"); };
destination slip { file("/var/log/slip.log"); };
destination ppp { file("/var/log/ppp.log"); };
destination console { file("/dev/console"); };
destination allusers { usertty("*"); };

destination network_all {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/all.log");
};
destination network_auth {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/auth.log");
};
destination network_debug {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/debug.log");
};
destination network_err {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/err.log");
};
destination network_warn {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/warn.log");
};
destination network_security {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/security.log");
};
destination network_daemon {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/daemon.log");
};
destination network_user {
	file("/var/log/network/${HOST}/${YEAR}-${MONTH}/user.log");
};

filter f_auth { facility(auth); };
filter f_authpriv { facility(authpriv); };
filter f_not_authpriv { not facility(authpriv); };
filter f_cron { facility(cron); };
filter f_daemon { facility(daemon); };
filter f_ftp { facility(ftp); };
filter f_kern { facility(kern); };
filter f_lpr { facility(lpr); };
filter f_mail { facility(mail); };
filter f_news { facility(news); };
filter f_security { facility(security); };
filter f_user { facility(user); };
filter f_uucp { facility(uucp); };
filter f_local0 { facility(local0); };
filter f_local1 { facility(local1); };
filter f_local2 { facility(local2); };
filter f_local3 { facility(local3); };
filter f_local4 { facility(local4); };
filter f_local5 { facility(local5); };
filter f_local6 { facility(local6); };
filter f_local7 { facility(local7); };

filter f_emerg { level(emerg); };
filter f_alert { level(alert..emerg); };
filter f_crit { level(crit..emerg); };
filter f_err { level(err..emerg); };
filter f_warning { level(warning..emerg); };
filter f_notice { level(notice..emerg); };
filter f_info { level(info..emerg); };
filter f_debug { level(debug..emerg); };
filter f_is_debug { level(debug); };

filter f_ppp { program("ppp"); };
filter f_slip { program("startslip"); };

log { source(src); filter(f_err); destination(console); };
log { source(src); filter(f_kern); filter(f_warning); destination(console); };
log { source(src); filter(f_auth); filter(f_notice); destination(console); };
log { source(src); filter(f_mail); filter(f_crit); destination(console); };
log { source(src); filter(f_notice); filter(f_not_authpriv); destination(messages); };
log { source(src); filter(f_kern); filter(f_debug); destination(messages); };
log { source(src); filter(f_lpr); filter(f_info); destination(messages); };
log { source(src); filter(f_mail); filter(f_crit); destination(messages); };
log { source(src); filter(f_news); filter(f_err); destination(messages); };
log { source(src); filter(f_security); destination(security); };
log { source(src); filter(f_auth); filter(f_info); destination(authlog); };
log { source(src); filter(f_authpriv); filter(f_info); destination(authlog); };
log { source(src); filter(f_mail); filter(f_info); destination(maillog); };
log { source(src); filter(f_lpr); filter(f_info); destination(lpd-errs); };
log { source(src); filter(f_ftp); filter(f_info); destination(xferlog); };
log { source(src); filter(f_cron); destination(cron); };
log { source(src); filter(f_is_debug); destination(debuglog); };
log { source(src); filter(f_emerg); destination(allusers); };
log { source(src); filter(f_slip); destination(slip); };
log { source(src); filter(f_ppp); destination(ppp); };

log {
	source(src_network);
	destination(network_all);
};

log {
	source(src_network);
	filter(f_auth);
	destination(network_auth);
};

log {
	source(src_network);
	filter(f_daemon);
	destination(network_daemon);
};

log {
	source(src_network);
	filter(f_debug);
	destination(network_debug);
};

log {
	source(src_network);
	filter(f_err);
	destination(network_err);
};

log {
	source(src_network);
	filter(f_security);
	destination(network_security);
};

log {
	source(src_network);
	filter(f_user);
	destination(network_user);
};

log {
	source(src_network);
	filter(f_warning);
	destination(network_warn);
};
```

## Appendix C - syslog-ng Client-Side Configuration

```
@version:3.33
@include "scl.conf"

options { chain_hostnames(off); flush_lines(0); threaded(yes); };

source src { system();
	     udp(); internal(); };

destination messages { file("/var/log/messages"); };
destination security { file("/var/log/security"); };
destination authlog { file("/var/log/auth.log"); };
destination maillog { file("/var/log/maillog"); };
destination lpd-errs { file("/var/log/lpd-errs"); };
destination xferlog { file("/var/log/xferlog"); };
destination cron { file("/var/log/cron"); };
destination debuglog { file("/var/log/debug.log"); };
destination consolelog { file("/var/log/console.log"); };
destination all { file("/var/log/all.log"); };
destination newscrit { file("/var/log/news/news.crit"); };
destination newserr { file("/var/log/news/news.err"); };
destination newsnotice { file("/var/log/news/news.notice"); };
destination slip { file("/var/log/slip.log"); };
destination ppp { file("/var/log/ppp.log"); };
destination console { file("/dev/console"); };
destination allusers { usertty("*"); };

destination syslog_01 {
	network(
		"syslog-01.ip6.home.lan"
		transport(tcp)
		ip-protocol(6)
	);
};

filter f_auth { facility(auth); };
filter f_authpriv { facility(authpriv); };
filter f_not_authpriv { not facility(authpriv); };
filter f_cron { facility(cron); };
filter f_daemon { facility(daemon); };
filter f_ftp { facility(ftp); };
filter f_kern { facility(kern); };
filter f_lpr { facility(lpr); };
filter f_mail { facility(mail); };
filter f_news { facility(news); };
filter f_security { facility(security); };
filter f_user { facility(user); };
filter f_uucp { facility(uucp); };
filter f_local0 { facility(local0); };
filter f_local1 { facility(local1); };
filter f_local2 { facility(local2); };
filter f_local3 { facility(local3); };
filter f_local4 { facility(local4); };
filter f_local5 { facility(local5); };
filter f_local6 { facility(local6); };
filter f_local7 { facility(local7); };

filter f_emerg { level(emerg); };
filter f_alert { level(alert..emerg); };
filter f_crit { level(crit..emerg); };
filter f_err { level(err..emerg); };
filter f_warning { level(warning..emerg); };
filter f_notice { level(notice..emerg); };
filter f_info { level(info..emerg); };
filter f_debug { level(debug..emerg); };
filter f_is_debug { level(debug); };

filter f_ppp { program("ppp"); };
filter f_slip { program("startslip"); };

filter f_hbsdmon { program("hbsdmon"); };

log { source(src); filter(f_err); destination(console); };
log { source(src); filter(f_kern); filter(f_warning); destination(console); };
log { source(src); filter(f_auth); filter(f_notice); destination(console); };
log { source(src); filter(f_mail); filter(f_crit); destination(console); };
log { source(src); filter(f_notice); filter(f_not_authpriv); destination(messages); };
log { source(src); filter(f_kern); filter(f_debug); destination(messages); };
log { source(src); filter(f_lpr); filter(f_info); destination(messages); };
log { source(src); filter(f_mail); filter(f_crit); destination(messages); };
log { source(src); filter(f_news); filter(f_err); destination(messages); };
log { source(src); filter(f_security); destination(security); };
log { source(src); filter(f_auth); filter(f_info); destination(authlog); };
log { source(src); filter(f_authpriv); filter(f_info); destination(authlog); };
log { source(src); filter(f_mail); filter(f_info); destination(maillog); };
log { source(src); filter(f_lpr); filter(f_info); destination(lpd-errs); };
log { source(src); filter(f_ftp); filter(f_info); destination(xferlog); };
log { source(src); filter(f_cron); destination(cron); };
log { source(src); filter(f_is_debug); destination(debuglog); };
log { source(src); filter(f_emerg); destination(allusers); };
log { source(src); filter(f_slip); destination(slip); };
log { source(src); filter(f_ppp); destination(ppp); };

log { source(src); destination(syslog_01); };
```

## Appendix D - Mobility Laptop lagg Config

```
ifconfig_em0="ether mac_of_wlan0 up"
wlans_ath0="wlan0"
ifconfig_wlan0="WPA"
ifconfig_lagg0="up laggproto failover laggport em0 laggport wlan0 DHCP"
ifconfig_lagg0_ipv6="inet6 accept_rtadv"
```
