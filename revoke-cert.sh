#!/bin/bash

usage() {
    echo "Revokes a certificate given the configuration file, CA certificate, CA key, certificate to revoke, and digest" >&2
    echo "" >&2
    echo "usage: $0 -f CONFIG -c CACERT -k CAKEY -r CERT -d DIGEST" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -f CONFIG  configuration file to use" >&2
    echo "  -c CACERT  ca certificate" >&2
    echo "  -k CACERT  ca key" >&2
    echo "  -r CERT    certificate to revoke" >&2
    echo "  -d DIGEST  certificate to revoke" >&2
}

CONFIG=
CACERT=
CAKEY=
CERT=
DIGEST=
while getopts "f:c:k:r:d:h" opt; do
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
        r)
            CERT="${OPTARG}"
            ;;
        d)
            DIGEST="${OPTARG}"
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
   [ -z "$CERT" ] ||
   [ -z "$DIGEST" ]; then
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
    -cert "$CACERT" \
    -keyfile "$CAKEY" \
    -revoke "$CERT" \
    -md md5
exit $?
