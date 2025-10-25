#!/bin/bash

# Stop all Fabric network components

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
echo "  Stopping Fabric Network"
echo "============================================"
echo ""

log_info "Stopping API server..."
cd "$SCRIPT_DIR/api-2.0" && docker-compose down || true

log_info "Stopping network components..."
cd "$SCRIPT_DIR/artifacts" && docker-compose down || true

log_info "Stopping CA services..."
cd "$SCRIPT_DIR/artifacts/channel/create-certificate-with-ca" && docker-compose down || true

# Remove running marker
rm -f "$SCRIPT_DIR/artifacts/.network-running"

echo ""
log_info "✓ All services stopped"
echo ""
echo "To remove all data and start fresh:"
echo "  ./clean-all.sh"
echo ""
echo "To restart the network:"
echo "  ./start-all.sh"
echo ""

