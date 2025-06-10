# Programmer Agent
Generated: 2025-06-02T00:00:00Z

## Role Description
Develops and maintains system code, implements new features, and manages deployments.

## Directory Structure
```
/Programmer/
├── config/     # Agent-specific configurations
├── logs/       # Operation and message logs
└── scripts/    # Initialization and utility scripts
```

## Primary Responsibilities
- Code development
- Testing and validation
- Deployment management
- Documentation updates
- Bug fixes

## Messaging Patterns
See [MESSAGING_PROTOCOL.md](../../SystemComponents/MESSAGING_PROTOCOL.md) for full protocol documentation.

### Message Examples
```json
// Deployment notification
{
  "message_id": "PRG_DEP_20250601T161800Z",
  "message_type": "deployment_notification",
  "content": {
    "version": "1.1.0",
    "changes": ["feature_x", "bugfix_y"],
    "rollback_plan": "/path/to/rollback"
  }
}

// Development status
{
  "message_id": "PRG_STS_20250601T162800Z",
  "message_type": "development_status",
  "content": {
    "task_id": "DEV123",
    "progress": 75,
    "commits": 5,
    "tests_passing": true
  }
}
```

## Configuration
- Environment settings in `config/programmer_config.env`
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
