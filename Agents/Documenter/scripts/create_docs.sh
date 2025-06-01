#!/bin/bash
# Documenter Agent Script
# Version: 1.0

SYSTEM_ROOT="/home/host/Documents/Machina/MF_Main"
ANALYSIS_DIR="${SYSTEM_ROOT}/analysis/current"
DOCS_DIR="${SYSTEM_ROOT}/docs/current"
LOG_FILE="${SYSTEM_ROOT}/Agents/Documenter/logs/documentation.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Logging function
log_message() {
    echo "[${TIMESTAMP}] $1" >> "${LOG_FILE}"
    echo "$1"
}

# Process analysis file
create_documentation() {
    local file="$1"
    local basename=$(basename "$file")
    local doc_file="${DOCS_DIR}/documentation_${basename}"
    
    log_message "Creating documentation for: ${basename}"
    
    # Extract analysis information
    local source_file=$(grep "Source:" "$file" | cut -d: -f2- | xargs)
    local analysis_date=$(grep "Generated:" "$file" | cut -d: -f2- | xargs)
    
    # Create documentation
    cat > "${doc_file}" << EOL
# Documentation Report
Generated: ${TIMESTAMP}
Analysis Source: ${basename}
Original Source: ${source_file}

## Analysis Summary
Analysis performed on: ${analysis_date}

$(awk '/^## Content Analysis/,/^##/' "$file")

## Documentation Notes
- Documentation created: ${TIMESTAMP}
- Based on analysis file: ${basename}
- Original data: ${source_file}

## References
- Original Data: \`/data/processed/${source_file}\`
- Analysis: \`/analysis/processed/${basename}\`
- Documentation: \`/docs/current/${basename}\`

## Status
- [x] Analysis reviewed
- [x] Documentation created
- [ ] Peer review needed
- [ ] Ready for archive
EOL

    # Move processed analysis file
    mv "$file" "${SYSTEM_ROOT}/analysis/processed/${basename}"
    log_message "Documentation complete: ${basename} -> documentation_${basename}"
}

# Main documentation loop
log_message "Starting documentation monitoring..."

while true; do
    # Check for new analysis files
    for file in "${ANALYSIS_DIR}"/*.md; do
        if [ -f "$file" ]; then
            create_documentation "$file"
        fi
    done
    
    sleep 60  # Check every minute
done
