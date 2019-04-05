# Interview With Piotr Mieszkowski

I was interviewed about [contributing to FLOSS](https://untalkative.one/2019/03/30/floss-contrib.html).
Some of the questions were really personal and I'm grateful to have
the opportunity to shine some light on my life. Below is the interview
in raw format.

## What projects do you participate in?

I'm the cofounder of the HardenedBSD project and president of the
HardenedBSD Foundation, a 501(c)(3) tax-exempt charitable organization
in the USA. I'm also a member of the OPNsense Core Team, helping them
improve their security through the adoption of HardenedBSD's robust,
scalable security enhancements and technologies. I sit on SoldierX's
High Council, in charge of our defensive and offensive security
research team.

In addition to contributing to HardenedBSD and OPNsense, I work on
libhijack and FreeBSD rootkits for SoldierX. There's a lot of fun
offensive research happening with libhijack. My next major goal is to
write a remote RTLD (RTLD is short for "runtime dynamic linker").

## How did you start? How did you engage with FLOSS for the first time?

I'm 33 now. I started offensive research when I was 13. Back in the
days of dialup, there were free dial-up internet services, like
NetZero and Juno. In order to use their free service, you had to
connect via their adware dial-in software. Being on a 33.6kbit/s
connection, those ads took up a lot of precious bandwidth. I learned
the very basics of reverse engineering and reversed the dial-in
adware. I figured out how it was talking to the modem and how it
authenticated with the service. I then wrote a Windows batch script to
automate the process. We only had one telephone line. I disabled call
waiting. My parents hated me. ;)

My love for tinkering with software continued. When I turned 19, I
left the infosec scene (back then, just called the "hacking scene")
for two years to serve a religious mission. When I got back, I focused
on defensive work.

I got involved with open source mostly by reading existing code then 
writing my own open source offensive tools. That lead me naturally to
want to write defensive measures in the operating system. I fell in
love with FreeBSD in around 2000. I served my mission in 2005-2007. I
started work on implementing defensive measures for FreeBSD in 2013,
through the HardenedBSD project, which I cofounded with Oliver Pinter
at that time. The project became a public project in 2014. In April
2019. the repo on GitHub will turn five years old!

I created a tool similar to libhijack, but for private use, prior to
leaving on my mission. After coming back, I resumed work on it by
rewriting it and eventually porting it to FreeBSD. I later removed
Linux support for it, and ported it to arm64. So libhijack supports
FreeBSD/amd64 and FreeBSD/arm64. I donated the libhijack project to
SoldierX and became a member on their High Council.

The work with OPNsense came about because I wanted to run pfSense
based on HardenedBSD, not based on FreeBSD. However, pfSense
ultimately rejected my offer to help them adopt HardenedBSD while
OPNsense accepted the same offer. As of January 2019, OPNsense is now
fully based on HardenedBSD!

## How much time do you spend daily or weekly on your FLOSS projects?

I have a really patient and supporting wife! ;)

Working to both maintain and improve HardenedBSD is a full-time job.
I put in a minimum of forty hours per week on HardenedBSD, with most
of that time being on the weekends. None of my work in open source is
done on company time, so all of my contributions are in spare time.

I also have medical issues, chronic migrains and depression. I cherish
those times when I feel good and can contribute in meaningful ways. 

## How long do you sleep usually?

My brain hates it if I get less than ten hours of sleep per night due
to how hard I work it during the day. However, I usually get around
6-7 hours per night.

As children, we hate naps. As adults, we can't get enough of them. ;)

## How do you achieve the balance between personal life, work and FLOSS activity?

I don't have a good balance. That is something I need to work on.
There are times when I feel burnt out, but then I remember why I do
this work in the first place. It's for a few reasons:

1. I owe my entire life to other FLOSS contributors. As a college
   flunkee, I was self-taught (with a lot of selfless help from others
   online) by reading quality code from other open source projects.  
1. Contributing to open source is my way of saying "thank you" to
   those people who helped me along the way, and who continue to help
   me now.
1. Being a university flunkee, I need to show potential employers
   quality work.  Open source allows them to see the kinds of things
   in which I'm interested and the quality of work I do.
1. My brain needs a creative outlet. If I go more than a two or three
   days without hacking on something, I get seriously depressed. I've
   lived with depression to various degrees my entire life. I feel   
   best when I hack on code. Perhaps it's my escape from life. Perhaps
   it's my brain wanting simply to be creative. Or perhaps it's a
   mixture of the two. ;)

## What hints would you like to give to people who would like to contribute to FLOSS projects but can't find the time to do it?

There's many ways to contribute. Contributing doesn't necessarily mean
development. Here's a few ways to contribute to a project:

1. Advocacy. Talk to people about the cool things you're doing with
   the project. Talk to them about how it has solved real-world
   problems for you.
1. Donate. This is a huge one. Donate hardware, software, and/or 
   money. A lot of developers work on their projects in their spare
   time, like me, with spare resources. Donating funds allows them to
   pay for hosting services, DNS, etc. Donating hardware allows them 
   to test their code in a variety of ways.
1. Document. Every project's documentation could be improved in some
   way. Whether it be through translation or enhancements to any  
   existing documents, help with documentation will always be gladly
   received.
1. Development. If you do have time to develop (though this question
   is about not having the time), do it! If you use the project at
   work, perhaps you can have your employer slice off some paid time
   for fixing bugs.

## What motivates you to keep doing it? What  motivated you at the beginning?

I think I answered this question above. Whoops! Essentially,
contributing to open source is my way of giving back to those who
taught me so much and a way of saying thank you. As a side affect, my
contributions help fill gaps.

## What major obstacles did you need to overcome and how did you do it?

I still face obstacles. I take the attitude that "I'm a newb." There's
always something more to learn. There's always something about which I
have an incorrect assumption. There's always something of which I'm
ignorant.

I try to overcome challenges by learning about them. I may fail
occasionally, and that's fine. Eventual success sometimes comes with
failure. As Mythbuster's Adam Savage says, I only want to work with
those who have failed in some way, and aren't afraid to admit the
failure and learn and grow from it. It's through that learning process
that we not only gain success, but also learn what was originally
needed for that success.

Let's learn and grow together. Let's uplift and community and make
tomorrow a better place for everyone around us, and potentially people
we don't know and never will. That's the fun thing about open source:
our contributions could help people in ways we don't understand.
