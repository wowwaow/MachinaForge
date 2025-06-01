# MachinaForge Data Inventory
**Generated**: 2025-06-01T18:53:11Z
**Task ID**: SM-BCK-20250601
**Status**: Current

## 1. Databases and State Storage
### Redis Data
- Heartbeat system state
- Message queues
- Metrics cache

### Agent States
- `/Agents/Status/agent_registry.json` - Active agent records
- `/Agents/Status/heartbeat_*.json` - Agent heartbeat records
- `/SystemComponents/Status/HEARTBEAT_MONITOR.json` - System heartbeat state

## 2. Configuration Files
### System Configuration
- `/System/config/monitoring.json` - Monitoring settings
- `/System/config/notifications.json` - Alert configurations
- `/System/config/mcp_endpoint.json` - MCP endpoint settings
- `/System/MCP/config/mcp_config.json` - MCP core configuration
- `/System/MCP/config/warp_integration.json` - Integration settings

### Agent Configuration
- `/Agents/Analyst/config/warp_config.json`
- `/Agents/Documenter/config/warp_config.json`
- `/Agents/Janitor/config/warp_config.json`

### Service Configuration
- `/services/nginx/conf.d/default.conf` - NGINX configuration

## 3. User Data and Templates
### Message Templates
- `/Templates/Messages/*.json` - Core message templates
- `/SystemComponents/Handoff/templates/*.json` - Handoff templates

### Task Templates
- `/Templates/Tasks/task_template.json`
- `/Templates/Objectives/objective_template.json`
- `/Templates/Roles/role_template.json`

### Active Tasks
- `/Tasks/Pool/task_registry.json` - Task tracking
- `/devstack/tasks/tasks.json` - Development tasks

## 4. Application States
### MCP Status
- `/System/MCP/cache/system_status.json`
- `/System/MCP/cache/*_status.json` - Component status files

### Agent States
- `/Agents/Status/agent_registry.json`
- `/SystemComponents/Registry/AGENT_REGISTRY.json`

### Message Processing
- `/SystemComponents/Handoff/processed/*.json` - Processed messages
- `/SystemComponents/Handoff/archive/**/*.json` - Archived messages

## 5. Logs and Metrics
### System Logs
- `/System/Logs/system.log` - Main system log
- `/System/Logs/monitoring.log` - Monitoring data
- `/System/Logs/alerts.log` - System alerts
- `/System/Logs/agent_manager.log` - Agent management
- `/System/Logs/message_monitor.log` - Message tracking
- `/System/MCP/logs/server.log` - MCP server logs
- `/MCP/mcp_server.log` - Legacy MCP logs

### Agent Logs
- `/System/Logs/*_output.log` - Agent output logs
- `/Agents/*/logs/*.log` - Agent-specific logs

### Metrics and Trends
- `/System/Metrics/trends/**/*.json` - Performance trends
- `/System/Metrics/baseline/*_baseline.json` - Baseline metrics
- `/System/Trends/hourly/**/*.json` - Hourly trend data
- `/SystemComponents/Monitoring/metrics.json` - Current metrics
- `/SystemComponents/Monitoring/enhanced_metrics.json` - Extended metrics

## 6. Security Data
### SSL/TLS
- Certificates directory (TBD)
- Private keys storage (TBD)

### Access Control
- API keys (TBD)
- Authentication tokens (TBD)

## Storage Requirements
- Total current size: TBD
- Expected growth rate: TBD
- Retention periods:
  - Logs: 30 days
  - Metrics: 7 days
  - Messages: 24 hours (active), 7 days (archived)
  - Critical alerts: 30 days

## Backup Priority Levels
1. **Critical (Real-time backup)**
   - Agent registry
   - Task registry
   - Active configurations

2. **High (Daily backup)**
   - System logs
   - Metrics data
   - Processed messages

3. **Standard (Weekly backup)**
   - Templates
   - Archived messages
   - Historical trends

4. **Archive (Monthly backup)**
   - Historical logs
   - Old metrics
   - Legacy data

## Validation Requirements
- SHA-256 checksums for all backups
- Integrity verification after backup
- Restore testing procedures
- Access permission validation
- Data consistency checks

