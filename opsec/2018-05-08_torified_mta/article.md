Setting up an MTA Behind Tor
============================

This article will document how to set up OpenSMTPD behind a
[fully Tor-ified network](https://github.com/lattera/articles/blob/master/infosec/tor/2017-01-14_torified_home/article.md).
Given that Tor's DNS resolver code does not support MX record lookups,
care must be taken for setting up an MTA behind a fully Tor-ified
network. OpenSMTPD was chosen because it was easy to modify to force
it to fall back to A/AAAA lookups when MX lookups failed with a DNS
result code of NOTIMP (4).

Note that as of 08 May 2018, the OpenSMTPD project is planning a
configuration file language change. The proposed change has not
landed. Once it does, this article will be updated to reflect both the
old language and new.

The reason to use an MTA behing a fully Tor-ified network is to be
able to support email behind the .onion TLD. This setup will only
allow us to send and receive email to and from the .onion TLD.

Requirements:

1. A fully Tor-ified network
1. HardenedBSD as the operating system
1. A server (or VM) running HardenedBSD behind the fully Tor-ified
   network.
1. /usr/ports is empty
   * Or is already pre-populated with the HardenedBSD Ports tree

Why use HardenedBSD? We get all the features of FreeBSD (ZFS, DTrace,
bhyve, and jails) with enhanced security through exploit mitigations
and system hardening. Tor has a very unique threat landscape and using
a hardened ecosystem is crucial to mitigating risks and threats.

Also note that this article reflects how I've set up my MTA. I've
included configuration files verbatim. You will need to replace the
text that refers to my .onion domain with yours.

Installation
------------

On 08 May 2018, HardenedBSD's version of OpenSMTPD just gained
[support](https://github.com/HardenedBSD/hardenedbsd-ports/commit/fbc2c8f8bb023bf91ae6dcbc5643507d3cd9c0c3)
for running an MTA behind Tor. The package repositories do not yet
contain the patch, so we will compile OpenSMTPD from ports.

We'll also install dovecot for IMAP support.

```
# pkg install -y git-lite
# mkdir -p /usr/ports
# git clone https://github.com/HardenedBSD/hardenedbsd-ports.git \
    /usr/ports
# cd /usr/ports/mail/opensmtpd
# make install clean BATCH=1
# pkg install dovecot
# sysrc smtpd_enable=YES
```

Replace `/etc/mail/mailer.conf` with this:

```
# $FreeBSD$
#
# Execute the "real" sendmail program, named /usr/libexec/sendmail/sendmail
#
### smtpd: sendmail     /usr/libexec/sendmail/sendmail
### smtpd: mailq                /usr/libexec/sendmail/sendmail
### smtpd: newaliases   /usr/libexec/sendmail/sendmail
### smtpd: hoststat     /usr/libexec/sendmail/sendmail
### smtpd: purgestat    /usr/libexec/sendmail/sendmail
sendmail        /usr/local/sbin/smtpctl
send-mail       /usr/local/sbin/smtpctl
mailq           /usr/local/sbin/smtpctl
makemap         /usr/local/libexec/opensmtpd/makemap
newaliases      /usr/local/libexec/opensmtpd/makemap
```

Generating Cryptographic Key Material
-------------------------------------

We will want to support SSL/TLS and STARTTLS with OpenSMTPD and
Dovecot. We need to generate some crypto key material. We'll use
self-signed certificates. Note that generating the 4096-bit DH
parameters can take a substantial amount of time, so grab a pineapple
pizza and watch your favorite episode of Seinfeld. Perhaps practice
the Elaine dance a little.

```
# openssl req -x509 -new rsa:4096 \
    -keyout /usr/local/etc/ssl/mta.key.pem \
    -out /usr/local/etc/ssl/mta.crt.pem \
    -days 3650 -nodes
# openssl dhparam -out /usr/local/etc/dovecot/dh.pem 4096
```

Tor Configuration
-----------------

We now need to add an Onion Service for our MTA. Let's add the
following lines to the torrc of our Tor-ified network:

```
HiddenServiceDir /var/db/tor/services-mta-01
HiddenServiceVersion 3
HiddenServicePort 22 192.168.254.20:22
HiddenServicePort 25 192.168.254.20:25
HiddenServicePort 80 192.168.254.20:80
HiddenServicePort 143 192.168.254.20:143
HiddenServicePort 587 192.168.254.20:587
HiddenServicePort 993 192.168.254.20:993
```

Replace 192.168.254.20 with the IP of the MTA system. You can find out
the hostname of your MTA with this command after restarting or
reloading the tor service:

```
# cat /var/db/tor/services-mta-01/hostname
```

You will use that hostname later on in this process.

OpenSMTPD Configuration
-----------------------

A basic configuration for OpenSMTPD is really simple. We'll use a
configuration file that has been only slightly modified from the
example:

Place this in `/usr/local/etc/mail/smtpd.conf`:

```
pki 3w2s7tpb5mc7ubsjjnzp4oxvqupjeoywzwdxfvfnjn3toqbuzgkn7kqd.onion certificate "/usr/local/etc/ssl/mta.crt.pem"
pki 3w2s7tpb5mc7ubsjjnzp4oxvqupjeoywzwdxfvfnjn3toqbuzgkn7kqd.onion key "/usr/local/etc/ssl/mta.key.pem"

listen on lo0
listen on igb0
listen on igb0 port 587 tls-require pki 3w2s7tpb5mc7ubsjjnzp4oxvqupjeoywzwdxfvfnjn3toqbuzgkn7kqd.onion

table aliases file:/etc/mail/aliases

accept from any for domain "3w2s7tpb5mc7ubsjjnzp4oxvqupjeoywzwdxfvfnjn3toqbuzgkn7kqd.onion" alias <aliases> deliver to maildir "~/mail"

accept for local alias <aliases> deliver to maildir "~/mail"
accept from any for domain "*.onion" relay
```

This configuration will make our MTA an open relay to other .onion
MTAs. Given the use cases for Tor, I believe this to be acceptable. We
could add authentication to the MTA, but I don't believe this to be
necessary at this point.

Dovecot Configuration
---------------------

Now that the MTA is configured, we can now set up Dovecot for IMAP
access.

```
# cp -R /usr/local/etc/dovecot/example-config/* \
    /usr/local/etc/dovecot
# sysrc dovecot_enable=YES
```

Set the following variables in the following files:

1. `/usr/local/etc/dovecot/conf.d/10-auth.conf`
   1. `auth_mechanisms = plain login cram-md5 digest-md5`
1. `/usr/local/etc/dovecot/conf.d/10-mail.conf`
   1. `mail_location = maildir:~/mail`
1. `/usr/local/etc/dovecot/conf.d/10-ssl.conf`
   1. `ssl_cert = </usr/local/etc/ssl/mta.crt.pem`
   1. `ssl_key = </usr/local/etc/ssl/mta.key.pem`
   1. `ssl_dh = </usr/local/etc/dovecot/dh.pem`

Some files have weird syntax that is hard to describe in the above
numbered list format. The following files are pasted verbatim. The
first commented line contains the filename.

```
# /usr/local/etc/dovecot/conf.d/10-master.conf
#default_process_limit = 100
#default_client_limit = 1000

# Default VSZ (virtual memory size) limit for service processes. This is mainly
# intended to catch and kill processes that leak memory before they eat up
# everything.
#default_vsz_limit = 256M

# Login user is internally used by login processes. This is the most untrusted
# user in Dovecot system. It shouldn't have access to anything at all.
#default_login_user = dovenull

# Internal user is used by unprivileged processes. It should be separate from
# login user, so that login processes can't disturb other processes.
#default_internal_user = dovecot

service imap-login {
  inet_listener imap {
    port = 143
  }
  inet_listener imaps {
    port = 993
    ssl = yes
  }

  # Number of connections to handle before starting a new process. Typically
  # the only useful values are 0 (unlimited) or 1. 1 is more secure, but 0
  # is faster. <doc/wiki/LoginProcess.txt>
  #service_count = 1

  # Number of processes to always keep waiting for more connections.
  #process_min_avail = 0

  # If you set service_count=0, you probably need to grow this.
  #vsz_limit = $default_vsz_limit
}

service pop3-login {
  inet_listener pop3 {
    #port = 110
  }
  inet_listener pop3s {
    #port = 995
    #ssl = yes
  }
}

service submission-login {
  inet_listener submission {
    #port = 587
  }
}

service lmtp {
  unix_listener lmtp {
    #mode = 0666
  }

  # Create inet listener only if you can't use the above UNIX socket
  #inet_listener lmtp {
    # Avoid making LMTP visible for the entire internet
    #address =
    #port = 
  #}
}

service imap {
  # Most of the memory goes to mmap()ing files. You may need to increase this
  # limit if you have huge mailboxes.
  #vsz_limit = $default_vsz_limit

  # Max. number of IMAP processes (connections)
  #process_limit = 1024
}

service pop3 {
  # Max. number of POP3 processes (connections)
  #process_limit = 1024
}

service submission {
  # Max. number of SMTP Submission processes (connections)
  #process_limit = 1024
}

service auth {
  # auth_socket_path points to this userdb socket by default. It's typically
  # used by dovecot-lda, doveadm, possibly imap process, etc. Users that have
  # full permissions to this socket are able to get a list of all usernames and
  # get the results of everyone's userdb lookups.
  #
  # The default 0666 mode allows anyone to connect to the socket, but the
  # userdb lookups will succeed only if the userdb returns an "uid" field that
  # matches the caller process's UID. Also if caller's uid or gid matches the
  # socket's uid or gid the lookup succeeds. Anything else causes a failure.
  #
  # To give the caller full permissions to lookup all users, set the mode to
  # something else than 0666 and Dovecot lets the kernel enforce the
  # permissions (e.g. 0777 allows everyone full permissions).
  unix_listener auth-userdb {
    #mode = 0666
    #user = 
    #group = 
  }

  # Postfix smtp-auth
  #unix_listener /var/spool/postfix/private/auth {
  #  mode = 0666
  #}

  # Auth process is run as this user.
  #user = $default_internal_user
}

service auth-worker {
  # Auth worker process is run as root by default, so that it can access
  # /etc/shadow. If this isn't necessary, the user should be changed to
  # $default_internal_user.
  #user = root
}

service dict {
  # If dict proxy is used, mail processes should have access to its socket.
  # For example: mode=0660, group=vmail and global mail_access_groups=vmail
  unix_listener dict {
    #mode = 0600
    #user = 
    #group = 
  }
}
```

Testing your configuration
--------------------------

Use your favorite MUA (mutt, neomutt, thunderbird, etc.) to connect to
your MTA. Feel free to send me an email at
shawn@3w2s7tpb5mc7ubsjjnzp4oxvqupjeoywzwdxfvfnjn3toqbuzgkn7kqd.onion
and I'll do my best to respond when I can.
