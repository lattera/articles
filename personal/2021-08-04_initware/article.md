# My Thoughts on InitWare

[InitWare](https://github.com/InitWare/InitWare) is a minimal port of
certain SystemD componenets, with a goal to run on the BSDs. Being a
port, it uses the GPL. This article details my thoughts about the
project and about its licensing, and what I see may be in the future
for this type of work.

This work would probably be a good starting point for a developer to
create documentation that would enable a clean-room reimplementation.

The problem I see is that as more and more Linux apps depend on
SystemD, they'll become harder to port to other POSIX operating
systems.

I would welcome a BSD-licensed compat layer that implements only the
most basic requirements to get modern apps that require SystemD to
run. This particular project is a direct derivative of SystemD, so
it's naturally under the GPL. At least three BSDs, FreeBSD,
HardenedBSD, and OpenBSD, have an aversion to introducing new GPL code
in the base OS (FreeBSD and HardenedBSD especially).

An independent, BSD licensed, reimplementation of SystemD (or simply a
compat layer) would make keeping applications portable easier.
Licensing it under the BSD 2-clause license would help increase
adoption.

If someone were to take this repo and convert it to clean-room
documentation, someone could then re-implement these base SystemD
components with the BSD license.

Now here's the "unpopular opinion puffer meme": that we're in this
situation means that Linux developers are implementing a form of open
source vendor lock-in. With Docker, k8s, SystemD, etc, Linux is
enticing developers to write code that only runs on Linux--that is,
locks users into Linux.

It's because of this open source vendor lock-in strategy that we in
the BSDs need some level of compatibility. Though FreeBSD has had a
notion of containerization for over two decades, Linux's Docker is way
more popular. SystemD is wholly incompatible with any of the init
systems in the BSDs. Yet some projects only support SystemD
integration.

I'd like to think that's because the Linux development community only
knows about Linux, and thus are wholly ignorant of the BSDs. And
indeed I've seen some cases of that. But, I think there's a lot more
developers who know the BSDs exist, and that they differ from Linux in
some pretty drastic ways.

But I digress.

Getting back to the subject at hand: InitWare. I think that this is a
good first step to figure out "okay, if we were to do this, what do we
need to do it?" I believe that this initial work will help pave the
way for a clean-room reimplementation (or clean-room compat layer)
that is BSD licensed--something that we absolutely need.
