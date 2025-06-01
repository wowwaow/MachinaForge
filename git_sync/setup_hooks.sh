#!/bin/bash

# Script to set up git hooks and verify git configuration
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Make hooks executable
chmod +x "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/post-commit"

# Create git sync directory
mkdir -p "$REPO_ROOT/git_sync"
touch "$REPO_ROOT/git_sync/sync.log"

# Verify git configuration
if ! git config --get remote.origin.url > /dev/null; then
    echo -e "${RED}Error: Git remote 'origin' not configured${NC}"
    exit 1
fi

# Verify branch configuration
if ! git symbolic-ref --short HEAD > /dev/null; then
    echo -e "${RED}Error: Not on a git branch${NC}"
    exit 1
fi

echo -e "${GREEN}Git hooks installed and configured successfully${NC}"
echo -e "Hooks location: $HOOKS_DIR"
echo -e "Sync log: $REPO_ROOT/git_sync/sync.log"

