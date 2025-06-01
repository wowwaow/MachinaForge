#!/bin/bash

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
MCP_ROOT="${SYSTEM_ROOT}/System/MCP"
DATE=$(date -u +"%Y-%m-%d")

prepare_agent_data() {
    local role=$1
    local metrics_file="${SYSTEM_ROOT}/System/Metrics/trends/${DATE}/${role}_metrics.json"
    local trends_file="${SYSTEM_ROOT}/System/Trends/hourly/${DATE}/${role}_history.json"
    local cache_file="${MCP_ROOT}/cache/${role}_status.json"
    
    if [ -f "$metrics_file" ] && [ -f "$trends_file" ]; then
        # Combine metrics and trends
        jq -s '.[0] * {"trends": .[1]}' "$metrics_file" "$trends_file" > "$cache_file"
    fi
}

# Prepare data for each agent
for role in Analyst Documenter Janitor; do
    prepare_agent_data "$role"
done

# Create system status summary
cat > "${MCP_ROOT}/cache/system_status.json" << STATUS
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "agents": {
        "total": 3,
        "active": $(pgrep -f "warp.*agent" | wc -l),
        "healthy": $(for r in Analyst Documenter Janitor; do
            if [ -f "${SYSTEM_ROOT}/Agents/${r}/config/warp_config.json" ]; then
                echo "1"
            fi
        done | wc -l)
    },
    "processing": {
        "total_files": $(ls -1 "${SYSTEM_ROOT}/SystemComponents/Handoff/processed/" | wc -l),
        "failed_files": $(ls -1 "${SYSTEM_ROOT}/SystemComponents/Handoff/failed/" | wc -l)
    }
}
STATUS
