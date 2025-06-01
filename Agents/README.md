# 📦 MachinaForge Agents Overview & Messaging Protocol

This directory contains all active **agent roles** in the MachinaForge system. Each agent operates autonomously but can coordinate with others using defined communication paths.

---

## 🔑 Agent Roles

| Agent Role             | Description                                                                     |
| ---------------------- | ------------------------------------------------------------------------------- |
| **Analyst**            | Analyzes collected data, generates insights, supports decision-making.          |
| **Archivist**          | Maintains historical records, archives completed tasks, ensures traceability.   |
| **Data_Collector**     | Gathers external and internal data sources, feeds raw data to the system.       |
| **Janitor**            | Documents active paths, cleans up directories, deletes stale or orphaned files. |
| **Overseer**           | Central coordinator, manages agent orchestration, role assignments, objectives. |
| **Programmer**         | Builds, tests, and deploys system code or logic updates; maintains pipelines.   |
| **Systems_Architect**  | Designs and updates system architecture, oversees dependency structures.        |

---

## 📡 Agent Messaging & Coordination Protocol

### Messaging Channels

Agents communicate through **shared directories** and files:

```
/SystemComponents/Handoff/ → for passing tasks, states, or messages
/SystemComponents/Registry/ → for role + capability lookups
/SystemComponents/Status/ → for health and heartbeat updates
```

---

### Message Workflow Example

✅ **When Analyst needs data:**
* Analyst checks `Registry` for active Data_Collector.
* Posts request file to `Handoff/` (e.g., `request_data_DC123.json`).
* Data_Collector picks up the request, processes, and posts response in `Handoff/`.

✅ **When Janitor cleans up:**
* Logs cleanup actions in `Janitor/logs/`.
* Notifies Overseer by posting `janitor_report.json` in `Handoff/`.

✅ **When Programmer deploys update:**
* Updates `Status` to signal deployment.
* Posts update summary in `Handoff/` for Architect + Overseer review.

✅ **When Overseer coordinates:**
* Reads all active statuses from `Status/`.
* Posts role assignment or escalation instructions in `Handoff/`.
* Updates global `SYSTEM_STATUS.md`.

---

### 🔐 Communication Rules

* All messages use **standardized file formats** (JSON or Markdown).
* Critical updates are **timestamped in UTC**.
* Every agent **logs its outgoing and incoming messages**.
* Overseer has final authority to resolve conflicts or escalate tasks.

---

## 📂 Folder Expectations

Each agent folder contains:

```
/config/ → configs + settings
/logs/ → operational + message logs
/scripts/ → init + utility scripts
README.md → role-specific responsibilities
```

---

## 🛠 System Integration

All agents are registered in:
```
/SystemComponents/Registry/AGENT_REGISTRY.json
```

Heartbeat + health statuses are tracked in:
```
/SystemComponents/Status/HEARTBEAT_MONITOR.json
```

Message handoffs + coordination happen in:
```
/SystemComponents/Handoff/
```

---

## 📝 Message Format Examples

### Task Request Message
```json
{
  "message_id": "REQ_{{timestamp}}",
  "timestamp": "{{utc_timestamp}}",
  "from_agent": "analyst_001",
  "to_agent": "data_collector_001",
  "message_type": "task_request",
  "priority": "normal",
  "content": {
    "task_id": "DC123",
    "task_type": "data_collection",
    "parameters": {
      "data_source": "external_api",
      "data_type": "market_metrics",
      "time_range": "last_24h"
    },
    "deadline": "{{utc_timestamp_plus_1h}}"
  }
}
```

### Task Response Message
```json
{
  "message_id": "RES_{{timestamp}}",
  "timestamp": "{{utc_timestamp}}",
  "from_agent": "data_collector_001",
  "to_agent": "analyst_001",
  "message_type": "task_response",
  "reference_id": "REQ_{{timestamp}}",
  "content": {
    "task_id": "DC123",
    "status": "completed",
    "result_location": "/path/to/collected/data",
    "metadata": {
      "records_collected": 1000,
      "processing_time": "45s",
      "data_format": "json"
    }
  }
}
```

### Status Update Message
```json
{
  "message_id": "STATUS_{{timestamp}}",
  "timestamp": "{{utc_timestamp}}",
  "from_agent": "programmer_001",
  "to_agent": "overseer",
  "message_type": "status_update",
  "content": {
    "deployment_id": "DEP456",
    "status": "in_progress",
    "progress": 75,
    "eta": "{{utc_timestamp_plus_30m}}",
    "details": {
      "phase": "testing",
      "tests_passed": 95,
      "tests_failed": 2,
      "tests_pending": 3
    }
  }
}
```

### System Alert Message
```json
{
  "message_id": "ALERT_{{timestamp}}",
  "timestamp": "{{utc_timestamp}}",
  "from_agent": "janitor",
  "to_agent": "overseer",
  "message_type": "system_alert",
  "priority": "high",
  "content": {
    "alert_type": "disk_space",
    "severity": "warning",
    "details": {
      "directory": "/path/to/logs",
      "current_usage": "85%",
      "threshold": "90%",
      "recommendation": "Archive logs older than 7 days"
    }
  }
}
```

### Role Assignment Message
```json
{
  "message_id": "ROLE_{{timestamp}}",
  "timestamp": "{{utc_timestamp}}",
  "from_agent": "overseer",
  "to_agent": "all",
  "message_type": "role_assignment",
  "content": {
    "assignments": [
      {
        "agent_id": "agent_001",
        "assigned_role": "programmer",
        "capabilities": ["python", "docker", "git"],
        "active_tasks": ["DEP456"]
      }
    ],
    "effective_from": "{{utc_timestamp}}"
  }
}
```

