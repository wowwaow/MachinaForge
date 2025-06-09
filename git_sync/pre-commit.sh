#!/bin/bash

# Pre-commit hook for MachinaForge
# Validates changes and prevents sensitive data from being committed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
REPO_ROOT=$(git rev-parse --show-toplevel)
LOG_FILE="$REPO_ROOT/git_sync/security_checks.log"
MAX_FILE_SIZE=10485760  # 10MB in bytes

# MachinaForge-specific sensitive patterns
SENSITIVE_PATTERNS=(
    # Hetzner credentials
    'HCLOUD_TOKEN\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'ROOT_PASSWORD\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    
    # MCP API and security
    'MCP_API_KEY\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'MCP_DB_PASSWORD\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'SECRET_KEY\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    
    # Database credentials
    'DB_PASSWORD\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'MYSQL_PASSWORD\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'MONGODB_URI\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    
    # API tokens and keys
    'API[_\-]?TOKEN\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'API[_\-]?KEY\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    'PRIVATE[_\-]?KEY\s*=\s*["'"'"'][^"'"'"']*["'"'"']'
    
    # Common patterns
    '[0-9a-fA-F]{32}'  # 32-char hex (like API keys)
    '[0-9a-zA-Z]{40}'  # 40-char alphanumeric (like tokens)
    '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  # IP addresses
    '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,63}'  # Email addresses
)

# Sensitive and restricted files
SENSITIVE_FILES=(
    '*.env'
    'config/*.env'
    'config/secrets/*'
    '*.pem'
    '*.key'
    '*.crt'
    'config/hetzner.env'
    '*id_rsa'
    '*id_dsa'
    '*.pfx'
    '*.p12'
)

# Prohibited binary and generated files
PROHIBITED_FILES=(
    '*.pyc'
    '*.pyo'
    '*.so'
    '*.dll'
    '*.dylib'
    '__pycache__/*'
    'venv/*'
    '*.egg-info/*'
    'dist/*'
    'build/*'
)

# Allowed exception files
ALLOWED_FILES=(
    '.env.example'
    'config/default.env'
    'config/template.env'
)

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
    echo -e "$1"
}

# Check file for sensitive data
check_sensitive_data() {
    local file="$1"
    local status=0

    # Skip binary files
    if [ -z "$(file "$file" | grep text)" ]; then
        return 0
    fi

    # Get only added/modified lines
    local diff_content
    diff_content=$(git diff --cached "$file" | grep -E '^\+' | grep -Ev '^\+\+\+')

    for pattern in "${SENSITIVE_PATTERNS[@]}"; do
        if echo "$diff_content" | grep -E "$pattern" > /dev/null; then
            log "${RED}[ERROR] Potential sensitive data in $file matches pattern: $pattern${NC}"
            status=1
        fi
    done

    return $status
}

# Check file permissions
check_file_permissions() {
    local file="$1"
    local status=0

    # Skip allowed files
    for allowed in "${ALLOWED_FILES[@]}"; do
        if [[ "$file" == *"$allowed" ]]; then
            return 0
        fi
    done

    for pattern in "${SENSITIVE_FILES[@]}"; do
        if [[ "$file" == $pattern ]]; then
            local perms=$(stat -c %a "$file")
            if [ "$perms" != "600" ]; then
                log "${RED}[ERROR] Sensitive file $file has incorrect permissions: $perms (should be 600)${NC}"
                status=1
            fi
        fi
    done

    return $status
}

# Check file size
check_file_size() {
    local file="$1"
    local size=$(stat -c%s "$file")

    if [ "$size" -gt "$MAX_FILE_SIZE" ]; then
        log "${RED}[ERROR] File $file exceeds size limit ($(($size/1024/1024))MB > $(($MAX_FILE_SIZE/1024/1024))MB)${NC}"
        return 1
    fi

    return 0
}

# Check prohibited files
check_prohibited_files() {
    local file="$1"
    local status=0

    # Skip allowed files
    for allowed in "${ALLOWED_FILES[@]}"; do
        if [[ "$file" == *"$allowed" ]]; then
            return 0
        fi
    done

    for pattern in "${PROHIBITED_FILES[@]}"; do
        if [[ "$file" == $pattern ]]; then
            log "${RED}[ERROR] Prohibited file type: $file${NC}"
            status=1
        fi
    done

    return $status
}

# Check environment files
check_env_files() {
    local file="$1"
    local status=0

    if [[ "$file" == *.env ]] && [[ ! "$file" =~ \.example$ ]] && [[ ! "$file" =~ \.template$ ]]; then
        log "${RED}[ERROR] Attempting to commit environment file: $file${NC}"
        log "${YELLOW}[INFO] Use .env.example or .env.template for environment templates${NC}"
        status=1
    fi

    return $status
}

# Main execution
main() {
    local exit_status=0
    log "${GREEN}Running pre-commit security checks...${NC}"

    # Get staged files
    staged_files=$(git diff --cached --name-only)

    for file in $staged_files; do
        # Skip deleted files
        if [ ! -f "$file" ]; then
            continue
        fi

        log "${GREEN}Checking: $file${NC}"

        # Run all checks
        if ! check_sensitive_data "$file"; then
            exit_status=1
        fi

        if ! check_file_permissions "$file"; then
            exit_status=1
        fi

        if ! check_file_size "$file"; then
            exit_status=1
        fi

        if ! check_prohibited_files "$file"; then
            exit_status=1
        fi

        if ! check_env_files "$file"; then
            exit_status=1
        fi
    done

    if [ $exit_status -eq 0 ]; then
        log "${GREEN}[SUCCESS] All security checks passed${NC}"
    else
        log "${RED}[FAILED] Security checks failed. Please fix the issues above.${NC}"
        log "${YELLOW}[INFO] To bypass these checks in exceptional cases, use: git commit --no-verify${NC}"
    fi

    exit $exit_status
}

main

