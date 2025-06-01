#!/bin/bash
# Agent Monitor Script
# Version: 1.0

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
LOG_FILE="${SYSTEM_ROOT}/Agents/Overseer/logs/monitor.log"
REGISTRY_FILE="${SYSTEM_ROOT}/SystemComponents/Registry/AGENT_REGISTRY.json"

# Monitor active agents
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Starting agent monitoring" >> "${LOG_FILE}"

# Check agent heartbeats
while true; do
    CURRENT_TIME=$(date -u +%s)
    
    # Read registry and check timestamps
    if [ -f "${REGISTRY_FILE}" ]; then
        while IFS= read -r line; do
            if [[ ${line} =~ \"last_heartbeat\":\ \"([^\"]+)\" ]]; then
                HEARTBEAT="${BASH_REMATCH[1]}"
                HEARTBEAT_TIME=$(date -u -d "${HEARTBEAT}" +%s)
                
                if (( CURRENT_TIME - HEARTBEAT_TIME > 120 )); then
                    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] Agent timeout detected" >> "${LOG_FILE}"
                fi
            fi
        done < "${REGISTRY_FILE}"
    fi
    
    sleep 30
done
