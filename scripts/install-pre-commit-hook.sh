#!/bin/bash

# Install pre-commit hook script
# This script installs the pre-commit hook to enforce CI compliance checks
# Usage: ./scripts/install-pre-commit-hook.sh

set -e

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HOOK_FILE="$PROJECT_ROOT/.git/hooks/pre-commit"
HOOK_TEMPLATE="$PROJECT_ROOT/scripts/pre-commit-hook.template"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing pre-commit hook...${NC}"

# Create hooks directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/.git/hooks"

# Copy template to hook location
if [ -f "$HOOK_TEMPLATE" ]; then
    cp "$HOOK_TEMPLATE" "$HOOK_FILE"
    echo -e "${GREEN}✅ Copied hook template${NC}"
else
    # Create hook from inline script
    cat > "$HOOK_FILE" << 'HOOK_EOF'
#!/bin/bash

# Git pre-commit hook
# This hook runs CI compliance checks before allowing a commit
# Based on .github/workflows/ci.yml code-quality job

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🔍 Running CI Compliance Checks (Pre-Commit Hook)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Get the project root directory
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

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
if flutter analyze lib/ --no-fatal-warnings > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Code analysis passed${NC}"
else
    echo -e "${RED}   ❌ Code analysis failed${NC}"
    flutter analyze lib/ --no-fatal-warnings || true
    FAILED=1
fi
echo ""

# Step 3: Check formatting
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
if flutter analyze lib/ --fatal-infos > /dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Strict linting passed${NC}"
else
    echo -e "${RED}   ❌ Strict linting failed${NC}"
    flutter analyze lib/ --fatal-infos || true
    FAILED=1
fi
echo ""

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
    echo -e "${RED}❌ Commit blocked. Please fix the issues above.${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Tip: You can bypass this hook with --no-verify, but CI will still fail.${NC}"
    echo ""
    exit 1
fi
HOOK_EOF
    echo -e "${GREEN}✅ Created hook from inline script${NC}"
fi

# Make hook executable
chmod +x "$HOOK_FILE"
echo -e "${GREEN}✅ Made hook executable${NC}"

echo ""
echo -e "${GREEN}✅ Pre-commit hook installed successfully!${NC}"
echo ""
echo -e "${YELLOW}The hook will now run automatically on every git commit.${NC}"
echo -e "${YELLOW}To test it, try: git commit --allow-empty -m 'test hook'${NC}"
echo ""

