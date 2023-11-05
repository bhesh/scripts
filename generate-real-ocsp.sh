#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="out"

usage() {
    echo "Downloads the certificate chain of a TLS connection, generates OCSP requests, and queries the responder(s)" >&2
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
            SNI="-s ${OPTARG}"
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

if [ ! -d "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

CERT_CHAIN=()

chain="$("${SRC_DIR}/grab-tls-certs.sh" -H "$HOST" -p "$PORT" $SNI)"
subjects="$(while openssl x509 -subject_hash -noout; do :; done <<<"${chain}" 2>/dev/null)"
filename=($subjects)
count=0
while openssl x509 -out "${OUT_DIR}/${filename[${count}]}.pem"; do
    CERT_CHAIN+=("${OUT_DIR}/${filename[${count}]}.pem")
    count=$((count + 1))
done <<<"${chain}" 2>/dev/null
for cert in "${CERT_CHAIN[@]}"; do
    issuer="$(openssl x509 -issuer_hash -noout -in "${cert}").pem"
    if [ -f "${OUT_DIR}/$issuer" ]; then
        # Build OCSP request
        "${SRC_DIR}/make-ocsp-request.sh" -o "${cert/.pem/-ocsp-req.der}" -i "${OUT_DIR}/$issuer" -c "$cert"
        "${SRC_DIR}/make-ocsp-request.sh" -o "${cert/.pem/-ocsp-nonce-req.der}" -i "${OUT_DIR}/$issuer" -c "$cert" -n

        # Send OCSP request
        "${SRC_DIR}/send-ocsp-request.sh" -o "${cert/.pem/-ocsp-res.der}" -c "$cert" -r "${cert/.pem/-ocsp-req.der}"
        "${SRC_DIR}/send-ocsp-request.sh" -o "${cert/.pem/-ocsp-nonce-res.der}" -c "$cert" -r "${cert/.pem/-ocsp-nonce-req.der}"
    fi
done
