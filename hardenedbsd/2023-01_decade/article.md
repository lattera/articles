# A Decade of HardenedBSD

This year, HardenedBSD's codebase will turn a decade old. This article
provides a retrospective on ten years of hard, rewarding work along with some
personal reflections.

## Prologue

My introduction to FreeBSD was back in 2000, right around the same time as the
FreeBSD 4.0 release. I was a teenager back then, thirsty for knowledge. As a
misfit in the real world, I found refuge in online hacker communities. I
stumbled across four communities that provided the foundation for the rest of
my life: Hack3r, SoldierX, Pull The Plug (later renamed to Over The Wire), and
Netric.

Members from these communities taught me, selflessly sharing their wisdom with
me. Of course, hijinks ensued, and I learned many lessons the hard way. Those
lessons proved critical in my understanding of offensive security.

I owe my life to these communities. The many opportunities I've been given in
life can be directly attributed to them.

## The Beginning

FreeBSD's security posture had been focused more on the policy side: MAC/DAC
frameworks, jails, etc. Back in 2013, the only exploit mitigation FreeBSD had
was SSP.

Exploits against vulnerable applications could be, and were, written with
pre-calculated addresses. The exploit payloads could be reused en masse. The gap
between exploit mitigations common to the rest of the world and FreeBSD was
widening, and I figured I would take a stab at implementing some.

Having done a lot of ELF research the prior decade, coming up with interesting
post-exploitation techniques revolving around ELF and ptrace--culminating in my
libhijack project--I figured ASLR was a good starting point.

I wanted to visualize in my head how ASLR would affect tools like libhijack,
which had originally used hardcoded addresses to find in-process ELF headers.

I had been following Brad Spengler's and PaX Team's work with grsecurity/pax,
knowing how robust their implementation has been over the years. I had published
a blog article detailing my goals for the next year, with one goal being to
implement ASLR.

Unbeknownst to me, another hacker in Hungary, Oliver Pinter, had already started
work on a clean-room reimplementation of PaX's ASLR implementation. He reached
out to me and we started collaborating.

Thus HardenedBSD was born.

## That ASLR Story

This was the first large kernel development work I had ever done, so I had a lot
to learn. Oliver and I worked in separate personal repos in GitHub for a while
until Oliver created the HardenedBSD repo to unify our work. Our intent was to
do initial development in the HardenedBSD repo with the goal of upstreaming to
FreeBSD. History would take us on a different path.

As we worked on our ASLR implementation, we updated our submission in FreeBSD's
patch review system to solicit feedback from the FreeBSD project's official
development team. With this being our first real foray into FreeBSD kernel
development, we learned a lot through this review process.

After two years of the development and review process, it was apparent that we
differed with FreeBSD on the technical merits of our patch. Our work was not to
be upstreamed due to a variety of reasons, some technical, some political. I
eventually became overwhelmed and burned out and opted to abruptly discontinue
the attempt at upstreaming our work.

We got to a point in 2015 where we could consider our implementation as
complete, and moved on to other exploit mitigations.

## Growing Up

We continued on with a few other PaX features, most notably PaX NOEXEC and PaX
SEGVGUARD. The SEGVGUARD implementation was done by an outside contributor who
had interest in the work Oliver and I were doing.

One crucial decision we made early on was to provide a method of toggling
exploit mitigations on both a per-application and per-jail basis. I have a
distaste for modifying ELF objects, tagging them with exploit mitigation
settings. Microsoft showed us how flawed that path has been and I didn't want to
repeat history.

Oliver and I both came up with two different approaches. Oliver's was based on
using filesystem extended attributes and my approach was based on (ab)using the
MAC framework in FreeBSD. We both figured that the fsextattr approach is
preferred over the MAC approach, but not all filesystems support extended
attributes.

We integrated both the SafeStack and CFI implementations in llvm across the base
OS early on, which required us to switch to a complete llvm compiler toolchain.

We experimented with LibreSSL in base. That experiment showed us that the world
is not ready to rid itself of software monocultures. We've had contributions
from quite a number of folks. Recently, Loic and MrUNIX have really done a lot
to contribute towards the quality of our ports tree and provide a number of
various hardening bits in the base OS.

## New Job, Expansion, And The Internship

In 2015, I switched employers from Cisco Talos (formerly Sourcefire VRT) to G2,
Inc. I fell in love with the work there. It was the first job in which I could
see a tangible human impact of infosec. The relationship between HardenedBSD and
G2 was incredibly symbiotic in nature. We used HardenedBSD in various ways to
support efforts in national and international security endeavors.

In 2018, I was given the opportunity to mentor two interns. I feel like those
two gals taught me a lot more than I taught them. If you draw a venn diagram
with two circles, one focusing on human rights and geo-, cultural-, and
socio-political issues and the other focusing on infosec, we navigated the nexus
between those two circles.

We saw first-hand the correlation between propaganda, misinformation,
disinformation, censorship, and surveillance campaigns and the propagation of
malware and, further, its tangible impact on human life.

I literally fell in love with G2, feeling married to the work.

That internship taught me how crucial providing unique access to
security-focused technologies can have a direct impact on human rights and life.
In 2020, HardenedBSD shifted its focus solely from providing the BSD community
with a clean-room reimplementation of the publicly documented bits of grsecurity
to providing a hardened ecosystem with unique points of access to help further
human rights endeavors globally.

## My Personal Struggles

My whole life, I've lived with treatment-resistant depression and bipolar.
Shortly after the internship ended, my employer was acquired by "the nation's
largest military shipbuilding company."

It seemed that nearly overnight, the we shifted from a company specializing in
what I like to call "peacesful offensive" solutions to having to work for a
large corporation that profits from murder.

I felt divorced from my work. The passion that I held dear no longer existed.
Along with familial and relationship issues, my life had come into turmoil. I
spiraled downward from 2018 to 2020, very quite literally only barely surviving.

Due to his own shift in priorities, Oliver amicably resigned from the project.
He wanted to focus his attention elsewhere and I was (and still am) totally
supportive of that decision. I will admit, though, that it took aother hit to my
mental health decline. I felt like I was carrying the torch alone. I recognize
now, however, that I was far from alone.

I'm still healing from the trauma, the heartache, and the pain from those two
years. I'm doing so much better, especially as I utilize positive coping
mechanisms in my recovery. I hope never to go through that experience again.

## The Present Day

In early 2020, I knew that as part of my healing, I needed to find new
employment. I joined on with BlackhawkNest in May of that year. I'm grateful to
them for trusting in me and supporting me through this journey.

Through my work there, we were able to integrate the company's technology into a
proprietary fork of OPNsense that we based on HardenedBSD. A number of features
in HardenedBSD from 2020 and on came from work supporting that endeavor.

Overall, I enjoyed working for BlackhawkNest. I learned a lot in my
two-and-a-half years there. I especially learned that my strengths and passions
lie in the grunt work: finding unique solutions to challenging technical
problems. I took on a hybrid role as Senior Security Engineer and Project
Manager, realizing that I'm really not a good fit for the latter.

Managing an open source project volunteer project like HardenedBSD differs
greatly than project management in a business context. I'm decent in the former,
but horrid in the latter.

In the end, BlackhawkNest had to make a difficult decision in this post-pandemic
world. With funding being tight, I found myself needing to find new employment.

Over the past ten years, we've implemented quite a few exploit mitigations and
security hardening mechanisms. We upstreamed a number of those mechanisms. I'm
proud to have upstreamed support for jailing bhyve. HardenedBSD has evolved to
have a life of its own. The community has really supported the project--support
for which I'm incredibly grateful.

With HardenedBSD's development and build infrastructure being closely tied to my
employer, HardenedBSD has drastically scaled back. While we're no longer able to
provide regular OS builds, updates, or packages, we're looking to rebuild and
re-evolve.

Both me and the project has seen its struggles over the years, and the project
itself showing signs of struggle, the future still remains bright. I'm here to
stay. The project lives on, even through we've temporarily scaled back. We will
survive and thrive. The infrastructure will come alive again in due time.

I look forward to the next decade of HardenedBSD. I would love to see CHERI,
Capsicum, and (forward edge and backward edge) CFI tightly integrated together.

### Friends Made Along The Way

A lot of folks have touched my life throughout the past decade. I had a blast
working with the OPNsense project, helping them adopt HardenedBSD. Early on,
SoldierX provided some hardware and did a lot of advocacy for the project.

Emerald Onion is doing some really cool things with Tor. They continuously
inspire me.

Everyone on The HardenedBSD Foundation Board of Directors leads and guides me to
new paths, ones which I never knew existed.

I have tremendous respect for some in the FreeBSD project and community. Namely,
Kyle Evans, Ed Maste, John-Mark Gurney, Eric McCorkle, Michael Shirk, and the
rest of the CharmBUG crew. I'm sure there's quite a number of others.

Eva Winterschon has selflessly contributed an amazing amount of infrastructure
to the project, helping us scale to the level we did. My recent advancements in
Cross-DSO CFI integration were done on hardware she donated to the project.
