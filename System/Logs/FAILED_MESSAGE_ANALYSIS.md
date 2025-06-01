# Failed Message Analysis Report
Generated: 2025-06-01T16:29:33Z

## Overview
Total Failed Messages: 2
Analysis Date: 2025-06-01T16:29:33Z

## Message Analysis

### Failed Message: msg_005_malformed.json
**Content:**
```json
{
  "message_id": "BAD_MSG_20250601T162107Z",
  "timestamp": "2025-06-01T16:21:07Z",
  "from_agent": "test_agent",
  "message_type": "test_message",
  "content": {
    "test": "incomplete_message"
  }
```

**Analysis:**
- ❌ Invalid JSON format

**Related Error Logs:**
[2025-06-01T16:21:07Z] ERROR: Malformed message detected in msg_005_malformed.json
[2025-06-01T16:21:25Z] ERROR: Invalid JSON format in msg_005_malformed.json
[2025-06-01T16:21:25Z] FAILED: Message validation failed for msg_005_malformed.json

### Failed Message: MSG_20250601T162550_malformed.json
**Content:**
```json
{
  "message_id": "MSG_20250601T162550_ERR",
  "timestamp": "2025-06-01T16:25:50Z",
  "from_agent": "test_agent",
  "message_type": "test_message",
  "content": {
    "incomplete": true
  }
}
```

**Analysis:**
- ✓ Valid JSON format

**Missing Fields:**
- ❌ Missing: to_agent
- ❌ Missing: priority

**Message Type:** test_message

**Related Error Logs:**
[2025-06-01T16:25:55Z] ERROR: Missing required field 'to_agent' in MSG_20250601T162550_malformed.json
[2025-06-01T16:25:55Z] FAILED: Message validation failed for MSG_20250601T162550_malformed.json

## Root Causes
1. Invalid JSON format in older messages
2. Missing required fields from pre-validation messages
3. Schema validation failures from initial test cases

## Recommendations
1. Archive these failed messages as they represent pre-improvement test cases
2. Continue using new message templates and validation
3. Monitor for any new failures with improved validation

## Action Taken
- Failed messages archived to: /home/host/Documents/Machina/MF_Main/SystemComponents/Handoff/archive/failed/202506
- System logs updated
- Validation improvements implemented
