#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "PEM encodes a DER format file" >&2
    echo "" >&2
    echo "usage: $0 -t TYPE [-k KEY] [-d] [-i INPUT] [-o OUTPUT]" >&2
    echo "" >&2
    echo "Types: key, req, cert, crl" >&2
    echo "Key params: dsa, ec, ed25519, rsa" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -t TYPE    type to convert" >&2
    echo "  -k KEY     key param (only if -t key)" >&2
    echo "  -d         decode PEM to DER instead" >&2
    echo "  -i INPUT   input file" >&2
    echo "  -o OUTPUT  output file" >&2
}

TYPE=
KEY=
ACTION='-inform DER -outform PEM'
INPUT=/dev/fd/0
OUTPUT=/dev/fd/1
while getopts "t:k:di:o:h" opt; do
    case "$opt" in
        t)
            TYPE="${OPTARG}"
            ;;
        k)
            KEY="${OPTARG}"
            ;;
        d)
            ACTION='-inform PEM -outform DER'
            ;;
        i)
            INPUT="${OPTARG}"
            ;;
        o)
            OUTPUT="${OPTARG}"
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

ARG=
if [ "$TYPE" == "key" ]; then
    if [ "$KEY" == "dsa" ]; then
        ARG=dsa
    elif [ "$KEY" == "ec" ]; then
        ARG=ec
    elif [ "$KEY" == "ed25519" ]; then
        ARG=pkey
    elif [ "$KEY" == "rsa" ]; then
        ARG=rsa
    else
        echo "Invalid key type \`$KEY\`" >&2
        exit 1
    fi
elif [ "$TYPE" == "req" ]; then
    ARG=req
elif [ "$TYPE" == "cert" ]; then
    ARG=x509
elif [ "$TYPE" == "crl" ]; then
    ARG=crl
else
    echo "Invalid type \`$TYPE\`" >&2
    exit 1
fi

openssl $ARG $ACTION -in "$INPUT" -out "$OUTPUT"
