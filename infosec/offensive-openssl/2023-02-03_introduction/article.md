# Introducing Offensive-OpenSSL

I found myself in a situation where I needed to be able to generate custom
cryptographic key material of the type commonly used in communications
applications and libraries. I also need to trick existing open source
applications and libraries into accepting and using weird key material.

Software monocultures are unfortunate, but it's where we are. However, I'm about
to benefit from the rigidity (and fragility?) of the software ecosystem to which
we are eternally and fatally bound. And you can benefit, too!

The primary purpose of "Offensive-OpenSSL" is to provide the community with a
version of OpenSSL that red teamers and offensive peeps can make use of with as
little effort as possible. The Offensive-OpenSSL project will do its best to
maintain exact ABI and API compatibility with upstream OpenSSL. Peeps should be
able to replace their `libcrypto.so` and `libssl.so` with that from
Offensive-OpenSSL. (Or, better yet, just recompile the darn thing!)

For purposes of the examples contained in this article, let us assume that I run
a complete hierarchical certificate authority in a lab-based setting. I control
the entire certificate chain and the related cryptographic key material.

The code can be found at my own
[fork](https://git.hardenedbsd.org/shawn.webb/openssl/) of the repo.

# No More Sanity

OpenSSL's certificate and cryptographic key material generation code contains a
lot of sanity checks. For example, OpenSSL ensures that the notAfter date is
indeed after the notBefore date with X.509 certificates.

The first goal of the Offensive-OpenSSL project is to rid ourselves of all
sanity checks unrelated to memory safety. This goal is incomplete, but is
definitely very much in progress. Want to put in a unicode character where only
ASCII is allowed? YES, PLEASE!

Removing sanity checks will aid in implementing our second goal.

# Enhancing the Command Line Interface

A lot of OpenSSL's command line interface regards itself solely with the
generation and presentation of key material--not the manipulation of such. I
will be adding parameters to the `openssl(8)` command we all have grown to love.
Existing scripts, tools, etc. will all still work as before.

Let us suppose that I have an X.509 certificate with an embedded RSA public key.
Is it possible for me to tweak the certificate's metadata in such a way that
consumers of that certificate might think the embedded key material is an ECDSA
public key instead?

This is where having a cryptographic key material "Swiss Army Knife" comes in
handy. By removing the sanity checks as mentioned above, we are now able to
further enhance the OpenSSL command line interface to provide these kinds of
capabilities.

# Deep Integration

The fun thing about being an operating systems developer is knowing how to
deeply integrate into the OS these kinds of fun things. The BSDs are monolithic:
they are an entire operating system, not just a kernel. The userland is
developed in lockstep with the kernel. You know that FreeBSD's `/bin/ls` is
FreeBSD's `/bin/ls`, not some random code dealer down on Forth Street.

FreeBSD (and a downstream project I'm inherently biased towards, HardenedBSD)
bundles OpenSSL with the operating system. So we have an interesting opportunity
here. We can perform a deep and tight integration of Offensive-OpenSSL into
HardenedBSD simply by copying over the modified files.

Since Offensive-OpenSSL will do its best to maintain ABI and API compatibility
with OpenSSL, this means that any application running on Offensive-HardenedBSD
will automatically pick up Offensive-OpenSSL (and not even know it!)

Thus, Offensive-OpenSSL will be baked right into the operating system. Well,
into a feature branch, that is. No way in heck would I merge Offensive-OpenSSL
into one of HardenedBSD's main branches.

HardenedBSD enforces and applies an ever-growing list of exploit mitigations and
security hardening techniques to userland. As someone who dabbles in offensive
work--including active threat hunting (and baiting)--from time to time, it is
imperative that whatever offensive tasks I performed are done in a defensive
environment.

Integrating Offensive-OpenSSL into a special feature branch of HardenedBSD
enables users to deploy normal HardenedBSD on their systems, yet create
containers with Offensive-OpenSSL deployed and have the same experience.

Indeed, this is precisely what I have done for satisfying the needs that birthed
this project: I have a special HardenedBSD jail (aka, container) in which I've
deployed Offensive-OpenSSL. The nginx package was installed into that container
from HardenedBSD's official package repos. Without having to recompile or
modify nginx at all, nginx now behaved differently due to `libcrypto.so` and
`libssl.so` provided by HardenedBSD being built from Offensive-OpenSSL sources.

The [HardenedBSD](https://git.hardenedbsd.org/hardenedbsd/HardenedBSD) feature
branch is aptly named
[shawn.webb/13-stable/offensive-openssl/main](https://git.hardenedbsd.org/hardenedbsd/HardenedBSD/-/commits/shawn.webb/13-stable/offensive-openssl/main).

# This is only the beginning

There's a lot more work to be done. I'm hoping to really turn this thing into a
useful tool for those interested in offensive work. The best part is that
anything that already relies on OpenSSL will be able to be exercised by
Offensive-OpenSSL. Not only can offensive peeps generate weird cryptographic key
material, but they can also toy with applications and libraries in unexpected
ways.

# Example output

If you like bloodshot eyes, here you go! In this output, we see two things.
Namely, that we were able to generate a client-side certificate with a notAfter
date that preceeds the notBefore date. And we see that nginx gladly accepted it.

The test zsh script I wrote can be found
[here](https://git.hardenedbsd.org/shawn.webb/articles/-/blob/master/infosec/offensive-openssl/2023-02-03_introduction/test_tls.zsh).

```
$ uname -a
FreeBSD offensive-openssl 13.2-PRERELEASE-HBSD FreeBSD 13.2-PRERELEASE-HBSD #0  hardened/13-stable/master-n191656-36e160ea752: Tue Feb  7 09:57:03 EST 2023     shawn@hbsd13-playground-01:/usr/obj/usr/src/amd64.amd64/sys/HARDENEDBSD amd64
$ pkg info nginx
nginx-1.22.1_2,3            
Name           : nginx                                                                                                                                         
Version        : 1.22.1_2,3                                                    
Installed on   : Thu Feb  9 03:02:48 2023 UTC                                  
Origin         : www/nginx 
Architecture   : FreeBSD:13:amd64
Prefix         : /usr/local
Categories     : www         
Licenses       : BSD2CLAUSE                                                                                                                                    
Maintainer     : joneum@FreeBSD.org
WWW            : https://nginx.com/
Comment        : Robust and small WWW server

[NOTE: I snipped a lot of unneeded text here.]

$ openssl version
OpenSSL 1.1.1s-freebsd  1 Nov 2022
$ openssl x509 -text -noout -in pki/issued/CatBadCert_02.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            c8:30:a2:68:1e:d6:0a:2c:6b:ee:fe:7c:b6:df:a8:a3
        Signature Algorithm: sha512WithRSAEncryption
        Issuer: CN = CatDeviceTestCA
        Validity
            Not Before: Feb  8 21:05:43 2023 GMT
            Not After : Feb  7 21:05:43 2023 GMT
        Subject: CN = CatBadCert_02
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:e8:7f:6d:e8:d1:d5:2b:67:5d:91:5c:5e:52:f5:
                    88:0f:3b:52:7e:98:63:73:df:2a:41:b5:3c:05:82:
                    41:cc:74:72:59:de:2b:4b:7f:a3:93:1d:77:f4:6d:
                    8b:4d:ca:21:96:e3:21:7d:f5:de:2d:59:55:be:f6:
                    04:5b:5d:27:fa:5e:e7:aa:e1:a5:85:f1:88:66:f3:
                    8e:45:e9:7e:56:a9:e2:2b:bf:be:c0:df:a0:f7:87:
                    55:6d:b1:b8:2e:42:a0:1a:47:ef:e9:c9:5c:99:f9:
                    a0:7a:db:93:42:24:ae:c3:38:26:76:e4:f1:b4:5a:
                    e8:37:78:62:2a:42:bf:d1:b3:8e:df:04:28:96:e0:
                    67:63:c8:47:19:57:10:fa:8c:47:8e:3c:5b:b9:ee:
                    c4:47:35:24:2e:fd:80:a2:26:e0:7e:04:84:05:99:
                    90:7a:a1:f9:44:27:4e:95:b4:d6:96:28:2c:e2:b5:
                    15:8b:49:2e:70:45:11:2a:9f:1b:b0:86:05:10:ac:
                    29:a1:03:e8:db:4c:0f:b1:83:24:d8:bb:8b:43:72:
                    a8:aa:83:d6:11:9a:71:de:f3:5d:47:8d:8b:56:07:
                    ab:7a:e5:3a:09:a0:0b:09:2d:07:88:c4:30:cd:3a:
                    ea:b0:01:a9:35:44:e4:94:2d:b6:86:2f:90:22:e8:
                    ed:4f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                3A:1B:F9:D7:03:3F:3B:C5:A8:BB:0A:A0:FA:12:8E:B3:C6:24:FC:58
            X509v3 Authority Key Identifier: 
                keyid:10:40:DD:A8:F3:E4:CD:3F:A0:15:13:E4:4F:8A:49:51:72:61:9F:0D
                DirName:/CN=CatDeviceTestCA
                serial:4E:22:52:1E:52:3E:1D:02:58:D7:67:82:D4:17:D0:8B:CF:D0:7A:B1

            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Key Usage: 
                Digital Signature
    Signature Algorithm: sha512WithRSAEncryption
         47:3d:1b:36:43:2d:7c:fd:76:7b:29:56:99:b3:9d:14:bb:3b:
         9e:f6:5a:30:c0:38:67:81:d6:d2:27:61:3a:2d:20:72:0a:eb:
         08:10:a3:58:a9:ff:17:78:11:78:b4:bc:6b:17:5a:91:ed:51:
         15:15:07:00:09:69:f7:98:b8:05:6f:9c:3e:8c:b3:bf:9e:8b:
         b6:4e:1f:29:8e:66:2a:66:e7:90:04:0d:25:44:be:36:18:88:
         2f:a4:10:22:dd:88:8d:3c:96:ba:80:75:35:72:f0:5d:e2:c6:
         a0:a0:32:fb:a0:91:09:1d:0c:55:07:39:a7:14:65:99:e4:aa:
         45:94:7f:e9:d6:71:be:2a:84:82:8f:7a:70:f8:9d:93:83:44:
         c4:24:7e:72:4e:76:c8:9d:f2:42:d8:40:ac:49:ba:c2:d4:22:
         2d:bf:6a:e1:f5:3c:d6:d3:9c:3a:bd:b8:60:5a:ed:27:33:3f:
         c5:e4:b2:b1:ee:c9:25:1b:6b:64:c2:55:dc:52:3d:4a:43:ba:
         a8:5e:e6:5d:6c:7f:cb:f0:cf:4c:9b:bd:4b:dd:8a:70:c6:89:
         be:20:39:53:96:5c:91:6a:25:a8:b1:45:5b:db:8a:8c:6f:90:
         3b:7e:40:a5:f5:38:72:4b:cf:71:71:29:8d:81:7b:3b:01:e1:
         d0:db:4e:34
$ ./test_tls.zsh -c CatBadCert_02
+./test_tls.zsh:5> noca='' 
+./test_tls.zsh:6> cert='' 
+./test_tls.zsh:7> pkidir=/home/shawn/engagements/certs/pki 
+./test_tls.zsh:9> getopts c:np: o
+./test_tls.zsh:10> case c (c)
+./test_tls.zsh:12> cert=CatBadCert_02 
+./test_tls.zsh:9> getopts c:np: o
+./test_tls.zsh:23> [ -z CatBadCert_02 ']'
+./test_tls.zsh:28> [ ! -f /home/shawn/engagements/certs/pki/issued/CatBadCert_02.crt ']'
+./test_tls.zsh:34> cat
+./test_tls.zsh:39> openssl s_client -connect 192.168.99.11:443 -CAfile /home/shawn/engagements/certs/pki/ca.crt -cert /home/shawn/engagements/certs/pki/issued/CatBadCert_02.crt -key /home/shawn/engagements/certs/pki/private/CatBadCert_02.key -quiet
Can't use SSL_get_servername
HTTP/1.1 200 OK
Server: nginx/1.22.1
Date: Thu, 09 Feb 2023 03:10:50 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 19 Oct 2022 08:02:20 GMT
Connection: keep-alive
ETag: "634faf0c-267"
Accept-Ranges: bytes
```
