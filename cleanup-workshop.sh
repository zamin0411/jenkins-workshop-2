#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo "=========================================="
echo "        Workshop Cleanup Script"
echo "=========================================="
echo ""

print_status "Stopping all containers..."
docker-compose down

print_status "Removing containers and networks..."
docker-compose down --remove-orphans

print_status "Removing volumes..."
docker volume rm workshop_jenkins_home 2>/dev/null || print_warning "Volume already removed"

print_status "Cleaning up local files..."
rm -rf deploy/* 2>/dev/null || print_warning "Deploy directory already clean"

print_success "Cleanup complete!"
echo ""
print_status "To start fresh, run: ./setup-workshop.sh"
