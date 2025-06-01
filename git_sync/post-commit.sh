#!/bin/bash

# Post-commit hook for MachinaForge
# Handles automatic GitHub synchronization

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
LOG_FILE="$REPO_ROOT/git_sync/sync.log"
METRICS_FILE="$REPO_ROOT/git_sync/metrics.json"
LOCK_FILE="$REPO_ROOT/git_sync/.sync.lock"
MAX_RETRIES=3
RETRY_DELAY=5
SYNC_TIMEOUT=30

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Update sync metrics
update_metrics() {
    local status="$1"
    local duration="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local branch=$(git symbolic-ref --short HEAD)
    local commit=$(git rev-parse HEAD)
    local commit_msg=$(git log -1 --pretty=%B)

    # Create metrics file if it doesn't exist
    if [ ! -f "$METRICS_FILE" ]; then
        echo '{"syncs":[],"statistics":{"total":0,"successful":0,"failed":0}}' > "$METRICS_FILE"
    fi

    # Update metrics
    local temp_file=$(mktemp)
    jq --arg ts "$timestamp" \
       --arg branch "$branch" \
       --arg commit "$commit" \
       --arg msg "$commit_msg" \
       --arg status "$status" \
       --arg duration "$duration" \
       '.syncs += [{
           "timestamp": $ts,
           "branch": $branch,
           "commit": $commit,
           "message": $msg,
           "status": $status,
           "duration": ($duration | tonumber)
       }] | .statistics.total += 1 | 
       if $status == "success" then .statistics.successful += 1 
       else .statistics.failed += 1 end' \
       "$METRICS_FILE" > "$temp_file" && mv "$temp_file" "$METRICS_FILE"
}

# Clean up function
cleanup() {
    rm -f "$LOCK_FILE"
}

trap cleanup EXIT

# Verify GitHub connection
verify_github_connection() {
    if ! timeout 10 git ls-remote origin HEAD &>/dev/null; then
        log "${RED}[ERROR] Cannot connect to GitHub${NC}"
        return 1
    fi
    return 0
}

# Push changes to GitHub
push_to_github() {
    local start_time=$(date +%s)
    local branch=$(git symbolic-ref --short HEAD)
    local attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        log "${GREEN}[INFO] Pushing to GitHub (attempt $attempt/$MAX_RETRIES)${NC}"

        if timeout $SYNC_TIMEOUT git push origin "$branch" 2>> "$LOG_FILE"; then
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            log "${GREEN}[SUCCESS] Successfully pushed changes to GitHub${NC}"
            update_metrics "success" "$duration"
            return 0
        else
            if [ $attempt -lt $MAX_RETRIES ]; then
                log "${YELLOW}[RETRY] Push failed, retrying in $RETRY_DELAY seconds...${NC}"
                sleep $RETRY_DELAY
            fi
            attempt=$((attempt + 1))
        fi
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log "${RED}[ERROR] Failed to push changes after $MAX_RETRIES attempts${NC}"
    update_metrics "failure" "$duration"
    return 1
}

# Main execution
main() {
    # Check if sync is already running
    if [ -f "$LOCK_FILE" ]; then
        log "${YELLOW}[WARNING] Another sync process is running, skipping${NC}"
        exit 0
    fi

    # Create lock file
    touch "$LOCK_FILE"

    # Start sync process
    log "${GREEN}Starting GitHub synchronization${NC}"

    # Get current state
    local branch=$(git symbolic-ref --short HEAD)
    local commit=$(git rev-parse HEAD)
    local commit_msg=$(git log -1 --pretty=%B)

    log "Branch: $branch"
    log "Commit: $commit"
    log "Message: $commit_msg"

    # Verify GitHub connection
    if ! verify_github_connection; then
        log "${RED}[ERROR] GitHub connection verification failed${NC}"
        cleanup
        exit 1
    fi

    # Push changes
    if push_to_github; then
        log "${GREEN}[SUCCESS] Synchronization completed successfully${NC}"
        cleanup
        exit 0
    else
        log "${RED}[ERROR] Synchronization failed${NC}"
        cleanup
        exit 1
    fi
}

main

