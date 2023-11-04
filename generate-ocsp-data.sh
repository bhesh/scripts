#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${SRC_DIR}/out"
WEBSITES=(
    google.com
    facebook.com
    twitter.com
    baidu.com
    wikipedia.com
    yahoo.com
    yandex.ru
    whatsapp.com
    amazon.com
    tiktok.com
    reddit.com
    linkedin.com
    office.com
    openai.com
    netflix.com
    ebay.com
    github.com
)

if [ ! -d "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

# Download certs
echo "Downloading certificates"
for site in "${WEBSITES[@]}"; do
    chain="$("${SRC_DIR}/grab-tls-certs.sh" -H $site -p 443 -s $site)"
    subjects="$(while openssl x509 -subject_hash -noout; do :; done <<<"${chain}" 2>/dev/null)"
    filename=($subjects)
    count=0
    while openssl x509 -out "${OUT_DIR}/${filename[${count}]}.pem"; do
        count=$((count + 1))
    done <<<"${chain}" 2>/dev/null
done

# Build and send ocsp requests
echo "Sending OCSP requests"
for pem in "${OUT_DIR}"/*.pem; do
    issuer="$(openssl x509 -issuer_hash -noout -in "${pem}").pem"
    if [ -f "${OUT_DIR}/$issuer" ]; then
        # Build OCSP request
        "${SRC_DIR}/make-ocsp-request.sh" -o "${pem/.pem/-ocsp-req.der}" -i "${OUT_DIR}/$issuer" -c "$pem"

        # Send OCSP request
        "${SRC_DIR}/send-ocsp-request.sh" -o "${pem/.pem/-ocsp-res.der}" -c "$pem" -r "${pem/.pem/-ocsp-req.der}"
    fi
done
