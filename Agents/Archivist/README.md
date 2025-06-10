# Archivist Agent
Generated: 2025-06-02T00:00:00Z

## Role Description
Maintains historical records, archives completed tasks, and ensures system traceability.

## Directory Structure
```
/Archivist/
├── config/     # Agent-specific configurations
├── logs/       # Operation and message logs
└── scripts/    # Initialization and utility scripts
```

## Primary Responsibilities
- Data archival and retrieval
- Version history maintenance
- Audit trail management
- Record organization
- Archive integrity verification

## Messaging Patterns
See [MESSAGING_PROTOCOL.md](../../SystemComponents/MESSAGING_PROTOCOL.md) for full protocol documentation.

### Message Examples
```json
// Archiving request
{
  "message_id": "ARC_REQ_20250601T161800Z",
  "message_type": "archive_request",
  "content": {
    "data": "/path/to/archive",
    "retention_period": "90d",
    "metadata": {
      "project": "MachinaForge",
      "version": "1.0.0"
    }
  }
}

// Archive confirmation
{
  "message_id": "ARC_CON_20250601T162800Z",
  "message_type": "archive_confirmation",
  "content": {
    "archive_id": "ARC123",
    "location": "/archives/2025/06",
    "checksum": "sha256_hash",
    "access_path": "/path/to/archived/data"
  }
}
```

## Configuration
- Environment settings in `config/archivist_config.env`
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
