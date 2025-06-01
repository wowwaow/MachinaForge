#!/bin/bash

# Script to install and verify Git hooks for MachinaForge
set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SYNC_DIR="$REPO_ROOT/git_sync"

# Logging function
log() {
    echo -e "$1"
}

# Install hooks
install_hooks() {
    log "${GREEN}Installing Git hooks...${NC}"
    
    # Ensure directories exist
    mkdir -p "$HOOKS_DIR"
    mkdir -p "$SYNC_DIR"
    
    # Copy hook scripts
    cp "$SYNC_DIR/pre-commit.sh" "$HOOKS_DIR/pre-commit"
    cp "$SYNC_DIR/post-commit.sh" "$HOOKS_DIR/post-commit"
    
    # Make hooks executable
    chmod +x "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/post-commit"
    
    # Create log files with correct permissions
    touch "$SYNC_DIR/sync.log"
    touch "$SYNC_DIR/security_checks.log"
    chmod 600 "$SYNC_DIR/sync.log"
    chmod 600 "$SYNC_DIR/security_checks.log"
    
    # Initialize metrics file
    echo '{"syncs":[],"last_update":""}' > "$SYNC_DIR/metrics.json"
    chmod 600 "$SYNC_DIR/metrics.json"
}

# Verify hooks
verify_hooks() {
    log "${GREEN}Verifying Git hooks installation...${NC}"
    
    local status=0
    
    # Check if hooks are executable
    if [ ! -x "$HOOKS_DIR/pre-commit" ]; then
        log "${RED}[ERROR] pre-commit hook is not executable${NC}"
        status=1
    fi
    
    if [ ! -x "$HOOKS_DIR/post-commit" ]; then
        log "${RED}[ERROR] post-commit hook is not executable${NC}"
        status=1
    fi
    
    # Check log files
    if [ ! -f "$SYNC_DIR/sync.log" ]; then
        log "${RED}[ERROR] sync.log not found${NC}"
        status=1
    fi
    
    if [ ! -f "$SYNC_DIR/security_checks.log" ]; then
        log "${RED}[ERROR] security_checks.log not found${NC}"
        status=1
    fi
    
    # Check file permissions
    for file in "$SYNC_DIR"/*.log "$SYNC_DIR/metrics.json"; do
        if [ "$(stat -c %a "$file")" != "600" ]; then
            log "${RED}[ERROR] Incorrect permissions on $file${NC}"
            status=1
        fi
    done
    
    return $status
}

# Main execution
main() {
    log "${GREEN}Starting Git hooks installation${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log "${RED}[ERROR] Not in a git repository${NC}"
        exit 1
    fi
    
    # Check if hook scripts exist
    if [ ! -f "$SYNC_DIR/pre-commit.sh" ] || [ ! -f "$SYNC_DIR/post-commit.sh" ]; then
        log "${RED}[ERROR] Hook scripts not found in $SYNC_DIR${NC}"
        exit 1
    fi
    
    # Install hooks
    install_hooks
    
    # Verify installation
    if verify_hooks; then
        log "${GREEN}[SUCCESS] Git hooks installed and verified successfully${NC}"
        log "Hooks location: $HOOKS_DIR"
        log "Sync directory: $SYNC_DIR"
        exit 0
    else
        log "${RED}[ERROR] Hook installation verification failed${NC}"
        exit 1
    fi
}

main

