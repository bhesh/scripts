#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Generates a root CA given the key file" >&2
    echo "" >&2
    echo "usage: $0 -s SUBJ -k KEY -d DIGEST [-n SERIAL] [-v DAYS]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -s SUBJ    subject to use" >&2
    echo "  -k KEY     path to the key file" >&2
    echo "  -d DIGEST  signature digest to use" >&2
    echo "  -n SERIAL  serial to use (in 0xNNNN format)" >&2
    echo "  -v DAYS    validity of certificate in days" >&2
}

SUBJ=
KEY=
DIGEST=
SERIAL=
VALIDITY=1095
while getopts "s:k:d:n:v:h" opt; do
    case "$opt" in
        s)
            SUBJ="${OPTARG}"
            ;;
        k)
            KEY="${OPTARG}"
            ;;
        d)
            DIGEST="${OPTARG}"
            ;;
        n)
            SERIAL="-set_serial ${OPTARG}"
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

if [ -z "$SUBJ" ] ||
   [ -z "$KEY" ] ||
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

openssl req -config "${SRC_DIR}/openssl.cnf" \
    -new -x509 \
    -days "$VALIDITY" \
    -$DIGEST \
    -key "$KEY" \
    -subj "$SUBJ" \
    $SERIAL \
    -extensions v3_ca
exit $?
