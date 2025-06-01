# Janitor Agent
Generated: 2025-06-01T16:19:47Z

## Role Description
Maintains system cleanliness by documenting paths, cleaning directories, and removing stale files.

## Directory Structure
```
/Janitor/
├── config/     # Agent-specific configurations
├── logs/       # Operation and message logs
└── scripts/    # Initialization and utility scripts
```

## Primary Responsibilities
- Directory structure maintenance
- Stale file cleanup
- Path documentation
- Log rotation and archival
- Disk space optimization

## Messaging Patterns
See [MESSAGING_PROTOCOL.md](../../SystemComponents/MESSAGING_PROTOCOL.md) for full protocol documentation.

### Message Examples
```json
// Cleanup notification
{
  "message_id": "JAN_NOT_20250601T161800Z",
  "message_type": "cleanup_notification",
  "content": {
    "action": "file_cleanup",
    "target": "/path/to/clean",
    "criteria": {
      "older_than": "7d",
      "type": "logs"
    }
  }
}

// Cleanup report
{
  "message_id": "JAN_REP_20250601T162800Z",
  "message_type": "cleanup_report",
  "content": {
    "files_removed": 100,
    "space_freed": "500MB",
    "archived_files": 50,
    "errors": []
  }
}
```

## Configuration
- Environment settings in `config/janitor_config.env`
- Logging configuration in `config/logging.json`
- Role-specific settings in `config/agent_config.json`

## Scripts
- `init.sh` - Agent initialization
- `monitor.sh` - Status monitoring
- Role-specific utility scripts

## Logging
- Operational logs in `logs/agent.log`
- Message logs in `logs/messages.log`
- Error logs in `logs/error.log`

## Integration Points
- Registers with Overseer via `AGENT_REGISTRY.json`
- Maintains heartbeat in `HEARTBEAT_MONITOR.json`
- Exchanges messages via `SystemComponents/Handoff/`

## Health Checks
- Heartbeat interval: 60 seconds
- Status updates: Every 5 minutes
- Error reporting: Immediate

## Error Handling
- Logs errors to `logs/error.log`
- Reports critical errors to Overseer
- Implements automatic retry for recoverable errors

## Dependencies
- System components required for operation
- Integration points with other agents
- Required external tools or services
