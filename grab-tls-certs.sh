#!/bin/bash

usage() {
    echo "Downloads the certificate chain of a TLS connection" >&2
    echo "" >&2
    echo "usage: $0 -H HOST -p PORT [-s SNI]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -H HOST    host or IP to connect to" >&2
    echo "  -p PORT    port to connect to" >&2
    echo "  -s SNI     server name indicator" >&2
}

HOST=
PORT=
SNI=
while getopts "H:p:s:h" opt; do
    case "$opt" in
        H)
            HOST="${OPTARG}"
            ;;
        p)
            PORT="${OPTARG}"
            ;;
        s)
            SNI="-servername {OPTARG}"
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$HOST" ] ||
   [ -z "$PORT" ]; then
    usage
    exit 1
fi

openssl s_client $SNI -connect $HOST:$PORT -showcerts 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'
