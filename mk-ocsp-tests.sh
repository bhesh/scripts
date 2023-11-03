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
    chain="$(openssl s_client -servername "${site}" -connect ${site}:443 -showcerts 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"
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
    issuer="$(openssl x509 -issuer_hash -noout -in "${pem}")"
    serial="$(openssl x509 -serial -noout -in "${pem}" | sed -r 's/serial ?= ?//')"
    url="$(openssl x509 -ocsp_uri -noout -in "${pem}")"
    if [ -f "${OUT_DIR}/${issuer}.pem" ]; then
        # Build OCSP request
        openssl ocsp -issuer "${OUT_DIR}/${issuer}.pem" -serial "0x${serial}" -reqout "${pem/.pem/-ocsp-req}.der"

        # Send OCSP request
        curl --silent -o "${pem/.pem/-ocsp-res}.der" --header 'Content-Type: application/ocsp-request' --data-binary @${pem/.pem/-ocsp-req}.der "$url"
    fi
done
