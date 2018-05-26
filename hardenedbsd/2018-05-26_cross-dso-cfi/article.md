May 2018 Status Report: Cross-DSO CFI in HardenedBSD
====================================================

Control Flow Integrity, or CFI, raises the bar for attackers aiming to
hijack control flow and execute arbitrary code. The llvm compiler
toolchain, included and used by default in HardenedBSD
12-CURRENT/amd64, supports forward-edge CFI. Backward-edge CFI support
is gained via a tangential feature called SafeStack. Cross-DSO CFI
builds upon ASLR and PaX NOEXEC for effectiveness.

HardenedBSD supports non-Cross-DSO CFI in base for 12-CURRENT/amd64
and has it enabled for a few individual ports. The term "non-Cross-DSO
CFI" means that CFI is enabled for code within an application's
codebase, but not for the shared libraries it depends on. Supporting
non-Cross-DSO CFI is an important initial milestone for supporting
Cross-DSO CFI, or CFI applied to both shared libraries and
applications.

This article discusses where HardenedBSD stands with regards to
Cross-DSO CFI in base. We have made a lot of progress, yet we're not
even half-way there.

Brace yourself: This article is going to be full of references to
"Cross-DSO CFI." Make a drinking game out of it. Or don't. It's your
call. ;)

Using More llvm Toolchain Components
------------------------------------

CFI requires compiling source files with Link-Time Optimization (LTO).
I remembered hearing a few years back that llvm developers were able
to compile the entirety of FreeBSD's source code with LTO. Compiling
with LTO produces intermediate object files as LLVM IR bitcode instead
of ELF objects.

In March of 2017, we started compiling all applications with LTO and
non-Cross-DSO CFI. This also enabled ld.lld as the default linker in
base since CFI requires lld. Commit
[f38b51668efcd53b8146789010611a4632cafade](https://github.com/HardenedBSD/hardenedBSD/commit/f38b51668efcd53b8146789010611a4632cafade)
made the switch to ld.lld as the default linker while enabling
non-Cross-DSO CFI at the same time.

Building libraries in base requires applications like ar, ranlib, nm,
and objdump. In FreeBSD 12-CURRENT, ar and ranlib are known as "BSD
ar" and "BSD ranlib." In fact, ar and ranlib are the same
applications. One is hardlinked to another and the application changes
behavior depending on arvgv[0] ending in "ranlib". The ar, nm, and
objdump used in FreeBSD do not support LLVM IR bitcode object files.

In preparation for Cross-DSO CFI support, commit
[fe4bb0104fc75c7216a6dafe2d7db0e3f5fe8257](https://github.com/HardenedBSD/hardenedBSD/commit/fe4bb0104fc75c7216a6dafe2d7db0e3f5fe8257)
in October 2017 saw HardenedBSD switching ar, ranlib, nm, and objdump
to their respective llvm components. The llvm versions due support LLVM
IR bitcode object files (surprise!) There has been some fallout in the
ports tree and we've added ``LLVM_AR_UNSAFE`` and friends to help
transition those ports that dislike llvm-ar, llvm-ranlib, llvm-nm, and
llvm-objdump.

With ld.lld, llvm-ar, llvm-ranlib, llvm-nm, and llvm-objdump the
default, HardenedBSD has effectively switched to a full llvm compiler
toolchain in 12-CURRENT/amd64.

Building Libraries With LTO
---------------------------

The primary 12-CURRENT development branch in HardenedBSD
(hardened/current/master) only builds applications with LTO as
mentioned in the secion above. My first attempt at building all
static and shared libraries failed due to issues within llvm itself.

I reported these issues to FreeBSD. Ed Maste (emaste@), Dimitry Andric
(dim@), and llvm's Rafael Espindola expertly helped address these
issues.  Various commits within the llvm project by Rafael fully
and quickly resolved the issues brought up privately in emails.

With llvm fixed, I could now build nearly every library in base with
LTO. I noticed, however, that if I kept non-Cross-DSO CFI and
SafeStack enabled, all applications would segfault. Even simplistic
applications like /bin/ls.

Disabling both non-Cross-DSO CFI and SafeStack, but keeping LTO
produced a fully functioning world! I have spent the last few months
figuring out why enabling either non-Cross-DSO CFI or SafeStack caused
issues. This brings us to today.

The Sanitizers in FreeBSD
-------------------------

FreeBSD brought in all the files required for SafeStack and CFI. When
compiling with SafeStack, llvm statically links a full sanitization
framework into the application. FreeBSD includes a full copy of the
sanitization framework in SafeStack, including the common C++
sanization namespaces. Thus, `libclang_rt.safestack` included code
meant to be shared among all the sanitizers, not just SafeStack.

I had naively taken a brute-force approach to setting up the
`libclang_rt.cfi` static library. I copied the `Makefile` from
`libclang_rt.safestack` and used that as a template for
`libclang_rt.cfi`. This approach was incorrect due to breaking the One
Definition Rule (ODR). Essentially, I ended up including a duplicate
copy of the C++ classes and sanitizer runtime if both CFI and
SafeStack were used.

In my Cross-DSO CFI development VM, I now have SafeStack disabled
across-the-board and am only compiling in CFI. As of 26 May 2018, an
LTO-ified world (libs + apps) works in my limited testing. `/bin/ls`
does not crash anymore! The second major milestone for Cross-DSO CFI
has now been reached.

Future Work
-----------

I need to create a static library that includes only a single copy of
the common sanitizer framework code. Applications compiled with CFI or
SafeStack will then only have a single copy of the framework.

Next I will need to integrate support in the RTLD for Cross-DSO CFI.
Applications with the cfi-icall scheme enabled that call functions
resolved through `dlsym(3)` currently crash due to the lack of RTLD
support. I need to make a design decision as to whether to only
support adding cfi-icall whitelist entries only with `dlfunc(3)` or to
also whitelist cfi-icall entries with the more widely used `dlsym(3)`.

There's likely more items in the "TODO" bucket that I am not currently
aware of. I'm treading in uncharted territory. I have no firm ETA for
any bit of this work. We may gain Cross-DSO CFI support in 2018, but
it's looking like it will be later in either 2019 or 2020.

Conclusion
----------

I have been working on Cross-DSO CFI support in HardenedBSD for a
little over a year now. A lot of progress is being made, yet there's
still some major hurdles to overcome. This work has already helped
improve llvm and I hope more commits upstream to both FreeBSD and llvm
will happen.

I would like to thank Ed Maste, Dimitry Andric, and Rafael Espindola
for their help, guidance, and support.
