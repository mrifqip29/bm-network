# Bawang Merah Blockchain Network

### Original source code by Adhav Pavan

Youtube Channel: https://www.youtube.com/watch?v=SJTdJt6N6Ow&list=PLSBNVhWU6KjW4qo1RlmR7cvvV8XIILub6

## Network Topology

Four Orgs(Peer Orgs)

    - Each Org have one peer(Each Endorsing Peer)
    - Each Org have separate Certificate Authority
    - Each Peer has Current State database as couch db

One Orderer Org

    - Three Orderers
    - One Certificate Authority

## Prerequisites

- Docker and Docker Compose
- Node.js (v14 or higher)
- **Optional:** Hyperledger Fabric binaries (peer, configtxgen, fabric-ca-client) - Can use Docker instead
- Go (for chaincode compilation - only if modifying chaincode)

## Setup and Run Instructions

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd bm-network
```

### Step 2: Start Certificate Authority (CA) Services

Start the CA containers for all organizations:

```bash
cd artifacts/channel/create-certificate-with-ca
docker-compose up -d
cd ../../..
```

### Step 3: Generate Crypto Materials

Create certificates and keys for all organizations (Penangkar, Petani, Pengumpul, Pedagang, and Orderer):

```bash
cd artifacts/channel/create-certificate-with-ca
./create-certificate-with-ca.sh
cd ../../..
```

This script will:
- Enroll CA admins
- Register and enroll peers
- Register and enroll users
- Generate TLS certificates

### Step 4: Generate Channel Artifacts

Create the genesis block and channel configuration.

**Option A: Using Docker (No local Fabric binaries required)**

```bash
cd artifacts/channel
./create-artifacts-docker.sh
cd ../..
```

**Option B: Using local Fabric binaries**

```bash
cd artifacts/channel
./create-artifacts.sh
cd ../..
```

This generates:
- Genesis block for the orderer
- Channel transaction file (mychannel.tx)
- Anchor peer updates for each organization

### Step 5: Start the Blockchain Network

Start all peer nodes, orderer nodes, and CouchDB instances:

```bash
cd artifacts
docker-compose up -d
cd ..
```

Verify all containers are running:

```bash
docker ps
```

You should see:
- 3 orderers (orderer.example.com, orderer2.example.com, orderer3.example.com)
- 4 peers (peer0.penangkar, peer0.petani, peer0.pengumpul, peer0.pedagang)
- 4 CouchDB instances
- 5 CA services

### Step 6: Create Channel and Join Peers

Create the channel and have all peers join it:

```bash
./createChannel.sh
```

This script will:
- Create the channel "mychannel"
- Join all 4 peer organizations to the channel
- Update anchor peers for each organization

### Step 7: Deploy Chaincode

Deploy the Bawang Merah chaincode:

```bash
./deployBawangCC.sh
```

This script performs the complete chaincode lifecycle:
1. Vendor Go dependencies
2. Package the chaincode
3. Install chaincode on all peers
4. Approve chaincode for each organization
5. Commit chaincode definition
6. Initialize the chaincode

### Step 8: Start the API Server

Install dependencies and start the REST API server:

```bash
cd api-2.0
npm install
npm start
```

The API server will start on port 4000 (default).

### Step 9: Test the Network

Register a user and test chaincode transactions using the API endpoints.

Example API endpoints:
- User registration: `POST /users`
- Invoke chaincode: `POST /channels/mychannel/chaincodes/bawangmerah_cc`
- Query chaincode: `GET /channels/mychannel/chaincodes/bawangmerah_cc`

Check the Postman collection in `api-2.0/postman-collection/` for example requests.

## Quick Start (After Initial Setup)

If the network has been set up before, restart it with:

```bash
# Start the network
cd artifacts && docker-compose up -d && cd ..

# Start the API server
cd api-2.0 && npm start
```

## Stopping the Network

To stop all containers:

```bash
cd artifacts
docker-compose down
cd ..
```

To stop and remove all volumes (clean reset):

```bash
cd artifacts
docker-compose down -v
cd ..
```

## Troubleshooting

### `configtxgen: command not found`

If you get this error when running `create-artifacts.sh`, you have two options:

**Option 1: Use the Docker version (Recommended)**
```bash
cd artifacts/channel
./create-artifacts-docker.sh
cd ../..
```

**Option 2: Install Fabric binaries locally**
```bash
# Download Fabric binaries version 2.1.0
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.1.0 1.4.7

# Add to PATH
export PATH=$PATH:$HOME/fabric-samples/bin
echo 'export PATH=$PATH:$HOME/fabric-samples/bin' >> ~/.zshrc
source ~/.zshrc

# Verify installation
configtxgen --version
```

### Check Container Logs

```bash
docker logs <container-name>
```

### Check Network Status

```bash
docker ps
docker network ls
```

### Clean Up and Restart

If you encounter issues, clean up and restart from Step 2:

```bash
# Stop all containers
docker-compose -f artifacts/docker-compose.yaml down -v
docker-compose -f artifacts/channel/create-certificate-with-ca/docker-compose.yaml down -v

# Remove crypto materials
sudo rm -rf artifacts/channel/crypto-config/*
rm -rf channel-artifacts/*

# Start fresh from Step 2
```
