#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Generates a CRL given the configuration file, CA certificate, CA key, and digest" >&2
    echo "" >&2
    echo "usage: $0 -f CONFIG -c CACERT -d DIGEST [-v DAYS]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -f CONFIG  configuration file to use" >&2
    echo "  -c CACERT  ca certificate" >&2
    echo "  -k CACERT  ca key" >&2
    echo "  -d DIGEST  certificate to revoke" >&2
    echo "  -v DAYS    validity of the CRL in days" >&2
}

CONFIG=
CACERT=
CAKEY=
DIGEST=
VALIDITY=365
while getopts "f:c:k:d:v:h" opt; do
    case "$opt" in
        f)
            CONFIG="${OPTARG}"
            ;;
        c)
            CACERT="${OPTARG}"
            ;;
        k)
            CAKEY="${OPTARG}"
            ;;
        d)
            DIGEST="${OPTARG}"
            ;;
        v)
            VALIDITY="${OPTARG}"
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$CONFIG" ] ||
   [ -z "$CACERT" ] ||
   [ -z "$CAKEY" ] ||
   [ -z "$DIGEST" ] ||
   [ -z "$VALIDITY" ]; then
    usage
    exit 1
fi

if [ "$DIGEST" != "md2" ] &&
   [ "$DIGEST" != "md5" ] &&
   [ "$DIGEST" != "sha1" ] &&
   [ "$DIGEST" != "sha224" ] &&
   [ "$DIGEST" != "sha256" ] &&
   [ "$DIGEST" != "sha384" ] &&
   [ "$DIGEST" != "sha512" ]; then
    echo "ERROR: the only valid digests are md2,md5,sha1,sha224,sha256,sha384,sha512" >&2
    exit 1
fi

openssl ca -config "$CONFIG" \
    -gencrl \
    -cert "$CACERT" \
    -keyfile "$CAKEY" \
    -md "$DIGEST" \
    -crldays "+$VALIDITY"
exit $?
