#!/bin/bash

# Google Sign-In SDK Setup Script for Ledger
# This script helps verify and complete the OAuth setup

set -e

echo "🔧 Google Sign-In SDK Setup for Ledger"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "ledger/ledger.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}Error: Please run this script from the ledger project root${NC}"
    echo -e "${RED}Current directory: $(pwd)${NC}"
    exit 1
fi

echo "Step 1: Verifying Info.plist exists..."
if [ -f "ledger/ledger/Info.plist" ]; then
    echo -e "${GREEN}✓${NC} Info.plist found"
else
    echo -e "${RED}✗${NC} Info.plist not found"
    exit 1
fi

echo ""
echo "Step 2: Checking Info.plist configuration..."

# Check for GIDClientID
if grep -q "GIDClientID" ledger/ledger/Info.plist; then
    echo -e "${GREEN}✓${NC} GIDClientID configured"
else
    echo -e "${RED}✗${NC} GIDClientID missing"
fi

# Check for URL scheme
if grep -q "com.googleusercontent.apps" ledger/ledger/Info.plist; then
    echo -e "${GREEN}✓${NC} Google URL scheme configured"
else
    echo -e "${RED}✗${NC} Google URL scheme missing"
fi

echo ""
echo "Step 3: Manual Xcode configuration required"
echo -e "${YELLOW}⚠${NC}  You need to complete these steps in Xcode:"
echo ""
echo "  1. Add Swift Package Dependency:"
echo "     • File → Add Package Dependencies"
echo "     • URL: https://github.com/google/GoogleSignIn-iOS"
echo "     • Version: 7.0.0 or later"
echo "     • Select: GoogleSignIn and GoogleSignInSwift"
echo ""
echo "  2. Configure Info.plist file:"
echo "     • Select 'ledger' target"
echo "     • Build Settings → Search 'Info.plist'"
echo "     • Set 'Info.plist File' to: ledger/Info.plist"
echo "     • Set 'Generate Info.plist File' to: NO"
echo ""
echo "  3. Build the project (⌘+B) to verify"
echo ""
echo -e "${YELLOW}→${NC} After completing these steps, run the verification:"
echo "     ./scripts/verify-google-signin.sh"
echo ""
