# Overseer Agent
Generated: 2025-06-02T00:00:00Z

## Role Description
Coordinates system operations, manages agent assignments, and maintains system health.

## Directory Structure
```
/Overseer/
├── config/     # Agent-specific configurations
├── logs/       # Operation and message logs
└── scripts/    # Initialization and utility scripts
```

## Primary Responsibilities
- Agent coordination
- Task assignment
- System monitoring
- Resource allocation
- Conflict resolution

## Messaging Patterns
See [MESSAGING_PROTOCOL.md](../../SystemComponents/MESSAGING_PROTOCOL.md) for full protocol documentation.

### Message Examples
```json
// Role assignment
{
  "message_id": "OVR_ASN_20250601T161800Z",
  "message_type": "role_assignment",
  "content": {
    "agent_id": "agent_123",
    "role": "programmer",
    "capabilities": ["python", "docker"],
    "active_tasks": ["DEP456"]
  }
}

// System status update
{
  "message_id": "OVR_STS_20250601T162800Z",
  "message_type": "system_status",
  "content": {
    "active_agents": 5,
    "system_health": "optimal",
    "resource_usage": {
      "cpu": "45%",
      "memory": "60%"
    }
  }
}
```

## Configuration
- Environment settings in `config/overseer_config.env`
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
