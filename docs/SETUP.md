# 🚀 MachinaForge Setup Guide

## Prerequisites

### System Requirements
- Python 3.8+
- Git 2.0+
- Sufficient system resources for multi-agent operations
- Linux/Unix-based operating system (recommended)

### Environment Setup
1. **Python Installation**
   ```bash
   python3 --version  # Must be 3.8+
   pip3 --version
   ```

2. **Git Installation**
   ```bash
   git --version  # Must be 2.0+
   ```

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/wowwaow/MachinaForge.git
cd MachinaForge
```

### 2. Environment Setup
```bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
.\venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

### 3. Configuration
```bash
# Copy example configuration
cp .env.example .env
```

Edit `.env` with your specific settings:
```ini
SYSTEM_DIR=/path/to/installation
LOG_LEVEL=INFO
AGENT_POOL_SIZE=5
HEALTH_CHECK_INTERVAL=60
```

## Directory Structure Setup

### 1. Create Required Directories
```bash
mkdir -p System/{Commands,Logs,Rules} \
        Objectives/{Current,Future,Past} \
        Agents/{Status,Registry,Handoff} \
        Tasks/{Pool,Assigned,Missing} \
        Tools/SSH
```

### 2. Set Permissions
```bash
chmod -R 755 System/Commands
chmod -R 644 System/Logs
chmod -R 644 System/Rules
```

## Initial Configuration

### 1. Agent Configuration
```bash
# Generate agent identities
python scripts/generate_agent_ids.py

# Configure agent roles
python scripts/configure_agents.py
```

### 2. System Initialization
```bash
# Initialize system components
python initialize.py

# Verify installation
python verify_setup.py
```

## Health Check Setup

### 1. Configure Monitoring
```bash
# Set up health monitoring
python scripts/setup_monitoring.py

# Configure alerts
python scripts/configure_alerts.py
```

### 2. Verify Monitoring
```bash
# Test monitoring system
python scripts/test_monitoring.py
```

## Security Configuration

### 1. Access Control Setup
```bash
# Configure RBAC
python scripts/setup_rbac.py

# Generate access tokens
python scripts/generate_tokens.py
```

### 2. Security Verification
```bash
# Run security checks
python scripts/verify_security.py
```

## Running the System

### 1. Start Core Services
```bash
# Start agent manager
python run_agents.py

# Start monitoring
python run_monitoring.py
```

### 2. Verify Operation
```bash
# Check system status
python check_status.py

# View logs
tail -f System/Logs/system.log
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Fix permissions
   chmod -R 755 Scripts/
   chmod -R 644 Logs/
   ```

2. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep LISTEN
   ```

3. **Resource Issues**
   ```bash
   # Check resource usage
   top
   df -h
   ```

### Health Checks

1. **System Health**
   ```bash
   python health_check.py
   ```

2. **Agent Status**
   ```bash
   python check_agents.py
   ```

## Maintenance

### Regular Tasks

1. **Log Rotation**
   ```bash
   # Setup log rotation
   python setup_log_rotation.py
   ```

2. **Backup Configuration**
   ```bash
   # Configure backups
   python configure_backups.py
   ```

### Updates

1. **System Updates**
   ```bash
   git pull origin main
   pip install -r requirements.txt
   python update_system.py
   ```

2. **Configuration Updates**
   ```bash
   python update_config.py
   ```

## Next Steps

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design details
2. Check [AGENTS.md](AGENTS.md) for agent configuration
3. Read [PROTOCOLS.md](PROTOCOLS.md) for communication standards
4. See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines

Last Updated: 2025-06-01

