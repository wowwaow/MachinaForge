# Systems_Architect Agent
Generated: 2025-06-01T16:19:47Z

## Role Description
Designs and maintains system architecture, manages dependencies, and ensures system integrity.

## Directory Structure
```
/Systems_Architect/
├── config/     # Agent-specific configurations
├── logs/       # Operation and message logs
└── scripts/    # Initialization and utility scripts
```

## Primary Responsibilities
- Architecture design
- Dependency management
- System integration
- Performance optimization
- Scalability planning

## Messaging Patterns
See [MESSAGING_PROTOCOL.md](../../SystemComponents/MESSAGING_PROTOCOL.md) for full protocol documentation.

### Message Examples
```json
// Architecture update
{
  "message_id": "ARC_UPD_20250601T161800Z",
  "message_type": "architecture_update",
  "content": {
    "component": "message_bus",
    "changes": ["new_queue", "improved_routing"],
    "dependencies": ["redis", "rabbitmq"]
  }
}

// System assessment
{
  "message_id": "ARC_ASS_20250601T162800Z",
  "message_type": "system_assessment",
  "content": {
    "components": ["messaging", "storage"],
    "health_status": "optimal",
    "recommendations": ["scale_queue_workers"]
  }
}
```

## Configuration
- Environment settings in `config/systems_architect_config.env`
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
