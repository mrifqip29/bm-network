# Bawang Merah Network - REST API (v2.0)

REST API server for interacting with the Bawang Merah (Shallot) Supply Chain Blockchain Network built on Hyperledger Fabric.

## Overview

This API provides endpoints for user management, authentication, and blockchain operations (query/invoke) across four participating organizations:
- **Petani** (Farmers)
- **Penangkar** (Breeders)
- **Pengumpul** (Collectors)
- **Pedagang** (Traders)

## Features

- 🔐 **User Authentication** - JWT-based authentication with role-based access control
- 👥 **User Management** - Register, login, logout, and profile management
- 🔗 **Blockchain Integration** - Query and invoke chaincode functions on Hyperledger Fabric
- 📦 **MongoDB Integration** - User data persistence
- 📚 **API Documentation** - Interactive Swagger UI documentation
- 🐳 **Docker Support** - Containerized deployment with Docker Compose
- 🔑 **Wallet Management** - Organization-specific identity wallets

## Tech Stack

- **Runtime**: Node.js 12
- **Framework**: Express.js 4.17.1
- **Blockchain**: Hyperledger Fabric SDK (fabric-network 2.2.2, fabric-client 1.4.17)
- **Database**: MongoDB 5.0
- **Authentication**: JWT (JSON Web Tokens)
- **API Documentation**: Swagger (swagger-ui-express)
- **Container**: Docker & Docker Compose

## Prerequisites

- Node.js v12.x or higher
- Docker and Docker Compose (for containerized deployment)
- MongoDB (if running locally without Docker)
- **Hyperledger Fabric network must be running** (including CA servers)
- **Certificate Authority (CA) servers** must be accessible on ports:
  - Penangkar: 7054
  - Petani: 8054
  - Orderer: 9054
  - Pengumpul: 10054
  - Pedagang: 11054

## Installation

### 1. Clone the repository

```bash
cd api-2.0
```

### 2. Install dependencies

```bash
npm install
# or
yarn install
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
PORT=4000
MONGO_URL=mongodb://localhost:27017/bawangmerah
JWT_SECRET=your_secret_key_here
```

### 4. Configuration Files

Ensure the following configuration files are present in the `config/` directory:
- `constants.json` - General application constants
- `connection-petani.json` - Petani organization connection profile
- `connection-penangkar.json` - Penangkar organization connection profile
- `connection-pengumpul.json` - Pengumpul organization connection profile
- `connection-pedagang.json` - Pedagang organization connection profile

## Running the Application

### Step 1: Start the Fabric Network (REQUIRED)

Before running the API, you **must** start the Hyperledger Fabric network including CA servers:

```bash
# From the project root directory
cd ../artifacts/channel/create-certificate-with-ca
docker-compose up -d

# Verify CA servers are running
docker ps | grep ca
```

You should see CA containers running on ports 7054, 8054, 9054, 10054, and 11054.

### Step 2: Start the API Server

#### Development Mode (Local)

```bash
cd api-2.0
npm run dev
```

#### Production Mode (Local)

```bash
cd api-2.0
node app.js
```

#### Docker Compose (Recommended)

```bash
cd api-2.0
docker-compose up -d
```

This will start:
- API server on port 4000
- MongoDB on port 27017

## API Endpoints

### User Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register new user | No |
| POST | `/login` | User login | No |
| GET | `/logout` | User logout | No |
| GET | `/user` | Get current user info | Yes |

### Blockchain Operations

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/sc/channels/:channelName/chaincodes/:chaincodeName` | Query chaincode | No |
| POST | `/sc/channels/:channelName/chaincodes/:chaincodeName` | Invoke chaincode | Yes |

### Documentation

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api-docs` | Swagger UI documentation |

## API Usage Examples

### Register a User

```bash
curl -X POST http://localhost:4000/register \
  -H "Content-Type: application/json" \
  -d '{
    "nama": "John Doe",
    "username": "johndoe",
    "password": "SecurePass123",
    "orgName": "Petani"
  }'
```

### Login

```bash
curl -X POST http://localhost:4000/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "password": "SecurePass123",
    "orgName": "Petani"
  }'
```

### Query Chaincode

```bash
curl -X GET "http://localhost:4000/sc/channels/mychannel/chaincodes/bawangmerah_cc?fcn=QueryAllBenih&args=[]&peer=peer0.petani.example.com"
```

### Invoke Chaincode (Requires Authentication)

```bash
curl -X POST http://localhost:4000/sc/channels/mychannel/chaincodes/bawangmerah_cc \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "fcn": "CreateBenih",
    "peers": ["peer0.penangkar.example.com"],
    "args": [{
      "umurBenih": "2 bulan",
      "umurPanen": "2 hari",
      "varietas": "Bima Brebes",
      "lamaPenyimpanan": "1 minggu",
      "kuantitasBenihKg": 4.2
    }]
  }'
```

## Project Structure

```
api-2.0/
├── app/                      # Core blockchain interaction modules
│   ├── helper.js            # Fabric SDK helper functions
│   ├── invoke.js            # Chaincode invoke functions
│   ├── query.js             # Chaincode query functions
│   ├── Listeners.js         # Event listeners
│   └── ...
├── config/                   # Configuration files
│   ├── constants.json       # Application constants
│   └── connection-*.json    # Fabric connection profiles
├── controllers/             # Request handlers
│   ├── user.controller.js   # User management logic
│   └── sc.controller.js     # Chaincode operations logic
├── middleware/              # Express middleware
│   └── middleware.js        # JWT authentication middleware
├── models/                  # Database models
│   └── user.model.js        # User schema
├── routes/                  # API routes
│   ├── user.js             # User routes
│   └── sc.js               # Smart contract routes
├── *-wallet/               # Organization wallets (auto-generated)
│   ├── petani-wallet/
│   ├── penangkar-wallet/
│   ├── pengumpul-wallet/
│   └── pedagang-wallet/
├── app.js                   # Main application entry point
├── Dockerfile              # Docker image configuration
├── docker-compose.yml      # Docker Compose setup
├── package.json            # Dependencies and scripts
└── README.md               # This file
```

## Organizations

The network supports four organizations:

1. **Petani** (Farmers) - Primary producers of shallots
2. **Penangkar** (Breeders) - Seed producers and breeders
3. **Pengumpul** (Collectors) - Collect produce from farmers
4. **Pedagang** (Traders) - Distribute to markets

Each organization has its own:
- Connection profile (`connection-{orgName}.json`)
- Wallet directory (`{orgName}-wallet/`)
- Peer nodes in the Fabric network

## Authentication & Authorization

The API uses JWT (JSON Web Token) for authentication:

1. Register/Login to receive a JWT token
2. Include the token in the `Authorization` header for protected endpoints:
   ```
   Authorization: Bearer YOUR_JWT_TOKEN
   ```
3. Token expiration is configured in `constants.json` (default: 36000 seconds = 10 hours)

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | API server port | 4000 |
| `MONGO_URL` | MongoDB connection string | mongodb://localhost:27017/bawangmerah |
| `JWT_SECRET` | Secret key for JWT signing | (required) |

## Swagger Documentation

Interactive API documentation is available at:
```
http://localhost:4000/api-docs
```

## Troubleshooting

### Error: "connect ECONNREFUSED 127.0.0.1:8054" (or other CA ports)

This is the most common error when registering users. It means the Certificate Authority (CA) servers are not running.

**Solution:**

```bash
# 1. Check if CA servers are running
docker ps | grep ca

# 2. If not running, start them from the artifacts directory
cd ../artifacts/channel/create-certificate-with-ca
docker-compose up -d

# 3. Wait a few seconds, then verify all CAs are running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep ca

# Expected output should show:
# - ca.penangkar.example.com (port 7054)
# - ca.petani.example.com (port 8054)
# - ca_orderer (port 9054)
# - ca.pengumpul.example.com (port 10054)
# - ca.pedagang.example.com (port 11054)

# 4. Now try registering again
```

**Quick Verification:**

```bash
# Test if CA is accessible
curl -k https://localhost:8054/cainfo

# Should return CA information in JSON format
```

### Connection Issues

If you encounter connection issues with the Fabric network:
1. **Ensure the Fabric network is running** (peers, orderers, CAs)
2. Check connection profile files in `config/` directory match your network setup
3. Verify peer addresses and TLS certificates are correct
4. Ensure all required ports are not blocked by firewall

### Wallet Issues

If identity/wallet errors occur:
1. Ensure wallet directories exist and have proper permissions
2. Re-register the user to regenerate identity files
3. Check that the CA (Certificate Authority) is accessible
4. Verify the admin identity exists in the wallet

### MongoDB Issues

If database connection fails:
1. Verify MongoDB is running: `docker ps | grep mongo`
2. Check `MONGO_URL` environment variable
3. Ensure MongoDB is accessible from the API container (if using Docker)
4. Test connection: `mongosh mongodb://localhost:27017/bawangmerah`

### Network Ports

Ensure these ports are available and not in use:

| Service | Port | Container |
|---------|------|-----------|
| API Server | 4000 | bm-api-2.0 |
| MongoDB | 27017 | bm-mongo-2.0 |
| CA Penangkar | 7054 | ca.penangkar.example.com |
| CA Petani | 8054 | ca.petani.example.com |
| CA Orderer | 9054 | ca_orderer |
| CA Pengumpul | 10054 | ca.pengumpul.example.com |
| CA Pedagang | 11054 | ca.pedagang.example.com |

Check for port conflicts:
```bash
lsof -i :4000  # Check if API port is in use
lsof -i :8054  # Check if CA Petani port is in use
```

## Development

### Watch Mode

```bash
npm run dev
```

Uses nodemon for automatic server restart on file changes.

### Adding New Routes

1. Create controller in `controllers/`
2. Define routes in `routes/`
3. Add Swagger documentation using JSDoc comments
4. Register routes in `app.js`

## Contributing

1. Follow existing code style
2. Add JSDoc comments for new functions
3. Update Swagger documentation for new endpoints
4. Test thoroughly before submitting

## License

ISC

## Contact

**SEIS IPB University**
- Website: https://cs.ipb.ac.id
- Production API: https://bm-network.rfq.my.id

## Related Projects

- Main Network: `../artifacts/` - Hyperledger Fabric network configuration
- Chaincode: `../artifacts/src/github.com/bawangmerah/go/` - Smart contract implementation
- Go API: `../api-go/` - Alternative API implementation in Go

