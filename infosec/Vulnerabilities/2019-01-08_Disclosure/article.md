Full Disclosure Versus Responsible Disclosure
=============================================

Very special and crucial note: This article discusses my personal
feelings regarding vulnerability disclosure methods. This article is
not written on behalf of HardenedBSD. This article does NOT reflect
the opinions, beliefs, or actions of The HardenedBSD Project.

Meltdown and Spectre, along with the other CPU microarchitecture
speculation vulnerabilities, will be the prime use case in this
article.

It's fine if you don't agree with this article. If everyone held my
same opinions and beliefs, the world would be a very boring place.
Diverse thought makes experiencing and living in this world exciting.

My goal with this article is to start a much-needed discussion. I hope
we in the infosec industry can learn from recent events and move
forward together.

My perspective may change with time. I'll keep this article updated
with regards to my perspective. I try to be malleable and
understanding. If I've completely missed the mark here, that's fine.
This is only a reflection of some of the recent events regarding large
architectural vulnerabilities that impact an extremely broad audience.
If you feel I'm out in left field, please reach out to me and we can
discuss the matter.

Definitions
-----------

We live in a time when vendors prefer security researchers disclose
newly-found vulnerabilities responsibly. We don't have a firm
definition of what "responsible disclosure" is, though. Usually,
researchers will follow this pattern:

1. Researcher finds exploitable vulnerability
1. Researcher notifies vendor, giving a projected embargo date
1. Vendor resolves issues prior to expiration of embargo
1. Researcher and vendor release a joint announcement

This workflow typically works when the vendor produces easy-to-update
products that don't have many (or any) downstream dependent consumers.
Firefox is an easy example. All Mozilla has to do is fix the bug and
cut a new release. The package maintainers for the various operating
systems will perform a version bump and the problem is largely solved.

The definition of "Responsible Disclosure" becomes murky when a
researcher finds a vulnerability in a hard-to-update product used in a
massive scale, like Intel CPUs. Sure, Intel should be notified, but
certain vulnerabilities have much larger impact than Intel's
product line by itself. Meltdown and Spectre provide an excellent case
study.

Thus, when we define "Responsible Disclosure," we also need to define
"Coordinated Disclosure." Vendors must responsibly decide which
downstream projects get notified and in which order.

The Coordinated Disclosure Problem
----------------------------------

A lot of business today is about relationships. This is especially
true in information security. We value the opinions of people we know
and trust and distrust everyone else.

When a vendor receives a security notification, the vendor must
evaluate who could be impacted and of those impacted, who to notify.
Coordinated disclosures usually come with either a Non-Disclosure
Agreement (NDA) or an embargo until a specified date. The vendor can
choose to collaborate with zero or more impacted entities of the
vendor's own choosing.

When Intel received notice from Google regarding Meltdown and Spectre,
Intel chose to notify only a few larger entities (eg, Amazon, Google,
and Linux). Those entities got a six-month advanced notice and had at
least some semblance of a fix the day the story broke in January 2018.
FreeBSD received notice the week around Christmas 2017 only after
certain researchers in-the-know pushed Intel hard to notify FreeBSD.
Smaller hosting companies and all of the other BSDs were left out.

Thus, Intel only coordinated the disclosure with a few larger players.
Favoritism is at play here. Such favoritism has a direct impact on the
economy of the less fortunate. Why would I go with a smaller hosting
provider when Amazon receives and can take action on advanced
vulnerability notifications? If security is of any concern, I should
only use Amazon's and Google's services. Screw the smaller players,
right?

Coordinated disclosure, as currently performed, should be called
unethical selective disclosure. Pay the right people your agreed
extortion, and you're now on the favorites list. When did it become
acceptable to pay someone to tell you you're vulnerable because of
their mistakes?

The Case For Full Disclosure
----------------------------

Since so-called responsible disclosure inevitably leads to greed and
extortion, full disclosure is the responsible way forward. All
downstream vendors become equals.

Full disclosure lends itself to a better collaborative effort. Now
that all entities are on equal footing, they can work together to
provide their communities the best quality fix. No one single vendor
has an omniscient developer capable of writing "the perfect fix." If
vendors work side-by-side, they can anticipate future problems along
with providing innovative fixes and mitigations for current issues.
