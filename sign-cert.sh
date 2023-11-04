#!/bin/bash

usage() {
    echo "Signs a certificate given the CSR, CA certificate, and CA key" >&2
    echo "" >&2
    echo "usage: $0 -r CSR -c CACERT -k CAKEY [-v DAYS]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         prints this message" >&2
    echo "  -r CSR     certificate request to sign" >&2
    echo "  -c CACERT  ca to sign the request with" >&2
    echo "  -k CAKEY   key to sign the requet with" >&2
    echo "  -v DAYS    validity of certificate in days" >&2
}

CSR=
CACERT=
CAKEY=
VALIDITY=1095
while getopts "r:c:k:v:h" opt; do
    case "$opt" in
        r)
            CSR="${OPTARG}"
            ;;
        c)
            CACERT="${OPTARG}"
            ;;
        k)
            CAKEY="${OPTARG}"
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

if [ -z "$CSR" ] ||
   [ -z "$CACERT" ] ||
   [ -z "$CAKEY" ] ||
   [ -z "$VALIDITY" ]; then
    usage
    exit 1
fi

openssl x509 -req -in "$CSR" -days "$VALIDITY" -CA "$CACERT" -CAkey "$CAKEY" -CAcreateserial
