#!/bin/bash

usage() {
    echo "Generates an OCSP request" >&2
    echo "" >&2
    echo "usage: $0 -o OUTPUT -i ISSUER -s SERIAL [-n] [-r SIGNER] [-k SIGNKEY]" >&2
    echo "       $0 -o OUTPUT -i ISSUER -c CERT [-n] [-r SIGNER] [-k SIGNKEY]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         prints this message" >&2
    echo "  -o OUTPUT  output file to write to" >&2
    echo "  -i ISSUER  issuer to query" >&2
    echo "  -c CERT    certificate to grab the serial from" >&2
    echo "  -s SERIAL  serial to use (in 0xNNNN format)" >&2
    echo "  -r SIGNER  certificate used to sign the request" >&2
    echo "  -k SIGNKEY key to sign the OCSP request with" >&2
    echo "  -n         add a nonce" >&2
}

OUTPUT=
ISSUER=
CERT=
SERIAL=
SIGNER=
SIGNKEY=
NONCE=-no_nonce
while getopts "o:i:c:s:r:k:nh" opt; do
    case "$opt" in
        o)
            OUTPUT="${OPTARG}"
            ;;
        i)
            ISSUER="${OPTARG}"
            ;;
        c)
            CERT="${OPTARG}"
            ;;
        s)
            SERIAL="${OPTARG}"
            ;;
        r)
            SIGNER="${OPTARG}"
            ;;
        k)
            SIGNKEY="${OPTARG}"
            ;;
        n)
            NONCE=-nonce
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done

if [ -z "$OUTPUT" ] ||
   [ -z "$ISSUER" ]; then
    usage
    exit 1
fi

if [ -z "$CERT" ] &&
   [ -z "$SERIAL" ]; then
    echo "ERROR: either -c CERT or -s SERIAL must be specified" >&2
    exit 1
fi

if [ ! -z "$CERT" ] &&
   [ ! -z "$SERIAL" ]; then
    echo "ERROR: only specify -c CERT or -s SERIAL, not both" >&2
    exit 1
fi

if [ "$SIGNER" ] && [ -z "$SIGNKEY" ]; then
    echo "ERROR: both -r SIGNER and -k SIGNKEY options are needed" >&2
    exit 1
fi

if [ -z "$SIGNER" ] && [ "$SIGNKEY" ]; then
    echo "ERROR: both -r SIGNER and -k SIGNKEY options are needed" >&2
    exit 1
fi

if [ -z "$SERIAL" ]; then
    SERIAL="$(openssl x509 -serial -noout -in "$CERT")"
    if [ $? -ne 0 ]; then
        echo "ERROR: failed to read \`$CERT\`" >&2
        exit 1
    fi
    SERIAL="0x$(echo "$SERIAL" | sed -r 's/serial ?= ?//')"
fi

if [ "$SIGNER" ]; then
    openssl ocsp -issuer "$ISSUER" -serial "$SERIAL" -signer "$SIGNER" -signkey "$SIGNKEY" $NONCE -reqout "$OUTPUT"
else
    openssl ocsp -issuer "$ISSUER" -serial "$SERIAL" $NONCE -reqout "$OUTPUT"
fi
