# ⛔ Work in Progress

# 🐧 System Update & Docker Management Script

<div align="center">

![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20|%20Debian-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A comprehensive automation script for system updates, package management, and Docker image updates with intelligent log management**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#%EF%B8%8F-configuration)

</div>

---

## 📋 Overview

System Update & Docker Management Script is a powerful automation tool that maintains Ubuntu/Debian-based systems by handling system updates, package management, Docker image updates, and intelligent log rotation—all in one comprehensive solution.

Perfect for:
- 🖥️ System administrators managing multiple servers
- 🔄 Automating routine maintenance tasks
- 🐳 Keeping Docker environments up-to-date
- 📊 Maintaining clean and organized system logs
- ⏰ Setting up automated maintenance schedules

---

## ✨ Features

### 🔧 Comprehensive System Management
- **Complete APT Updates** - Package lists, upgrades, and distribution upgrades
- **Package Repair** - Automatically fixes broken packages
- **Cleanup Operations** - Removes unnecessary packages and cleans APT cache
- **Non-Interactive Mode** - Safe for automation with `DEBIAN_FRONTEND=noninteractive`
- **Error Handling** - Comprehensive error detection and logging
- **Root Privilege Check** - Ensures proper permissions before execution

### 🐳 Docker Image Management
- **Automatic Docker Detection** - Intelligently checks if Docker is installed
- **Bulk Image Updates** - Updates all Docker images with one command
- **Ignore List Support** - Skip specific images using pattern matching
- **Wildcard Patterns** - Flexible image filtering (e.g., `mysql:*`, `*-dev`)
- **Dangling Image Cleanup** - Removes unused image layers automatically
- **Update Statistics** - Reports updated, skipped, and failed images

### 📁 Intelligent Log Management
- **Automatic Rotation** - Compresses logs when reaching 20MB
- **Organized Archives** - Stores compressed logs in dedicated `logs/` directory
- **Timestamped Naming** - Archives named as `update-system.log.YYYYMMDD_HHMMSS.gz`
- **Auto Cleanup** - Removes logs older than 10 days (configurable)
- **Space Efficient** - Compressed archives save significant disk space
- **Migration Support** - Automatically moves old logs to new structure

### 📊 Comprehensive Logging
- **Detailed Timestamps** - Every action logged with precise timing
- **Success/Error Tracking** - Clear differentiation between successful and failed operations
- **Operation Breakdown** - Separate logging for each update phase
- **Real-time Output** - See progress while logging to file
- **Searchable Archives** - Easily grep through compressed logs

---

## 🚀 Installation

### Prerequisites
- Ubuntu 18.04+ or Debian 10+
- Bash 5.0 or later
- Root or sudo privileges
- Docker (optional, for Docker image updates)

### Quick Start

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/janitorio.git
cd janitorio
```

2. **Make the script executable:**
```bash
chmod +x update-system.sh
```

3. **Create Docker ignore list (optional):**
```bash
touch docker-ignore.txt
```

4. **Run the script:**
```bash
sudo ./update-system.sh
```

### Alternative Installation

Download the script directly:
```bash
wget https://raw.githubusercontent.com/yourusername/janitorio/main/update-system.sh
chmod +x update-system.sh
```

---

## 💻 Usage

### Manual Execution

Run the script with sudo privileges:

```bash
sudo ./update-system.sh
```

### Expected Output

```
[2024-01-15 14:30:45] Created logs directory: /path/to/logs
[2024-01-15 14:30:45] =========================================
[2024-01-15 14:30:45] Starting system update process
[2024-01-15 14:30:45] =========================================
[2024-01-15 14:30:52] Updating package lists...
[2024-01-15 14:30:55] SUCCESS: Package lists updated successfully
[2024-01-15 14:31:00] Upgrading packages...
[2024-01-15 14:32:15] SUCCESS: Packages upgraded successfully
[2024-01-15 14:32:20] Performing distribution upgrade...
[2024-01-15 14:32:45] SUCCESS: Distribution upgrade completed successfully
[2024-01-15 14:32:50] Fixing broken packages...
[2024-01-15 14:32:55] SUCCESS: Broken packages fixed successfully
[2024-01-15 14:33:00] Removing unnecessary packages...
[2024-01-15 14:33:10] SUCCESS: Unnecessary packages removed successfully
[2024-01-15 14:33:15] Cleaning APT cache...
[2024-01-15 14:33:18] SUCCESS: APT cache cleaned successfully
[2024-01-15 14:33:20] Docker is installed
[2024-01-15 14:33:20] Starting Docker image updates...
[2024-01-15 14:33:22] Pulling latest version of nginx:latest...
[2024-01-15 14:33:45] SUCCESS: Successfully updated nginx:latest
[2024-01-15 14:34:00] Skipping ignored image: mysql:5.7
[2024-01-15 14:34:05] Docker update summary: 5 updated, 2 skipped, 0 failed
[2024-01-15 14:34:05] =========================================
[2024-01-15 14:34:05] System update process completed
[2024-01-15 14:34:05] =========================================

Update completed! Check /path/to/update-system.log for details.
Archived logs are stored in: /path/to/logs
```

### Automated Scheduling with Cron

#### Weekly Updates (Recommended)
```bash
# Edit crontab
sudo crontab -e

# Add this line for weekly updates every Sunday at 2 AM
0 2 * * 0 /path/to/update-system.sh >> /var/log/system-update-cron.log 2>&1
```

#### Daily Updates
```bash
# Daily updates at 3 AM
0 3 * * * /path/to/update-system.sh >> /var/log/system-update-cron.log 2>&1
```

#### Monthly Updates
```bash
# First day of each month at 4 AM
0 4 1 * * /path/to/update-system.sh >> /var/log/system-update-cron.log 2>&1
```

### Systemd Service (Advanced)

Create a systemd service for more control:

#### 1. Create service file:
```bash
sudo nano /etc/systemd/system/system-update.service
```

```ini
[Unit]
Description=System and Docker Update Service
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/path/to/update-system.sh
StandardOutput=journal
StandardError=journal
SyslogIdentifier=system-update
User=root

[Install]
WantedBy=multi-user.target
```

#### 2. Create timer file:
```bash
sudo nano /etc/systemd/system/system-update.timer
```

```ini
[Unit]
Description=Run system updates weekly
Requires=system-update.service

[Timer]
OnCalendar=Sun *-*-* 02:00:00
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
```

#### 3. Enable and start the timer:
```bash
sudo systemctl daemon-reload
sudo systemctl enable system-update.timer
sudo systemctl start system-update.timer
```

#### 4. Check timer status:
```bash
sudo systemctl status system-update.timer
sudo systemctl list-timers system-update.timer
```

---

## ⚙️ Configuration

### Script Variables

Edit these variables at the top of `update-system.sh` to customize behavior:

```bash
# Log Configuration
LOG_DIR="${SCRIPT_DIR}/logs"              # Directory for archived logs
LOG_FILE="${SCRIPT_DIR}/update-system.log" # Current log file path
LOG_MAX_SIZE=$((20 * 1024 * 1024))        # Max size before rotation (20MB)
LOG_RETENTION_DAYS=10                      # Days to keep old logs

# Docker Configuration
DOCKER_IGNORE_FILE="${SCRIPT_DIR}/docker-ignore.txt"  # Ignore list location
```

### Docker Ignore List

Create a `docker-ignore.txt` file to skip specific Docker images:

**Format:**
```
# Lines starting with # are comments
# Exact image match
mysql:5.7

# Wildcard patterns
*-dev
*:rc-*
redis:*-alpine

# Multiple wildcards
test/*:latest
staging/*/*

# Real-world examples
node:*-alpine           # Skip all Alpine-based Node images
postgres:13.*           # Skip all PostgreSQL 13.x versions
myapp:*-debug          # Skip all debug builds
*/test:*               # Skip all test images from any repository
```

**Pattern Matching Rules:**
- `*` matches any characters within a segment
- Patterns are matched against full image names (repository:tag)
- Empty lines and comments (starting with #) are ignored
- Case-sensitive matching

**Examples:**

```bash
# Skip all MySQL 5.x versions
mysql:5.*

# Skip all development images
*-dev
*-development

# Skip specific registry images
registry.company.com/project/*

# Skip all tagged with 'latest'
*:latest

# Skip beta and rc versions
*:*-beta
*:*-rc*
```

### Directory Structure

After installation and first run:

```
janitorio/
├── update-system.sh              # Main script
├── docker-ignore.txt             # Docker ignore patterns
├── update-system.log             # Current log file
└── logs/                         # Archived logs directory
    ├── update-system.log.20240115_143022.gz
    ├── update-system.log.20240114_020015.gz
    └── update-system.log.20240113_155030.gz
```

---

## 📊 Log Management

### Viewing Logs

#### Current Log
```bash
# View entire log
cat update-system.log

# Follow log in real-time
tail -f update-system.log

# View last 50 lines
tail -n 50 update-system.log

# Search for errors
grep ERROR update-system.log
```

#### Archived Logs
```bash
# List all archived logs
ls -lh logs/

# View compressed log
zcat logs/update-system.log.20240115_143022.gz | less

# Search in compressed log
zgrep "ERROR" logs/update-system.log.20240115_143022.gz

# Search all archived logs
zgrep "Docker" logs/*.gz

# Count errors in all logs
zgrep -c "ERROR" logs/*.gz
```

### Log Rotation Behavior

**Automatic Rotation Triggers:**
- When current log file reaches 20MB
- Compressed with gzip (typically 90-95% compression)
- Moved to `logs/` directory with timestamp
- Current log file truncated and continues

**Cleanup Process:**
- Runs every time the script executes
- Deletes compressed logs older than 10 days
- Keeps current log file regardless of age

### Manual Log Management

```bash
# Manually compress current log
gzip -c update-system.log > logs/update-system.log.$(date +%Y%m%d_%H%M%S).gz
> update-system.log

# Delete all logs older than 30 days
find logs/ -name "*.gz" -type f -mtime +30 -delete

# Check total log disk usage
du -sh logs/

# Count total archived logs
ls logs/*.gz | wc -l
```

---

## 🎯 Use Cases

### 1. Production Server Maintenance
```bash
# Weekly automated updates via cron
0 2 * * 0 /path/to/update-system.sh

# Perfect for:
- Web servers (Apache, Nginx)
- Database servers (MySQL, PostgreSQL)
- Application servers
- Container hosts
```

### 2. Development Environment Sync
```bash
# Keep dev environments updated
# Run daily to match production updates

# Skip development Docker images
echo "*-dev" >> docker-ignore.txt
echo "*:development" >> docker-ignore.txt
```

### 3. CI/CD Pipeline Integration
```bash
#!/bin/bash
# pre-deployment.sh

# Update system before deployment
/path/to/update-system.sh

# Check exit code
if [ $? -eq 0 ]; then
    echo "System updated successfully, proceeding with deployment"
    # Continue deployment
else
    echo "System update failed, aborting deployment"
    exit 1
fi
```

### 4. Multi-Server Management
```bash
# Update multiple servers via SSH
servers=("server1.example.com" "server2.example.com" "server3.example.com")

for server in "${servers[@]}"; do
    echo "Updating $server..."
    ssh root@$server 'bash -s' < update-system.sh
done
```

### 5. Disaster Recovery Prep
```bash
# Monthly full system update with backup
# Backup critical data
tar -czf /backup/system-$(date +%Y%m%d).tar.gz /etc /var/www /home

# Run system update
/path/to/update-system.sh

# Verify system health
systemctl status
docker ps -a
```

---

## 🛠️ Technical Details

### Update Process Flow

```
┌─────────────────────────────────────┐
│    Initialize & Check Privileges    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Create Logs Directory          │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Check & Rotate Logs (20MB)      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Update Package Lists (apt)     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       Upgrade Packages (apt)        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Distribution Upgrade (apt)       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Fix Broken Packages (apt)      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Remove Unnecessary Packages      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         Clean APT Cache             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Check Docker Installation      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Load Docker Ignore List         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Pull Latest Docker Images      │
│      (Skip ignored patterns)        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│    Clean Dangling Docker Images     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      Log Final Summary & Exit       │
└─────────────────────────────────────┘
```

### APT Operations

**Commands Used:**
- `apt-get update` - Updates package lists from repositories
- `apt-get upgrade -y` - Installs available upgrades for all packages
- `apt-get dist-upgrade -y` - Handles changing dependencies with new versions
- `apt-get install -f -y` - Fixes broken package dependencies
- `apt-get autoremove -y` - Removes packages that are no longer needed
- `apt-get clean` - Clears local repository of retrieved package files

**Safety Features:**
- `DEBIAN_FRONTEND=noninteractive` - Prevents interactive prompts
- Error checking after each operation
- Detailed logging of all operations
- Root privilege verification

### Docker Operations

**Image Update Process:**
1. Lists all images with `docker images --format`
2. Filters out `<none>` tagged images
3. Checks each image against ignore patterns
4. Pulls latest version with `docker pull`
5. Logs success or failure for each image
6. Cleans up dangling images with `docker image prune -f`

**Pattern Matching:**
- Converts shell wildcards (*) to regex patterns
- Performs full image name matching (repository:tag)
- Case-sensitive comparison
- Supports multiple wildcards per pattern

---

## 🐛 Troubleshooting

### Common Issues

#### Permission Denied
```bash
ERROR: This script must be run as root or with sudo
```
**Solution:**
```bash
sudo ./update-system.sh
```

#### Docker Not Found
```bash
Docker is not installed, skipping Docker updates
```
**Solution:** This is informational. Install Docker if needed:
```bash
curl -fsSL https://get.docker.com | sh
```

#### Log Directory Creation Failed
```bash
ERROR: Failed to create logs directory
```
**Solution:** Check parent directory permissions:
```bash
ls -ld /path/to/script/directory
chmod 755 /path/to/script/directory
```

#### APT Lock Error
```bash
ERROR: Could not get lock /var/lib/dpkg/lock-frontend
```
**Solution:** Another package manager is running:
```bash
# Wait for other operations to finish or:
sudo killall apt apt-get
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo dpkg --configure -a
```

#### Docker Image Pull Fails
```bash
ERROR: Failed to update nginx:latest
```
**Solution:** Check Docker daemon and network:
```bash
sudo systemctl status docker
sudo docker pull nginx:latest  # Test manually
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Add at top of script after shebang
set -x  # Enable debug mode
set -e  # Exit on error
set -u  # Exit on undefined variable
```

### Checking Script Status

```bash
# View recent log entries
tail -n 100 update-system.log

# Check for errors
grep -i error update-system.log

# Check last run time
ls -l update-system.log

# View archived logs
ls -lh logs/

# Check cron execution (if scheduled)
grep CRON /var/log/syslog | grep update-system
```

---

## 📈 Performance Considerations

### Execution Time

Typical execution times (varies by system):
- **Package updates:** 2-10 minutes
- **Docker image updates:** 1-5 minutes per image
- **Log rotation:** < 5 seconds
- **Total:** 5-30 minutes depending on updates available

### Resource Usage

- **CPU:** Moderate during package downloads and compression
- **Memory:** Low (< 100MB for script)
- **Disk I/O:** High during updates and log compression
- **Network:** Depends on update sizes (can be several GB)

### Optimization Tips

```bash
# Schedule during off-peak hours
0 2 * * 0  # 2 AM on Sundays

# Increase log retention, decrease file size for faster rotation
LOG_MAX_SIZE=$((10 * 1024 * 1024))  # 10MB
LOG_RETENTION_DAYS=30                # 30 days

# Limit Docker updates to critical images only
# Add non-critical images to ignore list

# Run on systems with fast internet connection
# Consider local APT mirror for multiple servers
```

---

## 🔒 Security Considerations

### Permissions

```bash
# Recommended file permissions
chmod 750 update-system.sh        # Owner: rwx, Group: r-x, Others: none
chmod 640 docker-ignore.txt       # Owner: rw-, Group: r--, Others: none
chmod 640 update-system.log       # Owner: rw-, Group: r--, Others: none

# Recommended ownership
sudo chown root:root update-system.sh
sudo chown root:root docker-ignore.txt
```

### Audit Trail

All operations are logged with timestamps:
```bash
# Review what was updated
grep "SUCCESS" update-system.log

# Check for failed operations
grep "ERROR" update-system.log

# Monitor Docker image changes
grep "docker pull" update-system.log

# Export audit log
zcat logs/*.gz > full-audit-$(date +%Y%m%d).log
```

---

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**[Report Bug](../../issues)** · **[Request Feature](../../issues)** · **[Documentation](../../wiki)**

Made with ❤️

</div>
