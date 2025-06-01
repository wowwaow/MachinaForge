#!/bin/bash
# Directory Cleanup Script
# Version: 1.0

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
LOG_FILE="${SYSTEM_ROOT}/Agents/Janitor/logs/cleanup.log"
ARCHIVE_DIR="${SYSTEM_ROOT}/Agents/Janitor/logs/archives"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting directory cleanup" >> "${LOG_FILE}"

# Create archive directory
mkdir -p "${ARCHIVE_DIR}"

# Archive old logs (older than 7 days)
find "${SYSTEM_ROOT}" -name "*.log" -type f -mtime +7 -exec mv {} "${ARCHIVE_DIR}/" \;

# Remove empty directories
find "${SYSTEM_ROOT}" -type d -empty -delete

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Directory cleanup completed" >> "${LOG_FILE}"
