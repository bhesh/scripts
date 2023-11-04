#!/bin/bash

usage() {
    echo "Generates a certificate request given the key file" >&2
    echo "" >&2
    echo "usage: $0 -s SUBJ -k KEY -d DIGEST" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -s SUBJ    subject to use" >&2
    echo "  -k KEY     path to the key file" >&2
    echo "  -d DIGEST  signature digest to use" >&2
}

SUBJ=
KEY=
DIGEST=
while getopts "s:k:d:h" opt; do
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
        *)
            usage
            exit 0
            ;;
    esac
done

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

openssl req -new -$DIGEST -key "$KEY" -subj "$SUBJ"
exit $?
