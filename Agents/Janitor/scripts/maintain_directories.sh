#!/bin/bash
# Janitor Agent Script
# Version: 1.0

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
LOG_FILE="${SYSTEM_ROOT}/Agents/Janitor/logs/maintenance.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Logging function
log_message() {
    echo "[${TIMESTAMP}] $1" >> "${LOG_FILE}"
    echo "$1"
}

# Archive old files
archive_old_files() {
    local dir="$1"
    local age="$2"  # in minutes
    local target_dir="$3"
    
    find "${dir}" -type f -mmin +${age} -exec mv {} "${target_dir}/" \;
}

# Clean temporary files
clean_temp_files() {
    find "${SYSTEM_ROOT}" -type f -name "*.tmp" -delete
    find "${SYSTEM_ROOT}" -type f -name "*.bak" -delete
}

# Main maintenance loop
log_message "Starting directory maintenance..."

while true; do
    # Archive old processed files (older than 1 day)
    archive_old_files "${SYSTEM_ROOT}/data/processed" 1440 "${SYSTEM_ROOT}/archive/data"
    archive_old_files "${SYSTEM_ROOT}/analysis/processed" 1440 "${SYSTEM_ROOT}/archive/analysis"
    archive_old_files "${SYSTEM_ROOT}/docs/processed" 1440 "${SYSTEM_ROOT}/archive/docs"
    
    # Clean temporary files
    clean_temp_files
    
    # Log directory status
    log_message "Directory Status:"
    log_message "- Data files: $(ls -1 ${SYSTEM_ROOT}/data/current/ | wc -l) current, $(ls -1 ${SYSTEM_ROOT}/data/processed/ | wc -l) processed"
    log_message "- Analysis files: $(ls -1 ${SYSTEM_ROOT}/analysis/current/ | wc -l) current, $(ls -1 ${SYSTEM_ROOT}/analysis/processed/ | wc -l) processed"
    log_message "- Documentation files: $(ls -1 ${SYSTEM_ROOT}/docs/current/ | wc -l) current, $(ls -1 ${SYSTEM_ROOT}/docs/processed/ | wc -l) processed"
    log_message "- Archive status: $(ls -1 ${SYSTEM_ROOT}/archive/*/* | wc -l) total archived files"
    
    sleep 300  # Check every 5 minutes
done
