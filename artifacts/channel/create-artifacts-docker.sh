#!/bin/bash

# This script uses Docker to run configtxgen, so you don't need to install Fabric binaries locally

# Delete existing artifacts
rm -f genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo "Channel Name: $CHANNEL_NAME"

# Docker image for Fabric tools
FABRIC_TOOLS_IMAGE="hyperledger/fabric-tools:2.1"

# Helper function to run configtxgen in Docker
configtxgen() {
    docker run --rm \
        -v ${PWD}:/work \
        -w /work \
        ${FABRIC_TOOLS_IMAGE} \
        configtxgen "$@"
}

echo "Generating System Genesis block..."
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL -outputBlock ./genesis.block

echo "Generating channel configuration block..."
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for PenangkarMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PenangkarMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PenangkarMSP

echo "#######    Generating anchor peer update for PetaniMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PetaniMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PetaniMSP

echo "#######    Generating anchor peer update for PengumpulMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PengumpulMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PengumpulMSP

echo "#######    Generating anchor peer update for PedagangMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PedagangMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PedagangMSP

echo "Channel artifacts generated successfully!"

