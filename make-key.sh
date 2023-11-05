#!/bin/bash

usage() {
    echo "Generates a key" >&2
    echo "" >&2
    echo "usage: $0 -a ALGO [-p PARAM]" >&2
    echo "" >&2
    echo "Algorithms: rsa, ec, dsa, ed25519" >&2
    echo "" >&2
    echo "OPTIONS" >&2
    echo "  -h         print this message" >&2
    echo "  -a ALGO    algorithm to use" >&2
    echo "  -p PARAM   parameters for the algorithm" >&2
}

ALGO=
PARAM=
while getopts "a:p:h" opt; do
    case "$opt" in
        a)
            ALGO="${OPTARG}"
            ;;
        p)
            PARAM="${OPTARG}"
            ;;
        *)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$ALGO" ]; then
    usage
    exit 1
fi

if [ "$ALGO" == "rsa" ]; then
    if [ -z "$PARAM" ]; then
        echo "ERROR: rsa requires the bits as a parameter" >&2
        exit 1
    fi
    openssl genrsa "$PARAM"
    exit $?
elif [ "$ALGO" == "ec" ]; then
    if [ -z "$PARAM" ]; then
        echo "ERROR: ec requires the curve as a parameter" >&2
        exit 1
    fi
    openssl ecparam -genkey -noout -name "$PARAM"
    if [ $? -ne 0 ]; then
        echo "ERROR: use \`openssl ecparam -list_curves\` for param values" >&2
        exit 1
    fi
elif [ "$ALGO" == "dsa" ]; then
    openssl dsaparam -genkey -noout 1024
    exit $?
elif [ "$ALGO" == "ed25519" ]; then
    openssl genpkey -algorithm ed25519
    exit $?
else
    echo "ERROR: unknown algorithm \`$ALGO\`" >&2
    exit 1
fi
