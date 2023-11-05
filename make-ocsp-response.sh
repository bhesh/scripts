#!/bin/bash

usage() {
    echo "Generates an OCSP response" >&2
    echo "" >&2
    echo "usage: $0 -o OUTPUT -f INDEX -c CACERT -r SIGNER -k SIGNKEY -q REQ [-v DAYS]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -o OUTPUT  output file to write to" >&2
    echo "  -f INDEX   index file to query" >&2
    echo "  -c CACERT  certificate to grab the serial from" >&2
    echo "  -r SIGNER  certificate used to sign the request" >&2
    echo "  -k SIGNKEY key to sign the OCSP response with" >&2
    echo "  -q REQ     OCSP request to respond to" >&2
    echo "  -v DAYS    validity of the OCSP response in days" >&2
}

OUTPUT=
INDEX=
CACERT=
SIGNER=
SIGNKEY=
REQ=
VALIDITY=365
while getopts "o:f:c:r:k:q:v:h" opt; do
    case "$opt" in
        o)
            OUTPUT="${OPTARG}"
            ;;
        f)
            INDEX="${OPTARG}"
            ;;
        c)
            CACERT="${OPTARG}"
            ;;
        r)
            SIGNER="${OPTARG}"
            ;;
        k)
            SIGNKEY="${OPTARG}"
            ;;
        q)
            REQ="${OPTARG}"
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

if [ -z "$OUTPUT" ] ||
   [ -z "$INDEX" ] ||
   [ -z "$CACERT" ] ||
   [ -z "$SIGNER" ] ||
   [ -z "$SIGNKEY" ] ||
   [ -z "$REQ" ] ||
   [ -z "$VALIDITY" ]; then
    usage
    exit 1
fi

openssl ocsp \
    -respout "$OUTPUT" \
    -index "$INDEX" \
    -CA "$CACERT" \
    -rsigner "$SIGNER" \
    -rkey "$SIGNKEY" \
    -reqin "$REQ" \
    -ndays "+$VALIDITY"
exit $?
