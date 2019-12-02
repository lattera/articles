# HardenedBSD Infrastructure Goals

2019 has been an extremely productive year with regards to
HardenedBSD's infrastructure. Several opportunities aligned themselves
in such a way as to open a door for a near-complete rebuild with a
vast expansion.

The last few months especially have seen a major expansion of our
infrastructure. We obtained a number of to-be-retired Dell R410
servers. The crash of our nightly build server provided the
opportunity to deploy these R410 servers, doubling our build capacity.

My available time to spend on HardenedBSD has decreased compared to
this time last year. As part of rebuilding our infrastructure, I
wanted to enable the community to be able to contribute. I'm
structuring the work such that help is just a pull request away. Those
in the HardenedBSD community who want to contribute to the
infrastructure work can simply open a pull request. I'll review the
code, and deploy it after a successful review. Users/contributors
don't need access to our servers in order to improve them.

My primary goal for the rest of 2019 and into 2020 is to become fully
self-hosted, with the sole exception of email. I want to transition
the source-of-truth git repos to our own infrastructure. We will still
provide a read-only mirror on GitHub.

As I develop this infrastructure, I'm doing so with human rights in
mind. HardenedBSD is in a very unique position. In 2020, I plan to
provide production Tor Onion Services for the various bits of our
infrastructure. HardenedBSD will provide access to its various
internal services to its developers and contributors. The entire
development lifecycle, going from dev to prod, will be able to happen
over Tor.

Transparency will be key moving forward. Logs for the auto-sync script
are now published directly to GitHub. Build logs will be, soon, too.
Logs of all automated processes, and the code for those processes,
will be tracked publicly via git. This will be especially crucial for
development over Tor.

Integrating Tor into our infrastructure so deeply increases risk and
maintenance burden. However, I believe that through added
transparency, we will be able to mitigate risk. Periodic audits will
need to be performed and published.

I hope to migrate HardenedBSD's site away from Drupal to a static site
generator. We don't really need the dynamic capabilities Drupal gives
us. The many security issues Drupal and PHP both bring also leave much
to be desired.

So, that's about it. I spent the last few months of 2019 laying the
foundation for a successful 2020. I'm excited to see how the project
grows.
