#!/bin/bash

# Clean all data and reset network

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo ""
echo "============================================"
echo "  Cleaning Fabric Network Data"
echo "============================================"
echo ""

log_warning "This will remove all network data including:"
log_warning "  - All certificates"
log_warning "  - Channel artifacts"
log_warning "  - Ledger data"
log_warning "  - Docker volumes"
log_warning "  - Wallet identities"
echo ""

read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

log_info "Stopping all services..."
./stop-all.sh

log_info "Removing Docker volumes..."
cd "$SCRIPT_DIR/api-2.0" && docker-compose down -v || true
cd "$SCRIPT_DIR/artifacts" && docker-compose down -v || true
cd "$SCRIPT_DIR/artifacts/channel/create-certificate-with-ca" && docker-compose down -v || true

log_info "Removing generated files..."
rm -rf "$SCRIPT_DIR/artifacts/channel/crypto-config/"* 2>/dev/null || true
rm -f "$SCRIPT_DIR/artifacts/channel/"*.block 2>/dev/null || true
rm -f "$SCRIPT_DIR/artifacts/channel/"*.tx 2>/dev/null || true
rm -f "$SCRIPT_DIR/artifacts/.network-running" 2>/dev/null || true
rm -f "$SCRIPT_DIR/artifacts/.setup-complete" 2>/dev/null || true

log_info "Removing wallet identities (keeping directory structure)..."
find "$SCRIPT_DIR/api-2.0" -name "*.id" -type f -delete 2>/dev/null || true

log_info "Removing chaincode packages..."
rm -f "$SCRIPT_DIR/"*.tar.gz 2>/dev/null || true

echo ""
log_info "✓ Cleanup complete"
echo ""
echo "Network has been reset to clean state"
echo ""
echo "To start fresh:"
echo "  ./start-all.sh"
echo ""

