# 🔒 Machina Hetzner Server Documentation
Version: 1.0
Last Updated: 2025-06-01T20:15:00Z
Status: Production

⚠️ **SECURITY NOTICE**
- This document contains system configuration information
- All credentials and sensitive data must be stored in secure credential storage
- Never share or commit actual credentials
- Follow all security protocols when accessing server

## Server Specifications

### Hardware Configuration
- Instance Type: CCX42
- CPU: 8 vCPU cores
- RAM: 32GB
- Storage: 400GB NVMe
- Network: 1 Gbps dedicated connection
- Backup Space: 200GB

### System Requirements
- Operating System: Ubuntu Linux
- Python 3.8+ (Current: 3.12.3)
- Docker Engine
- Git 2.43.0+

### Security Features
- DDoS Protection
- Network Security Groups
- VPN Access
- Regular Snapshots
- Automated Backups

## Access Information

### Server Details
- Environment: Production
- Location: [REDACTED]
- Domain: [CONFIGURED IN SECURE STORAGE]
- IP: [CONFIGURED IN SECURE STORAGE]

### Access Protocols
1. VPN access required for all connections
2. SSH key-based authentication only
3. Root login disabled
4. Access logged and monitored
5. 2FA required for control panel

## Security Protocols

### Credential Management
- All credentials stored in secure password manager
- Credentials rotated every 90 days
- Access requires management approval
- Audit logs maintained for all access

### Required Access Credentials
All credentials and access tokens must be obtained from the secure credential storage system. Required credentials include:

1. Server Access
   - Primary system access credentials
   - Infrastructure management tokens
   - System user authentication data

2. Service Authentication
   - Primary service credentials
   - Database authentication data
   - Monitoring system access tokens

3. Management Access
   - Administrative access credentials
   - Backup system authentication
   - Monitoring system tokens

### Environment Configuration
The system requires specific environment configuration parameters that must be securely stored and managed. Contact the security team for:

1. Server Configuration Parameters
   - System identification values
   - Network configuration data
   - Service account details

2. Application Parameters
   - Service authentication tokens
   - Database connection parameters
   - System integration credentials

NOTE: All configuration values must be obtained through the secure credential management system. Never store or transmit these values in plain text.

## Deployment Package

### Deployment Package Integrity

#### Critical Files
The deployment package includes the following critical files that require integrity verification:

1. Configuration Files
   - System_Map/MCP_READINESS_REPORT.json
   - services/nginx/conf.d/default.conf
   - docker-compose.yml

2. Dockerfiles
   - services/php/Dockerfile
   - services/nginx/Dockerfile

3. Configuration Files
   - services/php/php.ini

4. Deployment Scripts
   - scripts/deploy.sh
   - scripts/install_docker.sh
   - scripts/setup.sh

#### Integrity Verification
1. Download the official checksum file from the secure artifact repository
2. Verify the checksum file's signature using the security team's public key
3. Run the verification script from the deployment tools:
   ```bash
   ./verify_integrity.sh machina_hetzner_deploy.tar.gz
   ```

IMPORTANT: Do not proceed with deployment if integrity verification fails. Contact the security team immediately if discrepancies are found.

### Deployment Scripts
- setup.sh: System preparation and basic configuration
- install_docker.sh: Docker environment setup
- deploy.sh: Service deployment and configuration

## Monitoring & Maintenance

### Health Checks
- Service Status: http://localhost:8000/health
- Docker Service Status: docker compose ps
- System Logs: docker compose logs
- Resource Monitoring: Configured in monitoring dashboard

### Backup Procedures
1. Automated daily backups
2. Weekly system snapshots
3. Monthly full system backup
4. All backups encrypted at rest
5. Backup retention: 30 days

### Recovery Procedures
```bash
# Service level rollback
cd /opt/machina
docker compose down
docker compose up -d

# Full system rollback
cd /opt/machina/backups
sudo tar xzf backup_[TIMESTAMP].tar.gz -C /opt/machina
docker compose up -d
```

## Important Notes

### Current Status
- Production system active
- Regular backups configured
- Monitoring active
- All services operational

### Security Reminders
- Never share credentials
- Always use VPN for access
- Report security incidents immediately
- Follow least privilege principle
- Monitor audit logs regularly

### Emergency Contacts
- System Administrator: [CONFIGURED IN SECURE STORAGE]
- Security Team: [CONFIGURED IN SECURE STORAGE]
- DevOps Team: [CONFIGURED IN SECURE STORAGE]

---

🔐 **SECURITY ADVISORY**
- This document is for authorized personnel only
- Report any security concerns immediately
- Regular security audits required
- Keep all credentials in secure storage
- Follow security protocols at all times

