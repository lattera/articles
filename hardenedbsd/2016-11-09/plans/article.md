My 2017 Plans for HardenedBSD
=============================

A Look Back at 2016
-------------------

2016 is coming to a close. We weren't able to accomplish all the
goals in our roadmap for 2016, but we made a lot of major successes.

Let's first take a look at what we've done:

1. All of base and ports is compiled as Position-Independent
Executables (PIEs) along with full RELRO (note: there are some
exceptions).
1. I started hardening some syscalls and sysctl nodes. You'll now
notice that the ```gpart``` command must run as root because of that.
Jailed environments and unprivileged users now cannot see which
kernel modules are loaded and root cannot see the base address of
kernel modules.
1. Documentation is now a key priority. Work has started on the
HardenedBSD Handbook. We have a long way to go, but the foundation
has been laid.
1. Work on cleaning up our ```PaX SEGVGUARD``` implementation has
started. We're eventually going to take a whole different approach.
Though the current implementation is useful, we haven't guaranteed
its stability.
1. Intel SMAP/SMEP support working in a private feature branch.
1. LibreSSL imported into HardenedBSD base and made the default in
12-CURRENT.
1. ```hbsd-update``` continues receiving more features and can be
considered production-ready. Though there's still more work to do,
it is feature complete for the vast majority of use cases.
1. New, self-hosted package building server.
1. Port HardenedBSD ASLR and SEGVGUARD to OPNsense, complete with
PIE base/ports. Every single OPNsense install has ASLR enabled.
1. Help FreeBSD with the RPI3 efforts. Test and research clang
3.9.0 and ld.lld on the RPI3. HardenedBSD works flawlessly on the
RPI3, showing the strength of HardenedBSD's portability and
robustness.

For just three developers (Oliver Pinter, Bernard Spil, and myself)
doing this in our spare time, we've come a long way in 2016. I'm
extremely excited for 2017.

2017 Goals
----------

This list may be incomplete and is definitely not in any particular
order. Without further ado:

1. Finish documenting everything we've done to this point in the
HardenedBSD Handbook.
1. Maybe start on a Spanish translation of the HardenedBSD
Handbook (looking at you, @SoloBSD).
1. Get SafeStack working in base. ASLR and W^X are prerequisites for
SafeStack, so it's a good thing we have those.
   1. Investigate the patch floating around that allows CPI/SafeStack
      to be enabled for shared libraries.
1. Get our first release out the door.
1. Port over PaX NOEXEC (aka, W^X) to OPNsense.
1. Revamp secadm to make it use a more efficient and elegant
userlaned<->kernel model.
1. Import secadm into base.
1. When the time is right, investigate packaged base. I lean more
heavily towards ```hbsd-update```, but I'm open to investigating
packaged base.
1. Help FreeBSD with clang 3.9 efforts. clang 3.9 has a few
regressions, most notably with supporting PIEs. Since PIE is required
for ASLR to be fully applied to a process' address space, it's
crucial we don't regress.
1. Finish revamping ```PaX SEGVGUARD```.
1. Harden more syscalls and sysctls.
1. Bring more grsecurity features over to HardenedBSD
   * Especially desired: RBAC
