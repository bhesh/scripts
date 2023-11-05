#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Signs a certificate given the CSR, CA certificate, and CA key" >&2
    echo "" >&2
    echo "usage: $0 [-f CONFIG] -r CSR -c CACERT -k CAKEY [-s SERIAL] [-v DAYS] [-e EXT]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -f CONFIG  CONFIG file (updates database)" >&2
    echo "  -r CSR     certificate request to sign" >&2
    echo "  -c CACERT  ca to sign the request with" >&2
    echo "  -k CAKEY   key to sign the requet with" >&2
    echo "  -s SERIAL  serial to use (in 0xNNNN format)" >&2
    echo "  -v DAYS    validity of certificate in days" >&2
    echo "  -e EXT     section of CONFIG to use" >&2
}

OPTIONALCONFIG=
CSR=
CACERT=
CAKEY=
SERIAL="-CAcreateserial"
VALIDITY=1095
EXT=
while getopts "f:r:c:k:s:v:e:h" opt; do
    case "$opt" in
        f)
            OPTIONALCONFIG="${OPTARG}"
            ;;
        r)
            CSR="${OPTARG}"
            ;;
        c)
            CACERT="${OPTARG}"
            ;;
        k)
            CAKEY="${OPTARG}"
            ;;
        s)
            SERIAL="-set_serial ${OPTARG}"
            ;;
        v)
            VALIDITY="${OPTARG}"
            ;;
        e)
            EXT="-extensions ${OPTARG}"
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$CSR" ] ||
   [ -z "$CACERT" ] ||
   [ -z "$CAKEY" ] ||
   [ -z "$SERIAL" ] ||
   [ -z "$VALIDITY" ]; then
    usage
    exit 1
fi

CONFIG="${SRC_DIR}/openssl.cnf"
if [ ! -z "$OPTIONALCONFIG" ]; then
    CONFIG="$OPTIONALCONFIG"
fi

CERT="$(openssl x509 -req \
    -in "$CSR" \
    -days "$VALIDITY" \
    -CA "$CACERT" \
    -CAkey "$CAKEY" \
    $SERIAL \
    -extfile "$CONFIG" \
    $EXT)"
OUT=$?
if [ $OUT -ne 0 ]; then
    exit $OUT
fi
if [ "$OPTIONALCONFIG" ]; then
    openssl ca -config "$CONFIG" \
        -cert "$CACERT" \
        -keyfile "$CAKEY" \
        -md md5 \
        -valid <(cat <<<"$CERT")
fi
OUT=$?
if [ $OUT -ne 0 ]; then
    exit $OUT
fi
echo "$CERT"
