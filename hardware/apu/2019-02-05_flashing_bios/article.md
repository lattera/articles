# Flashing the BIOS on the PC Engines APU4c4

I absolutely love the [PC Engines](https://pcengines.ch/) APU devices.
I use them for testing HardenedBSD experimental features in more
constrained 64-bit environments and firewalls.

Their USB and mSATA ports have a few quirks, and I bumped up against a
major quirk that required flashing a different BIOS as a workaround.
This article details the hacky way in which I went about doing that.
The reason for this hacky way is because the upgrade of OPNsense from
18.7.10 to 19.1 failed partway through, leaving me with an unbootable
system.

What prompted this article is that something in either the CAM or GEOM
layer in FreeBSD 11.2 caused the mSATA to hang, preventing file
writes. OPNsense 18.7 uses FreeBSD 11.1 whereas the recently-released
OPNsense 19.1 uses HardenedBSD 11.2 (based on FreeBSD 11.2). I reached
out to PC Engines directly, and they let me know that the issue is a
known BIOS issue. Flashing the "legacy" BIOS series would provide me
with a working system.

It also just so happens that a new "legacy" BIOS version was just
released which turns on ECC mode for the RAM. So, I get a working
OPNsense install *AND* ECC RAM! I'll have one bird for dinner, the
other for dessert.

Though I'm using an APU4, these instructions should work for the other
APU devices. The BIOS ROM download URLs should be changed to reflect
the device you're targeting along with the BIOS version you wish to
deploy.

SPECIAL NOTE: There be dragons! I'm primarily writing this article to
document the procedure for my own purposes. My memory tends to be
pretty faulty these days. So, if something goes wrong, please do not
hold me responsible. You're the one at the keyboard. ;)

VERY SPECIAL NOTE: We'll use the mSATA drive for swap space, just in
case. Should the swap space be used, it will destroy what ever is on
the disk.

This post also assumes you know your way around a BSD system. You'll
need to modify some commands to accomodate your setup.

At the time of this writing (11 Feb 2019), the BIOS releases can be
found on the [PC Engines GitHub page](https://pcengines.github.io/).

**Update 11 Feb 2019**: Multiple people are reporting success running
firmware v4.9.0.1. So, if you don't want to run the legacy build, you
might give v4.9.0.1 a try.

## Well, get on with it already!

So, you'll need a few things before we get started. You'll need to
download a HardenedBSD installation image. Use the memstick image,
since we're going to boot off of a USB thumbdrive.

The latest build of 12-STABLE/amd64 can be found
[here](https://installer.hardenedbsd.org/hardened_12_stable_master-LAST/)

Write that to your thumbdrive:

```
# dd if=HardenedBSD-12-STABLE-v1200058.2-amd64-mini-memstick.img \
    of=/dev/da0 bs=64k status=progress
```

Plug the memstick into your APU. Attach your serial cable to your
system, and connect to it using `cu(1)`:

```
# cu -s 115200 -l /dev/cuaU0
```

When prompted, press F10 and boot from USB. You will see the
HardenedBSD bootloader screen pop up. Select the third option, "Escape
to Loader Prompt".

Type in the following commands for serial console access:

```
set comconsole_speed="115200"
set console="comconsole"
boot
```

You'll be prompted to select the terminal type. In my case, I enter
"xterm". Next, you'll be selected with options to install HardenedBSD.
Select LiveCD mode instead and login with the password-less root
account.

We're going to set up swap first, in preparation for a ramdrive that
will hold a chroot filesystem. We'll create a 3GB ramdisk that will
hold the live environment. We'll format the ramdisk as UFS, mount it,
and create two directories; one to hold a downloaded binary update and
the other to hold the chroot filesystem. Following that, we'll set up
networking.

```
# gpart destroy -F ada0
# gpart create -s gpt ada0
# gpart add -t freebsd-swap -s 2g ada0
# swapon /dev/ada0p1
# mdconfig -a -s 3g
# newfs md0
# mount /dev/md0 /mnt
# mkdir -p /mnt/update/../root
# dhclient igb0
```

HardenedBSD created a binary update utility for base, similar in scope
to `freebsd-update(8)`, called `hbsd-update(8)`. We'll use that to
populate `/mnt/root`. We'll then copy over `/etc/resolv.conf` so that
DNS works within the chroot. Finally, we'll mount `devfs(5)` in the
chroot.

```
# hbsd-update -VdnU -t /mnt/update -r /mnt/root
# cp /etc/resolv.conf /mnt/root/etc/
# mount -t devfs devfs /mnt/root/dev
```

We're now ready to dive into our chroot environment. We'll install the
`flashrom` and `ca_root_nss` packages, download BIOS v4.0.23, and
flash it.

**_VERY SPECIAL EXTRA CRUCIAL NOTE_**: Make sure you're downloading the
right BIOS for your system! Do NOT blame me if you simply copy these
next commands verbatim without first ensuring they apply to your
system.

```
# chroot /mnt/root
# pkg install -y flashrom ca_root_nss
# fetch http://pcengines.ch/file/apu4_v4.0.23.rom.tar.gz
# tar -xf apu4_v4.0.23.rom.tar.gz
# flashrom -p internal:boardmismatch=force -w apu4_v4.0.23.rom
```

That is it! You've now flashed the "legacy" BIOS on your APU4! Go
ahead and shutdown the system with `shutdown -p now` and go about your
merry way! I know I'll be enjoying my new OPNsense 19.1 installation.
