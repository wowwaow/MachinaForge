# MachinaForge Service Inventory
Version: 1.0
Generated: 2025-06-01T18:49:59Z

## Core Services

### 1. Master Control Program (MCP)
- **Type**: Control Plane
- **Dependencies**: Redis, API Key
- **Resources**:
  - CPU: Dedicated cores
  - Memory: 4GB minimum
  - Storage: 20GB
- **Endpoints**:
  - /status (GET)
  - /baseline (GET)

### 2. Heartbeat Service
- **Type**: System Health
- **Dependencies**: Redis
- **Resources**:
  - Memory: 2GB
  - Storage: 10GB
- **Update Frequency**: 30s

### 3. Metrics Collection
- **Type**: Monitoring
- **Dependencies**: None
- **Resources**:
  - Storage: 20GB (7d retention)
- **Update Frequency**: 60s

### 4. Message Queue System
- **Type**: Communication
- **Dependencies**: None
- **Resources**:
  - Memory: 4GB
  - Storage: 50GB
- **Retention**: 24h active, 7d processed

## Agent Services

### 1. Overseer Agent
- **Type**: Management
- **Dependencies**: MCP, Registry
- **Resources**:
  - Memory: 2GB
  - Storage: 10GB
- **Functions**:
  - Role management
  - Task coordination
  - Status monitoring

### 2. Analyst Agent
- **Type**: Data Analysis
- **Dependencies**: Data Collector
- **Resources**:
  - Memory: 4GB
  - Storage: 20GB
- **Functions**:
  - Data analysis
  - Insight generation
  - Report creation

### 3. Archivist Agent
- **Type**: Data Management
- **Dependencies**: Storage System
- **Resources**:
  - Memory: 2GB
  - Storage: 100GB
- **Functions**:
  - Data archival
  - Backup management
  - Recovery operations

### 4. Data Collector Agent
- **Type**: Data Acquisition
- **Dependencies**: None
- **Resources**:
  - Memory: 2GB
  - Storage: 50GB
- **Functions**:
  - Data collection
  - Data transformation
  - Data validation

### 5. Janitor Agent
- **Type**: Maintenance
- **Dependencies**: None
- **Resources**:
  - Memory: 1GB
  - Storage: 10GB
- **Functions**:
  - Cleanup operations
  - Resource optimization
  - Path management

### 6. Programmer Agent
- **Type**: Development
- **Dependencies**: Version Control
- **Resources**:
  - Memory: 4GB
  - Storage: 20GB
- **Functions**:
  - Code development
  - Deployment management
  - Integration testing

### 7. Systems Architect Agent
- **Type**: Architecture
- **Dependencies**: Documentation System
- **Resources**:
  - Memory: 2GB
  - Storage: 10GB
- **Functions**:
  - System design
  - Architecture management
  - Documentation

## Support Services

### 1. Monitoring Dashboard
- **Type**: Visualization
- **Dependencies**: Metrics Collection
- **Resources**:
  - Memory: 1GB
  - Storage: 5GB
- **Update Frequency**: 60s

### 2. Alert Manager
- **Type**: Notification
- **Dependencies**: Monitoring System
- **Resources**:
  - Memory: 1GB
  - Storage: 5GB
- **Channels**: Log, Console

### 3. Registry Service
- **Type**: Management
- **Dependencies**: None
- **Resources**:
  - Memory: 1GB
  - Storage: 5GB
- **Update Frequency**: Real-time

