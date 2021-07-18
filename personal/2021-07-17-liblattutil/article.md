# Introducing liblattutil

Over the past few years, I've found myself writing some of the same
boilerplate code over and over and over again for both personal and
work projects. I'm completely revamping my work's entire software
catalogue. So I'm left with reimplementing some of the bits I've
implemented before, but perhaps only slightly different.

The end goal is to capture in one place the set of code common to the
many projects I've written over the years, both open source and
proprietary (but only the non-money-making bits of the proprietary
code).

I'm getting long-winded, so on to the details.

Though the first set of APIs has been written, I would consider
neither the ABIs nor the APIs stable, yet. I plan to `git tag`
specific versions, and at that point, the ABIs and APIs should be
considered stable.

These are the initial set of features:

1. Modular logging system, supporting the following backends:
   * dummy (completed)
   * syslog (completed)
   * sqlite3 (todo)
   * stdio (todo)
1. sqlite3 abstractions (completed)
1. libucl-based configuration file parsing (in progress)
1. thread pools (todo)

The project is written with a slightly modified FreeBSD style(9) code
style. One goal is to make sure that the code is self-documenting
without any "clever" code. Clever code is usually antithetical to
clear, understandable code.

Though this code is meant primarily for my use, I hope that someone
else finds it useful. I'm totally open to bug reports and merge
requests.

Over time, I'll write a set of articles detailing how to use
liblattutil.

Here's a quick little sample on how to use the logging API (again,
neither the ABI nor API should be considered stable).

```C
#include <syslog.h>
#include <liblattutil.h>

lattutil_log_t *logp;

logp = lattutil_log_init("myapp", -1);
if (logp == NULL) {
	fprintf(stderr, "[-] Unable to create logging object\n");
	exit(1);
}

if (!lattutil_log_syslog_init(logp, LOG_PID, LOG_USER)) {
	fprintf(stderr, "[-] Unable to configure logging\n");
	exit(1);
}

logp->ll_log_info(logp, -1, "Informational log message");
logp->ll_log_err(logp, -1, "Error log message");
logp->ll_logg_warn(logp, -1, "Warning log message");

lattutil_log_free(&logp);
```
