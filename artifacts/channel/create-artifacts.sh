
# Delete existing artifacts
rm genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./mychannel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for PenangkarMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PenangkarMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PenangkarMSP

echo "#######    Generating anchor peer update for PetaniMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PetaniMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PetaniMSP

echo "#######    Generating anchor peer update for PengumpulMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PengumpulMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PengumpulMSP

echo "#######    Generating anchor peer update for PedagangMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PedagangMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PedagangMSP