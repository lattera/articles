About Meltdown and Spectre
==========================

Oh, no! Not yet another blog article! This article expresses my view
on the Meltdown and Spectre vulnerabilities, with a focus on FreeBSD
and HardenedBSD. Most other articles focus on Windows, Linux, and
macOS. Since there are plenty of other articles diving into the gory
details, I'll skip those in this article.

While we see a lot of speculation and rumors about Meltdown, it's
important to keep a level head. Meltdown is primarily a local attack.
Building a ROP chain for remote exploitation of Meltdown would likely
be extremely difficult. We are seeing Spectre proofs of concept
written in javascript.

Meltdown is a read-only attack. It is not possible to gain write
access in the kernel with Meltdown only. However, I would think it is
possible to gain write access by combining Meltdown with Row Hammer on
systems without ECC RAM.

The Meltdown vulnerability was disclosed to FreeBSD late in December.
HardenedBSD and OpenBSD received no advanced notification. Some
hardware and software vendors were notified months ago. The embargo is
technically still applied and the official PoC hasn't been released.

FreeBSD is working on a mitigation. We don't know how they plan to
approach the mitigation. We don't know if they'll issue a Call For
Testing (CFT) first, or if they will commit to HEAD. In either case,
HardenedBSD will thoroughly test and integrate their patch. It's
likely that the patch will cause merge conflicts, so we'll need to
work through that.

llvm is also working on at least one compiler-based mitigation
approach, called [retpoline](https://reviews.llvm.org/D41723). Their
plan is to introduce retpoline as an optional feature in 6.0.0 with
backports to older releases. The llvm project recommends compiling
retpoline-enabled applications to use immediate binding (-z now) in
order to make the retpoline PLT code smaller. HardenedBSD has had
full RELRO enabled (RELRO + BIND_NOW) for base and ports, with only
a few applications opting out of it, for almost two years. retpoline
also requires use of lld, which is the default linker in HardenedBSD
on both amd64 and arm64.

Once llvm's patch is committed, I will create a feature branch in
HardenedBSD's playground repo to test it with world and kernel. If I
succeed in enabling it in base, I will look into enabling it in ports.
At least one experimental package build (also known as an "exp-run")
will be performed. Doing an exp-run will also give us real-world
metrics on any potential overhead retpoline will give us.

If retpoline works out, then we in HardenedBSD will have two
mitigations against Spectre and/or Meltdown: the mitigation from
FreeBSD and the mitigation from llvm. retpoline will move from the
playground repo to our main repo.
