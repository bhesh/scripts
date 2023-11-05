#!/bin/bash

usage() {
    echo "Sends an OCSP request" >&2
    echo "" >&2
    echo "usage: $0 -o OUTPUT -c CERT -r REQUEST [-G]" >&2
    echo "       $0 -o OUTPUT -u URL -r REQUEST [-G]" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -o OUTPUT  output file to write to" >&2
    echo "  -c CERT    grabs the OCSP URL from the certificate" >&2
    echo "  -u URL     URL to send the OCSP request" >&2
    echo "  -r REQUEST request to send" >&2
    echo "  -G         sends the request via HTTP GET" >&2
}

OUTPUT=
CERT=
URL=
REQUEST=
GET=0
while getopts "o:c:u:r:Gh" opt; do
    case "$opt" in
        o)
            OUTPUT="${OPTARG}"
            ;;
        c)
            CERT="${OPTARG}"
            ;;
        u)
            URL="${OPTARG}"
            ;;
        r)
            REQUEST="${OPTARG}"
            ;;
        G)
            GET=1
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$OUTPUT" ] || [ -z "$REQUEST" ]; then
    usage
    exit 1
fi

if [ -z "$CERT" ] && [ -z "$URL" ]; then
    usage
    exit 1
fi

if [ "$CERT" ] && [ "$URL" ]; then
    echo "ERROR: only specify either -c CERT or -u URL, not both" >&2
    exit 1
fi

if [ -z "$URL" ]; then
    URL="$(openssl x509 -ocsp_uri -noout -in "$CERT")"
    if [ $? -ne 0 ]; then
        echo "ERROR: failed to read \`$CERT\`" >&2
        exit 1
    fi
fi

if [ $GET -eq 0 ]; then
    curl --silent -o "$OUTPUT" --header 'Content-Type: application/ocsp-request' --data-binary @"$REQUEST" "$URL"
    exit $?
else
    uri="$(base64 -w0 "$REQUEST" | sed 's/+/%2B/g;s|/|%2F|g;s/=/%3D/g')"
    curl --silent -o "$OUTPUT" --header 'Content-Type: application/ocsp-request' "${URL}/$uri"
    exit $?
fi
