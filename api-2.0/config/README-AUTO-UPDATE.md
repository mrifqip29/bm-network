# Automated Connection Profile Updates

This directory contains scripts to automatically update connection profiles with the latest TLS certificates.

## How It Works

When you run the CA certificate creation script, it will now automatically update all API connection profiles with the correct:
- Peer TLS CA certificates
- CA server TLS certificates  
- Orderer TLS certificates
- Correct container hostnames (not localhost)

## Usage

### Automatic Update (Recommended)

Simply run the CA creation script as usual:

```bash
cd artifacts/channel/create-certificate-with-ca
./create-certificate-with-ca.sh
```

The script will automatically:
1. Generate all certificates for all organizations
2. Extract the TLS certificates
3. Update all connection profiles in `api-2.0/config/`
4. Display a success message

### Manual Update

If you need to update the connection profiles manually (e.g., after regenerating certificates):

```bash
cd api-2.0/config
./update-connection-profiles.sh
```

## What Gets Updated

The script updates these files:
- `connection-penangkar.json`
- `connection-petani.json`
- `connection-pengumpul.json`
- `connection-pedagang.json`

For each file, it updates:
1. **Peer Configuration:**
   - TLS CA certificate from: `crypto-config/peerOrganizations/{org}/peers/peer0.{org}/tls/ca.crt`
   - URL: `grpcs://peer0.{org}.example.com:{port}`

2. **CA Configuration:**
   - TLS CA certificate from: `crypto-config/peerOrganizations/{org}/ca/ca.{org}.example.com-cert.pem`
   - URL: `https://ca.{org}.example.com:{port}`

3. **Orderer Configuration:**
   - TLS CA certificate from: `crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt`
   - URL: `grpcs://orderer.example.com:7050`

## Troubleshooting

### Script not found error
If you see "update-connection-profiles.sh not found", make sure you're in the correct directory:
```bash
pwd
# Should show: .../bm-network/artifacts/channel/create-certificate-with-ca
```

### Node.js not installed
The update script requires Node.js. Install it if needed:
```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm
```

### Certificate files not found
Ensure certificates are generated first:
```bash
cd artifacts/channel/create-certificate-with-ca
docker-compose up -d  # Start CA servers
./create-certificate-with-ca.sh
```

## Manual Verification

After updating, verify the connection profiles contain correct certificates:

```bash
# Check peer certificate
cat connection-petani.json | grep -A 5 "peer0.petani"

# Check CA certificate  
cat connection-petani.json | grep -A 5 "ca.petani"

# Check orderer certificate
cat connection-petani.json | grep -A 5 "orderer.example"
```

## Integration with Docker

After updating connection profiles, restart the API container to use new configs:

```bash
cd api-2.0
docker-compose restart api-2.0
```

## Notes

- The script automatically escapes newlines for JSON compatibility
- All certificates are in PEM format with `\n` line breaks
- Container hostnames (not localhost) are used for Docker networking
- The orderer configuration is added if it doesn't exist


