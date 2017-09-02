One Week With Tor
=================

On 25 Aug 2017, I decided to spend one week completely over Tor. On
one of my spare firewalls, I installed HardenedBSD 12-CURRENT/amd64
and configured it to be a transparent Tor proxy. Being a transparent
proxy, it forces all TCP traffic to go over Tor. UDP traffic is
silently dropped.

I've been a small advocate for Tor for a while. I'd like to imagine a
world where every service is also accessible via Tor onion services.
My use of Tor has been steadily growing. I run a public relay out of
my home. I use that same relay for my transparent proxy setup.

As it stands today, the network jacks all throughout my house are all
on the Tor-ified network. The wireless network, though, is still
un-Tor-ified. Netflix and Amazon Prime Video won't work over Tor. I
cannot live without Arrested Development and my wife can't live
without Downton Abbey. Additionally, some of the Android apps on my
phone either don't use HTTPS or don't use certificate pinning. I don't
feel comfortable putting my Android devices on the Tor-ified network.

There are certain things I won't do over Tor. I won't do online
banking over Tor. I simply don't have enough trust in exit nodes to
perform such sensitive tasks.

The Land of Many Captchas
-------------------------

Captchas are extremely annoying. Apparently, they're at least somewhat
effective against bots. The captcha that seems to be the most robust
is the one asking to click on all the images of cars. The street signs
one is stupid and often incorrect.

I found out that if a site is hosting its CSS/JS assets on CloudFlare,
that site's users are going to have a bad time. Such is the case for
[mastodon.social](https://mastodon.social/). The content might be
direct loaded, but the assets are served over CloudFlare. CloudFlare
is notorious for aggressively using captchas for Tor users. This
becomes a problem for assets, since assets are loaded in the
background without user intervention. The user never sees CloudFlare's
captcha request. Thus, the browser fails loading the assets and the
site completely breaks.

I ranted about this on mastodon.social (using Tusky on my Android
phone). [Eugen](https://mastodon.social/@Gargron) eventually fixed it,
whitelisting Tor for asset requests. Tor users can now use
mastodon.social without running into weird CloudFlare captcha issues.

Google thinks nearly every search I do behind Tor is malicious. Google
will either fully block my searches or present me with a captcha. Even
if I do one search, wait five minutes, then do another search, I'm
presented with either a hard block or a captcha. I've now switched to
the [DuckDuckGo Onion Service](https://3g2upl4pq6kufc4m.onion/) as my
search engine.

The Land of Tor Bannification
-----------------------------

The only service that I've found that outright blocks Tor is EFnet
IRC. A few FreeBSD developers hang out in various
[channels](https://wiki.freebsd.org/IRC/Channels) on EFnet. The EFnet
servers have a Realtime Block List (RBL) that includes Tor exit nodes.
Unlike FreeNode, EFnet doesn't provide onion services for those who
wish to use Tor. So, no chatting with FreeBSD developers about arm64
for anyone use wants to chat over Tor.

FreeNode doesn't block/ban Tor. However, they do make it rather
difficult. You must first have a valid account (and creating a valid
account must be done over clearnet).

Pidgin seems to be unable to connect to Google Chat services. My wife
and I use Hangouts to talk to text eachother, instead of SMS. Using
Google Hangouts is easier for me since I'm at a computer all day. I
can type on a full keyboard instead of using my thumbs to haphazardly
chat.

I can still use Telegram and other XMPP-based services with Pidgin
just fine. If you ever feel the need to chat with me, hit me up on
XMPP at lattera@is.a.hacker.sx. I have OTR configured for it. My OTR
fingerprint is:

```
030FEA2D E1DD3FA0 891AEF03 8AABE7BD 39BC16EF
```

Conclusion
----------

There are certain things I cannot do over Tor, either due to my
mistrust in exit nodes or by being blocked by certain services. A VPN
could be used to evade Tor bans, but those present other potential
issues (and I still don't trust them for extremely sensitive tasks).

If you can live with captchas, annoying as they are, 95% of the
captcha'd world can be accessed. The 5% is to account for when sites
place their CSS/JS assets behind CloudFlare without whitelisting Tor.

I think I'll extend this experiment by one more week. Chances are,
I'll keep extending indefinitely.

Addendum 01 - Regarding Trust Issues
------------------------------------

A few people have asked me why I don't trust exit nodes with sensitive
tasks like online banking. My distrust is mainly in the horrible state
of SSL/TLS PKI. With hundreds of trusted roots, each with SSL/TLS
certificate resellers, the amount of trust I must place in the least
secure certificate vendor is huge. Any certificate vendor whose chain
of trust resolves to a trusted root can issue certificates for any
domain I visit. If a malicious exit node also has compromised or
coerced a certificate vendor to produce (what we would consider, but
our browser wouldn't) fraudulent certificate, I'm now in a pickle.

Moxie's Convergence project would help resolve those issues. I loved
his Defcon presentation, SSL and the Future of Authenticy. I really
wish his Convergence project would've taken off. Instead, the industry
has gone the other way with DNSSEC (which Tor's DNS proxying doesn't
support).

Because I cannot easily guarantee that my financial institution has a
hardened SSL/TLS configuration with HSTS and PFS, I cannot guarantee
the safety of sensitive traffic going through a Tor exit node. It's
bad enough that I have to trust my ISP and all nodes in the route to
my financial institution.

If I had some sort of guarantee that SSL/TLS could 100% guarantee the
authenticity and integrity of data transmitted over untrusted
networks, I would definintely be okay with online banking over Tor.
That's simply not the case.
