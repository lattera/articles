Sometime recently (I'm not sure when), Verizon enabled IPv6 support for
residential FiOS customers. Verizon will give you a /56 prefix via DHCPv6.

At home, I run a custom build of OPNsense, based on HardenedBSD. My home
firewall is a Protectli FW6C. I use nearly all six ports on the Protectli
appliance, each with its own /64 allocation. The networks are for different
purposes.

I use Hurricane Electric's Tunnel Broker service to get IPv6 to my home. The
problem with this is that Netflix blocks Tunnel Broker. So I have a special
IPv4-only network so that I can watch Netflix on select devices. When I learned
about Verizon having deployed native IPv6 I immediately thought "great! perhaps
now I can have both my cake and eat it, too!" Turns out, I was half wrong.

In a test run, I rolled out Verizon's nativce IPv6 to the IPv4-only network. It
went well. No hiccups. But there's also nothing critical on that particular
network. If something went wrong, I likely wouldn't notice it (again--it's
primarily for Netflix.) The WAN interface is set to use DHCPv6, but only
requesting a prefix allocation. The WAN interface itself does not have a
world-routable IPv6 address.

So I decided to revamp my firewall, switching from an older build of a
proprietary fork of OPNsense (still based on HardenedBSD, but a firmware I'm
working on at ${DAYJOB}) to my latest open source build of
OPNsense + HardenedBSD. I wanted to see if I could ditch Tunnel Broker entirely
in favor of Verizon's native IPv6 offering.

As part of that revamp, I would make an attempt at rolling Verizon's native IPv6
out to my main network, where my ad-blocking DNS server lives (more on that
later). I set the LAN interface's IPv6 settings to track the WAN interface,
using a /64 prefix so that I can use SLAAC.

I saw that my LAN network got its /64 allocation. Prior to this revamp, my DNS
server had a static IPv6 address. However, since I'm now using a dynamic IPv6
allocation, I need to use SLAAC on the DNS server. That's fine. Instead of
referencing the RFC3041 address (a random address), I can just reference the
SLAAC address in my IPv6 router advertisement DNS entries. Only the DNS server
is allowed to send outbound DNS requests. No other systems are allowed to go
outbound--they all *MUST* use my DNS server.

That was the start of my problems. Whenever the firewall's LAN configuration
changes, or whenever Suricata reloads its rules (more on that later), I get a
whole new /56 prefix from Verizon, completely ditching the old /56. Hopefully
the problem becomes clear: the configuration I just set up became invalid
instantly. The DNS server no longer has the IPv6 SLAAC address it used to have.
Neither do any of my other devices. Yet the IPv6 router advertisement still
references the (now-deleted) original SLAAC IPv6 address.

When Suricata is set in IPS mode, it uses Netmap to effectively take control of
the NIC. The kernel passes packets directly to/from the NIC to Suricata,
skipping the rest of the networking stack. So when Suricata reloads its rules
(or is restarted), the NIC's state is changed. This state change invalidates the
previous Verizon IPv6 allocation.

Whenever the firewall reboots, Verizon invalidates the previous allocation and
creates a new one. With my IPv4-only network, I didn't catch this behavior.
Everything just worked when I deployed Verizon's native IPv6 there.

So since I don't use the ISP's DNS servers and instead run my own, I need some
form of determinism in my network--generally either via static addresses or via
the interface MAC-based SLAAC address. Removing that determinism wreaked havoc
on my network. Any slight change can cause a disturbance in the force.

I made a somewhat silly (incorrect) assumption that Verizon would have kept me
on the same IPv6 prefix allocation for a longer period of time--similar to how
my IPv4 address hasn't changed in years.

So, to recap:

1. Verizon native IPv6 is okay if you're just a typical IoT consumer.
1. Verizon native IPv6 is not okay if you need deterministic IPv6 behavior.

Things that can cause the current IPv6 prefix allocation to change:

1. Reloading Suricata's rules, when Suricata is in IPS mode.
1. Rebooting the firewall appliance.
1. Making any kind of change on the firewall appliance that causes the LAN
   interface to change states.
1. Perhaps anything at Verizon's own discretion?
