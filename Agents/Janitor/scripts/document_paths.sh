#!/bin/bash
# Path Documentation Script
# Version: 1.0

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
LOG_FILE="${SYSTEM_ROOT}/Agents/Janitor/logs/paths.log"
REPORT_FILE="${SYSTEM_ROOT}/Agents/Janitor/logs/path_report.md"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting path documentation" >> "${LOG_FILE}"

# Generate path report
cat > "${REPORT_FILE}" << EOL
# System Path Report
Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Directory Structure
\`\`\`
$(find "${SYSTEM_ROOT}" -type d -not -path "*/\.*" | sort | sed "s|${SYSTEM_ROOT}|.|g" | tree --fromfile .)
\`\`\`

## Active Configurations
$(find "${SYSTEM_ROOT}" -name "*.env" -o -name "*.json" -o -name "*.yaml" | sort)

## Active Scripts
$(find "${SYSTEM_ROOT}" -type f -executable | sort)

## Log Files
$(find "${SYSTEM_ROOT}" -name "*.log" | sort)
EOL

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Path documentation completed" >> "${LOG_FILE}"
