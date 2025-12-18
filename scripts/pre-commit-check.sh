#!/bin/bash

# Pre-commit CI compliance check script
# This script runs all CI checks locally before committing to GitHub
# Usage: ./scripts/pre-commit-check.sh

set -e  # Exit on any error

echo "🔍 Running pre-commit CI compliance checks..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any check fails
FAILED=0

# Function to run a check
run_check() {
    local name=$1
    local command=$2
    
    echo -e "${YELLOW}▶ Checking: ${name}${NC}"
    if eval "$command"; then
        echo -e "${GREEN}✅ ${name} passed${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ ${name} failed${NC}"
        echo ""
        FAILED=1
        return 1
    fi
}

# 1. Install dependencies
run_check "Dependencies" "flutter pub get"

# 2. Code Analysis (warnings allowed)
run_check "Code Analysis (no fatal warnings)" "flutter analyze lib/ --no-fatal-warnings"

# 3. Code Formatting
echo -e "${YELLOW}▶ Checking: Code Formatting${NC}"
if dart format --set-exit-if-changed lib/ > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Code Formatting passed${NC}"
    echo ""
else
    echo -e "${RED}❌ Code Formatting failed - files need formatting${NC}"
    echo -e "${YELLOW}   Running: dart format lib/${NC}"
    dart format lib/
    echo -e "${YELLOW}   Please review the changes and commit again${NC}"
    echo ""
    FAILED=1
fi

# 4. Info-Level Linting (strict)
run_check "Info-Level Linting (fatal infos)" "flutter analyze lib/ --fatal-infos"

# 5. Unit Tests (optional - can be skipped with --skip-tests)
if [[ "$1" != "--skip-tests" ]]; then
    run_check "Unit Tests" "flutter test --coverage test/"
else
    echo -e "${YELLOW}⏭ Skipping unit tests (--skip-tests flag)${NC}"
    echo ""
fi

# Final result
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All pre-commit checks passed! Ready to commit.${NC}"
    exit 0
else
    echo -e "${RED}❌ Pre-commit checks failed. Please fix the issues above before committing.${NC}"
    exit 1
fi

