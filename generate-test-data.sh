#!/bin/bash

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${SRC_DIR}/out"
CERTS=(
    "rsa 1024 md5"
    "rsa 2048 sha1"
    "rsa 2048 sha256"
    "rsa 3072 sha384"
    "rsa 4096 sha512"
    "dsa x sha1"
    "dsa x sha224"
    "dsa x sha256"
    "ed25519 x sha512"
    "ec secp256k1 sha256"
    "ec secp192r1 sha224"
    "ec secp224r1 sha224"
    "ec secp256r1 sha256"
    "ec secp384r1 sha384"
    "ec secp384r1 sha512"
)

if [ ! -d "${OUT_DIR}" ]; then
    mkdir "${OUT_DIR}"
fi

for params in "${CERTS[@]}"; do
    params=($params)

    echo "================================================================================"
    echo "Making ${params[@]} test data"
    echo "================================================================================"

    ca_subj="/CN=${params[0]}-${params[1]}-${params[2]}-ca"
    ca_key_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ca-key.pem"
    ca_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ca.pem"
    ca_config_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ca.cnf"
    ca_index_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ca-index.txt"
    crl_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ca-crl.pem"

    cert_subj="/CN=${params[0]}-${params[1]}-${params[2]}-crt"
    cert_key_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-crt-key.pem"
    cert_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-crt-req.pem"
    cert_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-crt.pem"

    revoked_subj="/CN=${params[0]}-${params[1]}-${params[2]}-revoked-crt"
    revoked_key_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-crt-key.pem"
    revoked_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-crt-req.pem"
    revoked_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-crt.pem"

    ocsp_subj="/CN=${params[0]}-${params[1]}-${params[2]}-ocsp-crt"
    ocsp_key_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ocsp-crt-key.pem"
    ocsp_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ocsp-crt-req.pem"
    ocsp_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-ocsp-crt.pem"

    good_ocsp_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-good-ocsp-req.der"
    good_ocsp_nonce_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-good-ocsp-nonce-req.der"
    revoked_ocsp_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-ocsp-req.der"
    revoked_ocsp_nonce_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-ocsp-nonce-req.der"
    unknown_ocsp_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-unknown-ocsp-req.der"
    unknown_ocsp_nonce_req_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-unknown-ocsp-nonce-req.der"

    good_ocsp_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-good-ocsp-res.der"
    good_ocsp_nonce_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-good-ocsp-nonce-res.der"
    revoked_ocsp_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-ocsp-res.der"
    revoked_ocsp_nonce_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-revoked-ocsp-nonce-res.der"
    unknown_ocsp_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-unknown-ocsp-res.der"
    unknown_ocsp_nonce_res_file="${OUT_DIR}/${params[0]}-${params[1]}-${params[2]}-unknown-ocsp-nonce-res.der"

    # ca
    sed "s|index.txt|$ca_index_file|" "${SRC_DIR}/openssl.cnf" > "$ca_config_file"
    rm -f "$ca_index_file"*
    touch "$ca_index_file"
    "${SRC_DIR}/make-key.sh" -a "${params[0]}" -p "${params[1]}" > "$ca_key_file"
    "${SRC_DIR}/make-ca.sh" -s "$ca_subj" -k "$ca_key_file" -d "${params[2]}" -n 0x1 -v 3285 > "$ca_file" 

    # good cert
    "${SRC_DIR}/make-key.sh" -a "${params[0]}" -p "${params[1]}" > "$cert_key_file"
    "${SRC_DIR}/make-csr.sh" -s "$cert_subj" -k "$cert_key_file" -d "${params[2]}" > "$cert_req_file"
    "${SRC_DIR}/sign-cert.sh" -f "$ca_config_file" -r "$cert_req_file" -c "$ca_file" -k "$ca_key_file" -s 0x2 -v 1095 > "$cert_file"

    # revoked cert
    "${SRC_DIR}/make-key.sh" -a "${params[0]}" -p "${params[1]}" > "$revoked_key_file"
    "${SRC_DIR}/make-csr.sh" -s "$revoked_subj" -k "$revoked_key_file" -d "${params[2]}" > "$revoked_req_file"
    "${SRC_DIR}/sign-cert.sh" -r "$revoked_req_file" -c "$ca_file" -k "$ca_key_file" -s 0x3 -v 1095 > "$revoked_file"
    "${SRC_DIR}/revoke-cert.sh" -f "$ca_config_file" -c "$ca_file" -k "$ca_key_file" -r "$revoked_file" -d "${params[2]}"
    "${SRC_DIR}/gen-crl.sh" -f "$ca_config_file" -c "$ca_file" -k "$ca_key_file" -d "${params[2]}" -v 365 > "$crl_file"

    # ocsp signing cert
    "${SRC_DIR}/make-key.sh" -a "${params[0]}" -p "${params[1]}" > "$ocsp_key_file"
    "${SRC_DIR}/make-csr.sh" -s "$ocsp_subj" -k "$ocsp_key_file" -d "${params[2]}" > "$ocsp_req_file"
    "${SRC_DIR}/sign-cert.sh" -r "$ocsp_req_file" -c "$ca_file" -k "$ca_key_file" -s 0x4 -v 365 -e v3_ocsp > "$ocsp_file"

    # ocsp requests
    "${SRC_DIR}/make-ocsp-request.sh" -o "$good_ocsp_req_file" -i "$ca_file" -c "$cert_file"
    "${SRC_DIR}/make-ocsp-request.sh" -o "$good_ocsp_nonce_req_file" -i "$ca_file" -c "$cert_file" -n
    "${SRC_DIR}/make-ocsp-request.sh" -o "$revoked_ocsp_req_file" -i "$ca_file" -c "$revoked_file"
    "${SRC_DIR}/make-ocsp-request.sh" -o "$revoked_ocsp_nonce_req_file" -i "$ca_file" -c "$revoked_file" -n
    "${SRC_DIR}/make-ocsp-request.sh" -o "$unknown_ocsp_req_file" -i "$ca_file" -s 0x5
    "${SRC_DIR}/make-ocsp-request.sh" -o "$unknown_ocsp_nonce_req_file" -i "$ca_file" -s 0x5 -n

    # ocsp responses
    "${SRC_DIR}/make-ocsp-response.sh" -o "$good_ocsp_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$good_ocsp_req_file"
    "${SRC_DIR}/make-ocsp-response.sh" -o "$good_ocsp_nonce_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$good_ocsp_nonce_req_file"
    "${SRC_DIR}/make-ocsp-response.sh" -o "$revoked_ocsp_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$revoked_ocsp_req_file"
    "${SRC_DIR}/make-ocsp-response.sh" -o "$revoked_ocsp_nonce_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$revoked_ocsp_nonce_req_file"
    "${SRC_DIR}/make-ocsp-response.sh" -o "$unknown_ocsp_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$unknown_ocsp_req_file"
    "${SRC_DIR}/make-ocsp-response.sh" -o "$unknown_ocsp_nonce_res_file" -f "$ca_index_file" -c "$ca_file" \
        -r "$ocsp_file" -k "$ocsp_key_file" -q "$unknown_ocsp_nonce_req_file"

    # convert ca and crl
    "${SRC_DIR}/encode.sh" -t key -k "${params[0]}" -d -i "$ca_key_file" -o "${ca_key_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t cert -d -i "$ca_file" -o "${ca_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t crl -d -i "$crl_file" -o "${crl_file/.pem/.der}"

    # convert good cert
    "${SRC_DIR}/encode.sh" -t key -k "${params[0]}" -d -i "$cert_key_file" -o "${cert_key_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t req -d -i "$cert_req_file" -o "${cert_req_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t cert -d -i "$cert_file" -o "${cert_file/.pem/.der}"

    # convert revoked cert
    "${SRC_DIR}/encode.sh" -t key -k "${params[0]}" -d -i "$revoked_key_file" -o "${revoked_key_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t req -d -i "$revoked_req_file" -o "${revoked_req_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t cert -d -i "$revoked_file" -o "${revoked_file/.pem/.der}"

    # convert ocsp cert
    "${SRC_DIR}/encode.sh" -t key -k "${params[0]}" -d -i "$ocsp_key_file" -o "${ocsp_key_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t req -d -i "$ocsp_req_file" -o "${ocsp_req_file/.pem/.der}"
    "${SRC_DIR}/encode.sh" -t cert -d -i "$ocsp_file" -o "${ocsp_file/.pem/.der}"

    echo ""
done
