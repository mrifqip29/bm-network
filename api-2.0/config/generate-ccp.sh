#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}

ORG=Penangkar
P0PORT=7051
CAPORT=7054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/tlscacerts/tls-localhost-7054-ca-penangkar-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/penangkar.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM )" > connection-penangkar.json

ORG=Petani
P0PORT=8051
CAPORT=8054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/tlscacerts/tls-localhost-8054-ca-petani-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/petani.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-petani.json

ORG=Pengumpul
P0PORT=10051
CAPORT=10054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/tlscacerts/tls-localhost-10054-ca-pengumpul-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/pengumpul.example.com/msp/tlscacerts/ca.crt


echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-pengumpul.json

ORG=Pedagang
P0PORT=11051
CAPORT=11054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/tlscacerts/tls-localhost-11054-ca-pedagang-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/pedagang.example.com/msp/tlscacerts/ca.crt


echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-pedagang.json