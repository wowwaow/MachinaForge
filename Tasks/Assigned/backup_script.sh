#!/bin/bash

# MachinaForge Backup Script
# Generated: 2025-06-01
# Task ID: SM-BCK-20250601

set -euo pipefail

# Base paths
MACHINA_ROOT="/home/host/Documents/Machina/MF_Main"
BACKUP_ROOT="${MACHINA_ROOT}/Backups"
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
BACKUP_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LOG_FILE="${BACKUP_DIR}/backup.log"
TEMP_LOG="/tmp/backup_${TIMESTAMP}.log"

# Early initialization
init_backup_environment() {
    # Create backup root if it doesn't exist
    if [[ ! -d "${BACKUP_ROOT}" ]]; then
        mkdir -p "${BACKUP_ROOT}"
        chmod 755 "${BACKUP_ROOT}"
    fi

    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    chmod 755 "${BACKUP_DIR}"

    # Initialize temporary log
    touch "${TEMP_LOG}"
    chmod 644 "${TEMP_LOG}"

    # Move to final log location
    mv "${TEMP_LOG}" "${LOG_FILE}"
}

# Initialize backup environment before proceeding
init_backup_environment

# Error handling
error_handler() {
    local line_no=$1
    local error_code=$2
    local log_target="${LOG_FILE}"
    
    # Use temporary log if main log is not accessible
    if [[ ! -w "${LOG_FILE}" ]]; then
        log_target="${TEMP_LOG}"
    fi
    
    echo "[ERROR] Failed at line ${line_no} with code ${error_code}" >> "${log_target}"
    
    # Ensure alerts directory exists
    mkdir -p "${MACHINA_ROOT}/SystemComponents/Handoff/alerts"
    
    # Send alert through MCP
    echo "{\"type\": \"system_alert\", \"severity\": \"critical\", \"message\": \"Backup failed at line ${line_no}\"}" > "${MACHINA_ROOT}/SystemComponents/Handoff/alerts/backup_failure.json"
    exit 1
}

trap 'error_handler ${LINENO} $?' ERR

# Logging function
log() {
    local level=$1
    local message=$2
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [${level}] ${message}" >> "${LOG_FILE}"
}

# Checksum validation
validate_backup() {
    local source_path=$1
    local backup_path=$2
    local source_sum=$(sha256sum "${source_path}" | cut -d' ' -f1)
    local backup_sum=$(sha256sum "${backup_path}" | cut -d' ' -f1)
    
    if [ "${source_sum}" != "${backup_sum}" ]; then
        log "ERROR" "Checksum mismatch for ${source_path}"
        return 1
    fi
    log "INFO" "Validated backup of ${source_path}"
    return 0
}

# Initialize backup directory structure
init_backup_dirs() {
    log "INFO" "Initializing backup directory structure"
    
    # Create all required directories with proper permissions
    local dirs=(
        "redis"
        "config/system"
        "config/mcp"
        "config/agents"
        "config/services"
        "templates"
        "states/agents"
        "states/components"
        "states/mcp"
        "states/tasks"
        "logs/system"
        "logs/agents"
        "metrics/system"
        "metrics/monitoring"
        "security"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "${BACKUP_DIR}/${dir}"
        chmod 755 "${BACKUP_DIR}/${dir}"
    done
    
    log "INFO" "Backup directory structure created successfully"
}

# Redis backup
backup_redis() {
    log "INFO" "Starting Redis backup"
    redis-cli save
    cp /var/lib/redis/dump.rdb "${BACKUP_DIR}/redis/dump.rdb"
    validate_backup "/var/lib/redis/dump.rdb" "${BACKUP_DIR}/redis/dump.rdb"
}

# Configuration backup
backup_configs() {
    log "INFO" "Starting configuration backup"
    local status=0
    
    # System configs
    log "INFO" "Backing up system configurations"
    if [[ -d "${MACHINA_ROOT}/System/config" ]]; then
        rsync -a "${MACHINA_ROOT}/System/config/" "${BACKUP_DIR}/config/system/" || status=$?
        if [[ $status -ne 0 ]]; then
            log "ERROR" "Failed to backup system config directory"
            return $status
        fi
    else
        log "WARN" "System config directory not found"
    fi

    # MCP configs
    log "INFO" "Backing up MCP configurations"
    if [[ -d "${MACHINA_ROOT}/System/MCP/config" ]]; then
        rsync -a "${MACHINA_ROOT}/System/MCP/config/" "${BACKUP_DIR}/config/mcp/" || status=$?
        if [[ $status -ne 0 ]]; then
            log "ERROR" "Failed to backup MCP config directory"
            return $status
        fi
    else
        log "WARN" "MCP config directory not found"
    fi

    # Agent configs
    log "INFO" "Backing up agent configurations"
    local agent_dirs=(
        "Archivist"
        "Janitor"
        "Overseer"
        "Data_Collector"
        "Analyst"
        "Systems_Architect"
        "Documenter"
        "Programmer"
    )

    for agent in "${agent_dirs[@]}"; do
        local agent_config="${MACHINA_ROOT}/Agents/${agent}/config"
        local agent_backup="${BACKUP_DIR}/config/agents/${agent}"
        
        if [[ -d "${agent_config}" ]]; then
            mkdir -p "${agent_backup}"
            rsync -a "${agent_config}/" "${agent_backup}/" || status=$?
            if [[ $status -ne 0 ]]; then
                log "ERROR" "Failed to backup ${agent} config directory"
                return $status
            fi
            log "INFO" "Successfully backed up ${agent} configurations"
        else
            log "WARN" "${agent} config directory not found at ${agent_config}"
        fi
    done

    # Service configs
    log "INFO" "Backing up service configurations"
    local service_dirs=(
        "nginx"
        "php"
    )

    for service in "${service_dirs[@]}"; do
        local service_path="${MACHINA_ROOT}/services/${service}"
        local service_backup="${BACKUP_DIR}/config/services/${service}"
        
        if [[ -d "${service_path}" ]]; then
            mkdir -p "${service_backup}"
            rsync -a "${service_path}/" "${service_backup}/" || status=$?
            if [[ $status -ne 0 ]]; then
                log "ERROR" "Failed to backup ${service} config directory"
                return $status
            fi
            log "INFO" "Successfully backed up ${service} configurations"
        else
            log "WARN" "${service} directory not found at ${service_path}"
        fi
    done

    if [[ $status -eq 0 ]]; then
        log "INFO" "Configuration backup completed successfully"
    else
        log "ERROR" "Configuration backup completed with errors"
    fi
    return $status
}

# Template backup
backup_templates() {
    log "INFO" "Backing up templates"
    rsync -a "${MACHINA_ROOT}/Templates/" "${BACKUP_DIR}/templates/"
}

# State backup
backup_states() {
    log "INFO" "Backing up system states"
    
    # Agent states
    rsync -a "${MACHINA_ROOT}/Agents/Status/" "${BACKUP_DIR}/states/agents/"
    rsync -a "${MACHINA_ROOT}/SystemComponents/Status/" "${BACKUP_DIR}/states/components/"
    
    # MCP states
    rsync -a "${MACHINA_ROOT}/System/MCP/cache/" "${BACKUP_DIR}/states/mcp/"
    
    # Task states
    rsync -a "${MACHINA_ROOT}/Tasks/Pool/" "${BACKUP_DIR}/states/tasks/"
}

# Log backup
backup_logs() {
    log "INFO" "Starting log backup process"
    local status=0
    
    # System logs
    if [[ -d "${MACHINA_ROOT}/System/Logs" ]]; then
        log "INFO" "Backing up system logs"
        mkdir -p "${BACKUP_DIR}/logs/system"
        rsync -a "${MACHINA_ROOT}/System/Logs/" "${BACKUP_DIR}/logs/system/" || {
            status=$?
            log "WARN" "Failed to backup system logs, continuing with other backups"
        }
    else
        log "WARN" "System logs directory not found"
    fi
    
    # Agent logs
    log "INFO" "Backing up agent logs"
    local agent_dirs=(
        "Archivist"
        "Janitor"
        "Overseer"
        "Data_Collector"
        "Analyst"
        "Systems_Architect"
        "Documenter"
        "Programmer"
    )

    for agent in "${agent_dirs[@]}"; do
        local agent_logs="${MACHINA_ROOT}/Agents/${agent}/logs"
        local agent_backup="${BACKUP_DIR}/logs/agents/${agent}"
        
        if [[ -d "${agent_logs}" ]]; then
            log "INFO" "Backing up ${agent} logs"
            mkdir -p "${agent_backup}"
            rsync -a "${agent_logs}/" "${agent_backup}/" || {
                status=$?
                log "WARN" "Failed to backup ${agent} logs, continuing with other backups"
            }
        else
            log "INFO" "Creating empty log directory for ${agent}"
            mkdir -p "${agent_logs}"
            mkdir -p "${agent_backup}"
            chmod 755 "${agent_logs}"
            touch "${agent_logs}/agent.log"
            log "INFO" "Created log directory and empty log file for ${agent}"
        fi
    done

    if [[ $status -eq 0 ]]; then
        log "INFO" "Log backup completed successfully"
    else
        log "WARN" "Log backup completed with some non-critical errors"
    fi
    return 0  # Always return success as log failures are non-critical
}

# Metrics backup
backup_metrics() {
    log "INFO" "Backing up metrics data"
    rsync -a "${MACHINA_ROOT}/System/Metrics/" "${BACKUP_DIR}/metrics/system/"
    rsync -a "${MACHINA_ROOT}/SystemComponents/Monitoring/" "${BACKUP_DIR}/metrics/monitoring/"
}

# Create checksums for all backed up files
create_checksums() {
    log "INFO" "Creating checksums"
    find "${BACKUP_DIR}" -type f \
        -not -name "backup.log" \
        -not -name "*.sha256" \
        -not -name "backup_complete" \
        -print0 | while IFS= read -r -d '' file; do
        sha256sum "${file}" > "${file}.sha256"
    done
    log "INFO" "Checksums created successfully"
}

# Verify backup integrity
verify_backup() {
    log "INFO" "Verifying backup integrity"
    local errors=0
    local EXCLUDE_PATTERN="backup.log|backup_complete"
    
    # First verify all files except excluded ones
    find "${BACKUP_DIR}" -name "*.sha256" -print0 | while IFS= read -r -d '' checksum_file; do
        # Skip verification for excluded files
        if echo "${checksum_file}" | grep -qE "${EXCLUDE_PATTERN}"; then
            continue
        fi
        
        if ! sha256sum -c "${checksum_file}" 2>/dev/null; then
            log "ERROR" "Verification failed for ${checksum_file}"
            ((errors++))
        fi
    done
    
    if [ "${errors}" -gt 0 ]; then
        log "ERROR" "Backup verification failed with ${errors} errors"
        return 1
    fi
    
    log "INFO" "Backup verification completed successfully"
    return 0
}

# Create backup completion marker
mark_backup_complete() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local marker="${BACKUP_DIR}/backup_complete"
    
    echo "{
        \"backup_id\": \"${TIMESTAMP}\",
        \"completed_at\": \"${timestamp}\",
        \"status\": \"success\",
        \"verification\": \"passed\"
    }" > "${marker}"
    
    log "INFO" "Created backup completion marker"
}

# Main backup procedure
main() {
    log "INFO" "Starting backup process"
    
    # Initialize
    init_backup_dirs
    
    # Critical backups (real-time)
    backup_redis
    backup_states
    backup_configs
    
    # High priority backups (daily)
    backup_logs
    backup_metrics
    
    # Standard backups (weekly)
    backup_templates
    
    # Create and verify checksums
    create_checksums
    if verify_backup; then
        mark_backup_complete
        
        # Create update directory if it doesn't exist
        mkdir -p "${MACHINA_ROOT}/SystemComponents/Handoff/updates"
        
        # Update task registry
        echo "{\"type\": \"status_update\", \"task_id\": \"SM-BCK-20250601\", \"status\": \"completed\", \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" > "${MACHINA_ROOT}/SystemComponents/Handoff/updates/backup_complete.json"
        
        log "INFO" "Backup process completed successfully"
        
        # Set final permissions on backup directory
        chmod -R 755 "${BACKUP_DIR}"
    else
        log "ERROR" "Backup verification failed"
        exit 1
    fi
}

# Execute main backup procedure
main

