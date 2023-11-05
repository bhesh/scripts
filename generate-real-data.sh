#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
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

for site in "${WEBSITES[@]}"; do
    echo "Getting data from $site"
    "${SRC_DIR}/generate-real-ocsp.sh" -H $site -p 443 -s $site
done
