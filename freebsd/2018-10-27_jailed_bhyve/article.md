Jailing The bhyve Hypervisor
============================

As FreeBSD nears the final 12.0-RELEASE release engineering cycles,
I'd like to take a moment to document a cool new feature coming in 12:
jailed bhyve.

You may notice that I use HardenedBSD instead of FreeBSD in this
article. There is no functional difference in bhyve on HardenedBSD
versus bhyve on FreeBSD. The only difference between HardenedBSD and
FreeBSD is the aditional security offered by HardenedBSD.

A Gentle History Lesson
--------------

At work in my spare time, I'm helping develop a malware lab. Due to
the nature of the beast, we would like to use bhyve on HardenedBSD.
Starting with HardenedBSD 12, non-Cross-DSO CFI, SafeStack, Capsicum,
ASLR, and strict W^X are all applied to bhyve, making it an extremely
hardened hypervisor.

So, the work to support jailed bhyve is sponsored by both HardenedBSD
and my employer. We've also jointly worked on other bhyve hardening
features, like protecting the VM's address space using guard pages
(`mmap(.., MAP_GUARD, ...)`). Further work is being done in a project
called "malhyve." Only those modifications to bhyve/malhyve that make
sense to upstream will be upstreamed.

Initial Setup
-------------

We will not go through the process of creating the jail's filesystem.
That process is documented in the [FreeBSD
Handbook](https://www.freebsd.org/handbook). For UEFI guests, you will
need to install the `uefi-edk2-bhyve` package inside the jail.

I network these jails with traditional jail networking. I have tested
vnet jails with this setup, and that works fine, too. However, there
is no real need to hook the jail up to any network so long as bhyve
can access the tap device. In some cases, the VM might not need
networking, in which case you can use a network-less VM in a
network-less jail.

By default, access to the kernel side of bhyve is disabled within
jails. We need to set `allow.vmm` in our `jail.conf` entry for the
bhyve jail.

We will use the following in our jail, so we will need to set up
`devfs(8)` rules for them:

1. A ZFS volume
1. A null-modem device (`nmdm(4)`)
1. UEFI GOP (no devfs rule, but IP assigned to the jail)
1. A tap device

In my `/etc/devfs.rules` file, I have:

```
[devfs_rules_bhyve_jail=25]
add include $devfsrules_jail
add path vmm unhide
add path vmm/* unhide
add path tap* unhide
add path zvol/tank/bhyve/* unhide
add path nmdm* unhide
```

Notice that this ruleset is assigned index 25. That number is
flexible. If you have another ruleset with the same index, please
choose a different index for this article. Keep in mind that you will
need to adjust the use of the index later on in this article should
you change it.

Now let's set up our `/etc/jail.conf` file. We'll reference the devfs
rule we set up above.

```
exec.start = "/bin/sh /etc/rc";
exec.stop = "/bin/sh /etc/rc.shutdown";
exec.clean;
mount.devfs;

path = "/usr/jails/$name";
host.hostname = "$name";

bhyve-01 {
    devfs_ruleset = 25;
    ip4.addr = 192.168.1.2;
    allow.vmm;
    persist;
}
```

Let's set up `/etc/rc.conf` with the right parameters. Again, this
next part contains variables and settings that may conflict with
existing setups. You'll need to modify this to fit your particular
setup.

```
cloned_interfaces="bridge0 tap0"
ifconfig_bridge0="addm em0 addm tap0 up"
jail_enable="YES"
jail_parallel_start="YES"
```

It's at this point that I would reboot the system. The jail we just
created, `bhyve-01`, will be started at boot time.

You should now be able to run bhyve. I use the
`/usr/share/examples/bhyve/vmrun.sh` script included in
FreeBSD/HardenedBSD base.

ssh or jexec into the jail before running this:

```
# sh /usr/share/examples/bhyve/vmrun.sh \
    -c 4 \
    -m 16g \
    -t tap0 \
    -C /dev/nmdm-laptop-dev-03-A \
    -d /dev/zvol/tank/bhyve/laptop-dev-03/disk-01 \
    -E \
    -P 5901 \
    laptop-dev-03
```

Conclusion
----------

The bhyve hypervisor works great within a jail. When combined with
HardenedBSD, bhyve is extremely hardened:

1. PaX ASLR is fully applied due to compilation as a
   Position-Independent Executable (HardenedBSD enhancement)
1. PaX NOEXEC is fully applied (strict W^X) (HardenedBSD enhancement)
1. Non-Cross-DSO CFI is fully applied (HardenedBSD enhancement)
1. Full RELRO (RELRO + BIND_NOW) is fully applied (HardenedBSD
   enhancement)
1. SafeStack is applied to the application (HardenedBSD enhancement)
1. Jailed (FreeBSD feature written by HardenedBSD)
1. Virtual memory protected with guard pages (FreeBSD feature written
   by HardenedBSD)
1. Capsicum is fully applied (FreeBSD feature)

Bad guys are going to have a hard time breaking out of the userland
components of bhyve on HardenedBSD. :)
