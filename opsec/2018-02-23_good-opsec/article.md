A Beginner's Guide To OPSEC
===========================

In this article, I'll talk about maintaining good OPerational SECurity
(OPSEC) practices. Practicing good OPSEC requires diligence and care.
You will probably make mistakes while learning it and putting it into
practice. That's totally okay. Just make sure that whatever you're
doing isn't too sensitive in the beginning and learn from your
mistakes.

Please note that this article is actively and heavily being worked on.
Do not consider this article as complete or even fully correct. If you
spot an issue or if there's something you'd like to add, please let me
know. The goal for this article is be a rather lengthy one, inclusive
of the needs of many different types of operations.

With that said, let's dig in!

Physical location
-----------------

Never perform operations out of your place of living. Always travel to
a location at least 75 miles (121 kilometers) away. This location
should always be random. Never use the same place twice. Only bring
the minimal amount of personally-identifying items necessary (driver's
license if you're driving.)

You can use your own car, so long as it does not have RF comms
capabilities (GPS, satellite radio, even TPMS). Using a cab or ride
sharing service is okay, provided you can pay in cash. Most grocery
store customer service desks will let you use their phone. If you're
driving your own vehicle, try not to use roads with tolls. Depending
on the sensitivity of the operation, taking a cab to an area close to
your final destination, then walking the rest of the way might be a
good idea.

When travelling, wear non-identifiable clothing. Nothing with logos,
slogans, etc. Plain and boring is the entire theme of OPSEC. Only
travel with burner devices. Keep them turned off with the battery
removed until you reach your destination.

Never contact loved ones or people who know the real you during your
travels.

Securing your network
---------------------

Once you've traveled to a random location, make sure it has
publicly-available internet access. Wired is better than wireless,
though the vast majority of business only provide free wireless.

There's a common misconception that solely using
[VPNs](https://twitter.com/SarahJamieLewis/status/967090895920103425)
will keep you safe. This is not true. VPNs simply transfer trust. Stay
away from VPNs that market themselves as subpeaona- or warrant-proof.
VPN providers will always follow justified requests from law
enforcement agencies. They may not currently log, but they will once
required by law. No VPN provider will go to jail simply to save some
unknown user. They will always save their own skin.  VPNs are useful,
especially if you want to make your traffic look like it's coming from
a certain geographic region.  They're just one more tool in an OPSEC
toolbag.

Use a fully Tor-ified network. I've written a
[guide](https://github.com/lattera/articles/blob/master/infosec/tor/2017-01-14_torified_home/article.md)
on how to do that. Once you've connected to Tor, then connect to your
VPN of choice. Never connect to the VPN prior to connecting to Tor.

A simplified network diagram would look like:

Laptop -> VPN -> Tor -> Internet

Connecting to the VPN first enables the VPN provider to know who you
are. By connecting to Tor first (and using the Tor-ified network), you
will need to use a VPN provider that uses TCP instead of UDP. Tor does
not support UDP for anything other than DNS.

All devices on your network should be kept up-to-date. Use full-disk
encryption where possible to protect data at rest. Of course, when the
device is powered on and the encrypted volume is mounted, the
encrypted data is accessible by you and any potential adversaries.

Burner phones will likely not have firmware updates, but that's fine.
Burner phones should be treated as hostile devices and should be
tossed every-so-often.

All devices on the network should be paid for in cash. None of the
devices should be attributable to you. If your operating system
supports it, randomize the MAC addresses of the NICs on the devices.
Wired networks should be preferred over wireless.

Ensure bluetooth is disabled on all devices. Cameras should be covered
and microphones turned off, if possible. If there are physical toggles
for bluetooth, cameras, or microphones, use those.

If possible, use operating systems that put security first. If you're
a Linux user, I've heard good things about Alpine and Void Linux. If
you're a BSD user, you can't go wrong with HardenedBSD or OpenBSD.

If you go the "Tor-ify your network route," make sure NEVER to run Tor
behind Tor. Do not run the Tor Browser in this case. Running Tor
behind Tor can open up weaknesses in your setup.

If using a regular browser, ensure you've hardened it. Here are some
sites that teach you how to harden your browser:

1. Firefox:
   1. https://browserleaks.com/
   1. https://vikingvpn.com/cybersecurity-wiki/browser-security/guide-hardening-mozilla-firefox-for-privacy-and-security
   1. https://wiki.mozilla.org/Security/Referrer
1. Chrome:
   1. https://browserleaks.com/

Purchasing Equipment
--------------------

You will likely want or need a burner phone along with a burner SIM.
The following instructions have a bias towards purchasing equipment,
like a burner phone and SIM, within the USA. Always pay in cash.

A lot of electronics stores, like Best Buy, sell unlocked GSM phones.
Use the travel documentation above to travel to a random Best Buy. You
might be driving for a while, so plan to make it a day trip. Plan on
spending around $160 USD for a single burner phone and SIM. Trac Fone,
H2O Wireless, and Simple Mobile are good providers to use. They don't
require using official identification. Always buy the pre-paid top-up
cards.

You'll want to pay attention to how long stores keep their CCTV camera
recordings. Typically, they will delete recordings older than two
weeks or one month. Do NOT use your newly-purcashed equipment within
that window. Never set up your newly-purchased equipment at any
location that identifies you or where you purchased it.

When registering your burner phone and SIM, do so at a different
location. Again, use the travel instructions above after you've waited
till the surveillance camera recordings have cycled. Do the initial
setup, including setting up any accounts you may need (gmail, signal,
facebook, twitter, etc.). Make sure to use the Tor-ified network setup
linked to above during the setup process. Disable GPS, bluetooth, and
anything else that generates RF comms and isn't needed for
communication services.

After you've performed your initial setup, cut up and toss the SIM
card. Make sure to toss each bit in different locations. Put your
burner phone in airplane mode and keep it that way for the rest of the
burner's life time. You'll use wifi only from now on, preferrably with
the Tor-ified network.

Once you're done with the initial setup, you're set. Of course, the
phone number may get reassigned to someone else. That other person may
decide to use Signal with that number. If that happens, destroy your
current burner phone, toss it at a random location, and restart this
process all over again.

Whenever you're done at a location and are about to move to a new
location (including going home), make sure you pull the battery.
Ensure that whatever battery-powered equipment you purchase has a
removable battery.

Developing an Alternate Persona
-------------------------------

Developing an alternate persona takes time, skill, and patience. You
will need to pick a country, language, ancestry, friends, and name
that matches all of those. You need to establish an identity,
including likes/dislikes, opinions, religion (if any), sexual
orientation, etc. Use social media during the hours of the time zone
your persona should be in.

Do your research on the culture behind the geographic area of the
persona you're establishing. You will need to use the language of that
area. For example, I am American. If I wanted to establish a persona
of someone from England, I would make sure to always write "favourite"
instead of the US English spelling "favorite." "Color" becomes
"colour," "flavor" becomes "flavour," and so on. Your writing style
will need to change as well. How you form your sentences can give away
who you are.

Establish a migration history that fits your target geographic area.
Some people never leave the town they grew up in, some move around a
little, others move around a lot.

This section needs more info.

Communicating With Others
-------------------------

Human life would be extremely boring if we never interacted with other
people. Use only the burner devices you've set up in the sections
above. Use the alternate personas you've developed above.

Whenever possible, use end-to-end encrypted (e2e) communications
services, like Signal or Wickr. You will want to establish a device
rotation schedule and procedure, which includes notifying your
contacts of a new ephemeral phone number. You will need to
re-establish trust when you obtain a new device.

If you're meeting someone you've neve met before, meet in a highly
visible, public area. You need to establish trust. Do not talk about
sensitive operations in public, however. Forget what you've seen on TV
shows about operatives talking ops in a coffee shop. Never discuss
sensitive details over links that can be recorded, even if using
e2e applications. Assume the device you're using has already been
compromised, even before you opened the packaging material. Use the
burner device to discuss high-level details, such as meeting times and
locations.

When discussing sensitive details, keep electronics powered off, with
the batteries fully removed, and preferrably in a different room.
Ideally, the electronics would be powered off with the batteries
pulled before going to the location where sensitive details can be
discussed.

Special Note on Phones
----------------------

Contributed by: ThoughtPhreaker

If you're trying to hide yourself on the phone network, there's
several things to consider.

### What kind of phone are you using?

What kind of phone you're on is, to a recipient on a landline, an open
secret. The reason being that all four major mobile providers each use
different codecs and bitrates for their calls. T-Mobile uses AMR
running at 12 kbps and AT&T AMR at 6 kbps. Sprint and Verizon's CDMA
networks use proprietary codecs based on EVRC-B. Both have a
significantly sharper sound than AMR though, and in the case of
Verizon's network, a bitrate low enough to warrant the implementation
of vocoderization. Voice over LTE networks generally use different
codecs.

The point being however, these are all distinct sounding codecs, and
can be picked out by anyone with a good ear. It doesn't stop there,
though:

Many voice-over-wifi services default to using the original (now
generally unused in GSM, but extremely distinct sounding) GSM codec,
referred to as GSM 6.10, or occasionally just "full rate". If you have
the option to avoid it, doing so would be advisable.

One popular myth about the phone network is that it doesn't deliver
frequencies below 300 hertz. Despite what textbooks will tell you,
this is very false. While the interfaces to the mobile network have
DSP-based filters that cut off everything below roughly this, many
phones with analog interfaces - and the equipment that powers them
have whatever is cheapest to implement (which can vary quite a lot.
Either the line interface circuit or the phone almost always has one
though, typically rolling off around 100 hertz - some more steeply
than others). Digital phones intended for PBXes have one that goes
slightly lower depending on the manufacturer - maybe ballpark around
80 hertz. However, most softphones have _none_. This unusual low
frequency presence is easy to spot to begin with, but will also
greatly exacerbate the companding artifacts in the mu-law codec used
in the phone network. This means that the codec will begin to fuzz
like crazy, and even if you can't hear the low frequencies, will make
it plain as day how you're calling. The apparentness of this can be
magnified by webcam mics with poor acoustic echo cancellation and the
heavy-handed attempts of algorithms to conceal it.

Additionally, as far as incoming calls are concerned, it's important
to note that the type of equipment powering your phone can frequently
be identified by the ringback tone it generates. The reason being that
digital switching equipment frequently has a DSP loop pre-generated
PCM samples to generate the ring tone, and it's almost always done in
different ways by different equipment. Telecom operators are creatures
of habit, and will frequently buy a lot of the same gear for a
nationwide network. Anyone with knowledge of this will have a
significantly easier time figuring out what network you're using just
by hearing it.

### What number are you calling?

If someone is asking you to call something, the short answer is `*67`
never, ever cuts it. Dialing this introduces what's referred to as a
privacy bit; it doesn't stop your number from being delivered, but
will simply introduce a bit into the initial address message
associated with your phone call telling the equipment not to give it
to the subscriber.

Additional Resources
--------------------

"From 1973 to 1984, [CounterSpy](https://altgov2.org/counterspy/)
published detailed, damning information about US covert activities
(and, to a lesser extent, those of other countries, including Israel,
Australia, and South Africa). It was most infamous for naming CIA
station chiefs. The CIA loathed it and, it's said, succeeded in
undermining it."

As of 24 Mar 2018, I've archived all publicly available issues of
CounterSpy [here](https://github.com/lattera/CounterSpy). CounterSpy
is a really good resource for learning both opsec failures and
successes.
