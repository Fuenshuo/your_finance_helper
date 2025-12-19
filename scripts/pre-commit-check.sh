#!/bin/bash

# Pre-commit CI compliance check script
# This script runs all CI checks locally before committing to GitHub
# Based on .github/workflows/ci.yml code-quality job
# Usage: ./scripts/pre-commit-check.sh [--skip-tests]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🔍 Running CI Compliance Checks${NC}"
echo -e "${BLUE}  Based on .github/workflows/ci.yml code-quality job${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Track if any check fails
FAILED=0

# Function to run a check
run_check() {
    local name=$1
    local command=$2
    
    echo -e "${YELLOW}▶ ${name}${NC}"
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Passed${NC}"
        return 0
    else
        echo -e "${RED}   ❌ Failed${NC}"
        echo -e "${YELLOW}   Running command to see errors:${NC}"
        eval "$command" || true
        FAILED=1
        return 1
    fi
}

# Step 1: Install dependencies
echo -e "${BLUE}Step 1/4: Installing dependencies...${NC}"
if flutter pub get > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Dependencies installed${NC}"
else
    echo -e "${RED}   ❌ Failed to install dependencies${NC}"
    flutter pub get
    FAILED=1
fi
echo ""

# Step 2: Code Analysis (warnings allowed)
echo -e "${BLUE}Step 2/4: Analyzing code (no fatal warnings)...${NC}"
run_check "Code Analysis" "flutter analyze lib/ --no-fatal-warnings"
echo ""

# Step 3: Code Formatting
echo -e "${BLUE}Step 3/4: Checking code formatting...${NC}"
if dart format --set-exit-if-changed lib/ > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Code formatting is correct${NC}"
else
    echo -e "${RED}   ❌ Code formatting check failed${NC}"
    echo -e "${YELLOW}   Some files need formatting. Running format...${NC}"
    dart format lib/
    echo -e "${YELLOW}   ⚠️  Files have been auto-formatted. Please review and commit again.${NC}"
    FAILED=1
fi
echo ""

# Step 4: Info-Level Linting (strict)
echo -e "${BLUE}Step 4/4: Running strict linting (fatal infos)...${NC}"
run_check "Strict Linting" "flutter analyze lib/ --fatal-infos"
echo ""

# Step 5: Unit Tests (optional - can be skipped with --skip-tests)
if [[ "$1" != "--skip-tests" ]]; then
    echo -e "${BLUE}Step 5/5: Running unit tests...${NC}"
    run_check "Unit Tests" "flutter test --coverage test/"
    echo ""
else
    echo -e "${YELLOW}⏭ Skipping unit tests (--skip-tests flag)${NC}"
    echo ""
fi

# Final result
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All CI compliance checks passed!${NC}"
    echo -e "${GREEN}✅ Ready to commit.${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ CI compliance checks failed!${NC}"
    echo -e "${RED}❌ Please fix the issues above before committing.${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    exit 1
fi

