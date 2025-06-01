# Current System Architecture Documentation
Created: 2025-06-01T19:41:38Z
Document Version: 1.0
Status: Pre-Migration Documentation

## 1. System Overview

### Operating System
- Distribution: Ubuntu
- Kernel: Linux 6.11.0-17-generic
- Architecture: x86_64
- Shell: bash 5.2.21(1)-release

## 2. Hardware Specifications

### CPU
- Model: AMD Ryzen 9 5900HS with Radeon Graphics
- Architecture: x86_64
- Cores: 8 physical cores, 16 logical threads
- Clock Speed: 
  - Base: 400 MHz
  - Max Boost: 4.68 GHz
- Cache:
  - L1d: 256 KB (8 instances)
  - L1i: 256 KB (8 instances)
  - L2: 4 MB (8 instances)
  - L3: 16 MB (1 instance)

### Memory
- Total RAM: 32 GB
  - Used: 7.0 GB
  - Free: 227 MB
  - Shared: 140 MB
  - Buffer/Cache: 24 GB
  - Available: 23 GB
- Swap:
  - Total: 8.0 GB
  - Used: 1.0 MB
  - Free: 8.0 GB

## 3. Storage Configuration

### Disk Layout
- Primary Drive (nvme0n1p4):
  - Size: 476 GB
  - Used: 123 GB
  - Available: 329 GB
  - Usage: 28%
  - Mount Point: /

### Additional Partitions
- EFI (nvme0n1p1):
  - Size: 1021 MB
  - Used: 6.2 MB
  - Available: 1015 MB
  - Mount Point: /boot/efi

### Temporary Filesystems
- /run: 3.1 GB
- /dev/shm: 16 GB
- /run/lock: 5.0 MB
- /run/user/1000: 3.1 GB

## 4. Running Services

### Core System Services
- systemd-journald
- systemd-logind
- systemd-oomd
- systemd-resolved
- systemd-timesyncd
- systemd-udevd

### Network Services
- NetworkManager
- wpa_supplicant
- avahi-daemon

### System Management
- accounts-daemon
- cron
- polkit
- udisks2
- upower
- packagekit

### Desktop Environment
- gdm
- colord
- gnome-remote-desktop

### Hardware Management
- bluetooth
- fwupd
- nvidia-persistenced
- power-profiles-daemon
- switcheroo-control

### Printing
- cups
- cups-browsed

### System Maintenance
- unattended-upgrades
- snapd
- ubuntu-advantage-desktop-daemon

## 5. Security Configuration

### CPU Security Features
- Virtualization: AMD-V enabled
- Vulnerability Mitigations:
  - Spectre v1: Mitigated (usercopy/swapgs barriers, __user pointer sanitization)
  - Spectre v2: Mitigated (Retpolines, IBPB conditional, IBRS_FW, STIBP always-on)
  - Spec store bypass: Mitigated
  - Meltdown: Not affected
  - L1tf: Not affected
  - MDS: Not affected
  - MMIO stale data: Not affected
  - Retbleed: Not affected

## 6. Network Configuration
*To be investigated - requires additional network interface and routing information*

## 7. Recommendations for Migration

### Hardware Requirements
- Recommend equivalent or better CPU specifications (minimum 8 cores, 16 threads)
- Minimum 32GB RAM
- Storage: Minimum 500GB NVMe or SSD
- Consider redundant storage options for critical data

### Service Configuration
- Maintain all current running services
- Set up monitoring for service health
- Implement service recovery procedures

### Security Considerations
- Implement equivalent CPU security features
- Set up firewall rules
- Configure secure remote access
- Implement backup solutions
- Set up monitoring and alerting

### Migration Checklist
- [ ] Verify hardware specifications of target system
- [ ] Document network requirements
- [ ] Plan service migration order
- [ ] Create backup strategy
- [ ] Define rollback procedures
- [ ] Set up monitoring
- [ ] Plan maintenance windows

## Notes
- Regular updates to this document will be maintained during migration
- Performance metrics should be collected for comparison
- Service dependencies should be mapped
- Network topology documentation pending

## 8. Network Configuration

### Network Interfaces
1. Loopback (lo):
   - IP: 127.0.0.1/8
   - IPv6: ::1/128
   - MTU: 65536
   - Status: UP

2. Wireless Interface (wlp2s0):
   - MAC: 90:e8:68:c7:9c:6f
   - IP: 192.168.0.145/24
   - IPv6: fe80::1212:6758:97df:19cd/64
   - MTU: 1500
   - Status: UP
   - Network: 192.168.0.0/24
   - Gateway: 192.168.0.1

### Listening Services
- TCP Services:
  - 127.0.0.1:631 (CUPS)
  - 127.0.0.1:6379 (Redis)
  - 127.0.0.53:53 (DNS)
  - 127.0.0.1:9277 (Warp)
  - 0.0.0.0:8000 (Python web server)
  - ::1:631 (CUPS IPv6)
  - ::1:6379 (Redis IPv6)

## 9. Performance Baseline Metrics

### System Load (as of 2025-06-01T19:45:20)
- Load Average: 93.54, 88.78, 78.02
- Tasks: 769 total
  - Running: 93
  - Sleeping: 669
  - Stopped: 0
  - Zombie: 7

### CPU Utilization
- User: 59.7%
- System: 40.3%
- Idle: 0.0%
- I/O Wait: 0.0%
- Hardware Interrupt: 0.0%
- Software Interrupt: 0.0%

### Memory Usage
Current utilization:
- Total RAM: 31.5 GB
- Used: 7.3 GB
- Free: 237 MB
- Buffer/Cache: 24.6 GB
- Available: 24.2 GB
- Swap Used: 1.0 MB out of 8.0 GB

### Disk I/O Performance (nvme0n1)
- Read Operations: 3.29 r/s
- Write Operations: 135.16 w/s
- Read Bandwidth: 137.43 kB/s
- Write Bandwidth: 9348.97 kB/s
- Average Queue Size: 2.16
- Utilization: 5.20%

## 10. Application Services

### Core Services
1. Database Services:
   - Redis (127.0.0.1:6379)

2. Web Services:
   - Python Web Server (0.0.0.0:8000)
   - CUPS Web Interface (631)

3. Network Services:
   - DNS Resolution (systemd-resolved)
   - Network Manager
   - WPA Supplicant
   - Avahi Daemon

4. System Services:
   - System Logger (rsyslog)
   - Cron Daemon
   - Package Management (packagekit)
   - System Updates (unattended-upgrades)

### Development Tools
- Python Runtime
- Firefox Browser
- Warp Terminal

### Service Dependencies
Key dependency chains:
1. Network Stack:
   - NetworkManager → wpa_supplicant
   - systemd-resolved → NetworkManager
   - avahi-daemon → NetworkManager

2. System Core:
   - dbus → systemd
   - polkit → dbus
   - accountsservice → dbus

3. Desktop Environment:
   - gdm → dbus
   - gnome-remote-desktop → gdm
   - colord → dbus

## 11. Performance Recommendations for Migration

### CPU Requirements
- Maintain similar core count (8 cores, 16 threads)
- Ensure base clock speed ≥ 3.0 GHz
- Support for virtualization required

### Memory Sizing
- Minimum: 32 GB RAM
- Swap: 8 GB
- Consider 48 GB for growth

### Storage Requirements
- Primary Storage: ≥ 500 GB NVMe
- I/O Performance:
  - Sustained write: ≥ 10 MB/s
  - Peak write: ≥ 110 MB/s
  - Average queue depth: < 3

### Network Requirements
- Gigabit Ethernet minimum
- Support for IPv6
- Dedicated IP address
- Firewall rules for ports:
  - 8000 (Web Server)
  - 6379 (Redis)
  - 53 (DNS)
  - 22 (SSH)

