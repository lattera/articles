#!/usr/local/bin/zsh

set -ex

noca=""
cert=""
pkidir="/home/shawn/engagements/certs/pki"

while getopts 'c:np:' o; do
	case "${o}" in
		c)
			cert="${OPTARG}"
			;;
		n)
			noca="-no-CAfile"
			;;
		p)
			pkidir="${OPTARG}"
			;;
	esac
done

if [ -z "${cert}" ]; then
	echo "[-] Specify the cert with -c" >&2
	exit 1
fi

if [ ! -f ${pkidir}/issued/${cert}.crt ]; then
	echo "[-] Cert ${pkidir}/issued/${cert}.crt not found" >&2
	exit 1
fi

(
	cat<<EOF
HEAD / HTTP/1.1
Host: localhost

EOF
)| openssl s_client \
	-connect 192.168.99.11:443 \
	-CAfile ${pkidir}/ca.crt \
	-cert ${pkidir}/issued/${cert}.crt \
	-key ${pkidir}/private/${cert}.key \
	${noca} \
	-quiet
