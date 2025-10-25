#!/bin/bash

# One-Command Fabric Network Startup Script
# This script orchestrates all the setup steps in the correct order

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP $1]${NC} $2"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    log_info "Docker is running ✓"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Cleanup function
cleanup() {
    log_warning "Cleaning up existing network..."
    
    # Stop and remove all containers
    cd "$SCRIPT_DIR/api-2.0" && docker-compose down 2>/dev/null || true
    cd "$SCRIPT_DIR/artifacts" && docker-compose down 2>/dev/null || true
    cd "$SCRIPT_DIR/artifacts/channel/create-certificate-with-ca" && docker-compose down 2>/dev/null || true
    cd "$SCRIPT_DIR"
    
    log_info "Cleanup complete"
}

# Main script
main() {
    echo ""
    echo "============================================"
    echo "  Hyperledger Fabric Network Startup"
    echo "============================================"
    echo ""
    
    # Check prerequisites
    check_docker
    
    # Ask if user wants to clean up first
    if [ -f "$SCRIPT_DIR/artifacts/.network-running" ]; then
        log_warning "Network appears to be already running"
        read -p "Do you want to clean up and restart? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cleanup
        fi
    fi
    
    # ============================================
    # Step 1: Start Certificate Authorities
    # ============================================
    log_step "1/9" "Starting Certificate Authority services..."
    cd "$SCRIPT_DIR/artifacts/channel/create-certificate-with-ca"
    docker-compose up -d
    log_info "Waiting for CA services to be ready (20s)..."
    sleep 20
    log_info "✓ CA services started"
    
    # ============================================
    # Step 2: Generate Certificates
    # ============================================
    log_step "2/9" "Generating certificates for all organizations..."
    cd "$SCRIPT_DIR/artifacts/channel/create-certificate-with-ca"
    bash ./create-certificate-with-ca.sh
    log_info "✓ Certificates generated"
    log_info "✓ API connection profiles updated automatically"
    
    # ============================================
    # Step 3: Generate Channel Artifacts
    # ============================================
    log_step "3/9" "Generating channel artifacts..."
    cd "$SCRIPT_DIR/artifacts/channel"
    
    if command_exists configtxgen; then
        log_info "Using local Fabric binaries..."
        bash ./create-artifacts.sh
    else
        log_info "Using Docker for artifact generation..."
        bash ./create-artifacts-docker.sh
    fi
    
    log_info "✓ Channel artifacts generated"
    
    # ============================================
    # Step 4: Start Network Components
    # ============================================
    log_step "4/9" "Starting orderers, peers, and CouchDB..."
    cd "$SCRIPT_DIR/artifacts"
    docker-compose up -d
    log_info "Waiting for network components to start (20s)..."
    sleep 20
    log_info "✓ Network components started"
    
    # ============================================
    # Step 5: Create Channel
    # ============================================
    log_step "5/9" "Creating and joining channel..."
    cd "$SCRIPT_DIR"
    bash ./createChannel.sh
    log_info "✓ Channel created and peers joined"
    
    # ============================================
    # Step 6: Deploy Chaincode
    # ============================================
    log_step "6/9" "Deploying Bawang Merah chaincode..."
    cd "$SCRIPT_DIR"
    bash ./deployBawangCC.sh
    log_info "✓ Chaincode deployed and initialized"
    
    # ============================================
    # Step 7: Start API Server
    # ============================================
    log_step "7/9" "Starting REST API server..."
    cd "$SCRIPT_DIR/api-2.0"
    docker-compose up -d
    log_info "Waiting for API to start (15s)..."
    sleep 15
    log_info "✓ API server started"
    
    # ============================================
    # Step 8: Verify Network
    # ============================================
    log_step "8/9" "Verifying network status..."
    
    # Check containers
    RUNNING_CONTAINERS=$(docker ps --format '{{.Names}}' | wc -l)
    log_info "Running containers: $RUNNING_CONTAINERS"
    
    # Check API health
    if curl -s http://localhost:4000/health > /dev/null 2>&1 || curl -s http://localhost:4000 > /dev/null 2>&1; then
        log_info "✓ API is responding"
    else
        log_warning "API might not be ready yet (this is normal)"
    fi
    
    # ============================================
    # Step 9: Display Summary
    # ============================================
    log_step "9/9" "Network setup complete!"
    
    # Mark network as running
    touch "$SCRIPT_DIR/artifacts/.network-running"
    
    echo ""
    echo "============================================"
    echo -e "${GREEN}✓ Fabric Network is Ready!${NC}"
    echo "============================================"
    echo ""
    echo "Network Components:"
    echo "  ✓ 5 Certificate Authorities"
    echo "  ✓ 3 Orderers"
    echo "  ✓ 4 Peers (Penangkar, Petani, Pengumpul, Pedagang)"
    echo "  ✓ 4 CouchDB instances"
    echo "  ✓ 1 MongoDB instance"
    echo "  ✓ REST API Server"
    echo ""
    echo "Network Details:"
    echo "  - Channel: mychannel"
    echo "  - Chaincode: bawangmerah_cc"
    echo "  - API Endpoint: http://localhost:4000"
    echo ""
    echo "Test the API:"
    echo "  curl -X POST http://localhost:4000/register \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"nama\":\"Test User\",\"username\":\"test1\",\"password\":\"pass123\",\"orgName\":\"Petani\"}'"
    echo ""
    echo "View logs:"
    echo "  docker logs -f bm-api-2.0"
    echo ""
    echo "Stop network:"
    echo "  ./stop-all.sh"
    echo ""
    echo "============================================"
}

# Error handler
error_handler() {
    log_error "An error occurred during setup"
    log_error "Check the logs above for details"
    log_info "You can try running individual steps manually"
    exit 1
}

trap error_handler ERR

# Run main function
main

exit 0

