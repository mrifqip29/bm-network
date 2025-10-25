#!/bin/bash

# Script to automatically update connection profile JSON files with latest TLS certificates
# This should be run after creating certificates with create-certificate-with-ca.sh

set -e

echo "======================================"
echo "Updating Connection Profiles"
echo "======================================"

# Paths
CRYPTO_PATH="${PWD}/../../artifacts/channel/crypto-config"
CONFIG_PATH="${PWD}"

# Function to convert certificate to JSON-escaped string
cert_to_json() {
    local cert_file=$1
    if [ ! -f "$cert_file" ]; then
        echo "ERROR: Certificate file not found: $cert_file"
        return 1
    fi
    # Read cert, escape newlines for JSON (works on both macOS and Linux)
    awk '{printf "%s\\n", $0}' "$cert_file"
}

# Function to update connection profile with Node.js
update_connection_profile() {
    local org_name=$1
    local org_lower=$(echo "$org_name" | tr '[:upper:]' '[:lower:]')
    local config_file="${CONFIG_PATH}/connection-${org_lower}.json"
    local peer_port=$2
    local ca_port=$3
    
    echo ""
    echo "Updating $org_name connection profile..."
    
    # Get certificates
    local peer_tls_cert=$(cert_to_json "${CRYPTO_PATH}/peerOrganizations/${org_lower}.example.com/peers/peer0.${org_lower}.example.com/tls/ca.crt")
    local ca_tls_cert=$(cert_to_json "${CRYPTO_PATH}/peerOrganizations/${org_lower}.example.com/ca/ca.${org_lower}.example.com-cert.pem")
    local orderer_tls_cert=$(cert_to_json "${CRYPTO_PATH}/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt")
    
    # Use Node.js to update JSON (more reliable than jq for complex updates)
    node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('${config_file}', 'utf8'));

// Update peer TLS cert
if (config.peers && config.peers['peer0.${org_lower}.example.com']) {
    config.peers['peer0.${org_lower}.example.com'].url = 'grpcs://peer0.${org_lower}.example.com:${peer_port}';
    config.peers['peer0.${org_lower}.example.com'].tlsCACerts = {
        pem: '${peer_tls_cert}'
    };
    config.peers['peer0.${org_lower}.example.com'].grpcOptions = {
        'ssl-target-name-override': 'peer0.${org_lower}.example.com',
        'hostnameOverride': 'peer0.${org_lower}.example.com'
    };
}

// Update CA TLS cert
if (config.certificateAuthorities && config.certificateAuthorities['ca.${org_lower}.example.com']) {
    config.certificateAuthorities['ca.${org_lower}.example.com'].url = 'https://ca.${org_lower}.example.com:${ca_port}';
    config.certificateAuthorities['ca.${org_lower}.example.com'].tlsCACerts = {
        pem: '${ca_tls_cert}'
    };
}

// Update or add orderer
if (!config.orderers) {
    config.orderers = {};
}
config.orderers['orderer.example.com'] = {
    url: 'grpcs://orderer.example.com:7050',
    tlsCACerts: {
        pem: '${orderer_tls_cert}'
    },
    grpcOptions: {
        'ssl-target-name-override': 'orderer.example.com'
    }
};

fs.writeFileSync('${config_file}', JSON.stringify(config, null, 4));
console.log('✓ Updated ${org_name} connection profile');
    "
}

# Update all organization connection profiles
echo ""
echo "Extracting certificates and updating connection profiles..."

update_connection_profile "Penangkar" "7051" "7054"
update_connection_profile "Petani" "8051" "8054"
update_connection_profile "Pengumpul" "10051" "10054"
update_connection_profile "Pedagang" "11051" "11054"

echo ""
echo "======================================"
echo "✓ All connection profiles updated!"
echo "======================================"
echo ""
echo "Updated files:"
echo "  - connection-penangkar.json"
echo "  - connection-petani.json"
echo "  - connection-pengumpul.json"
echo "  - connection-pedagang.json"
echo ""

