export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_PENANGKAR_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/penangkar.example.com/peers/peer0.penangkar.example.com/tls/ca.crt
export PEER0_PETANI_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/petani.example.com/peers/peer0.petani.example.com/tls/ca.crt
export PEER0_PENGUMPUL_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengumpul.example.com/peers/peer0.pengumpul.example.com/tls/ca.crt
export PEER0_PEDAGANG_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pedagang.example.com/peers/peer0.pedagang.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Penangkar(){
    export CORE_PEER_LOCALMSPID="PenangkarMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PENANGKAR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/penangkar.example.com/users/Admin@penangkar.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Petani(){
    export CORE_PEER_LOCALMSPID="PetaniMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PETANI_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/petani.example.com/users/Admin@petani.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0Pengumpul(){
    export CORE_PEER_LOCALMSPID="PengumpulMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PENGUMPUL_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengumpul.example.com/users/Admin@pengumpul.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

setGlobalsForPeer0Pedagang(){
    export CORE_PEER_LOCALMSPID="PedagangMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PEDAGANG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pedagang.example.com/users/Admin@pedagang.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Penangkar
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-org1/*
    rm -rf ./api-2.0/org1-wallet/*
    rm -rf ./api-2.0/org2-wallet/*
}


joinChannel(){
    setGlobalsForPeer0Penangkar
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    
    setGlobalsForPeer0Petani
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Pengumpul
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Pedagang
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Penangkar
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Petani
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Pengumpul
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Pedagang
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

removeOldCrypto

createChannel
joinChannel
updateAnchorPeers