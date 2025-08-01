# Devtools Final Project: Joomla Docker Deployment
A Docker based toolkit for deploying, backing up, and restoring Joomla sites with MySQL database.

## Submitted By:
- Or Abramovitch, Ofir Beck, Ariel Blinder

## Technologies Used
- **Docker**: Container orchestration and deployment
- **MySQL 8.0**: Database server for Joomla
- **Joomla**: Content Management System
- **Alpine Linux**: Lightweight container for backup operations
- **Bash**: Shell scripting for automation
- **MySQL Client Tools**: Database backup and restore operations
- **Gzip**: Compression for database backups

## Quick Start Guide

### Prerequisites
- An internet connection
- Linux machine with Docker installed
- sudo privileges for package installation

### Step-by-Step Deployment

#### 1. Clone and Prepare Environment
```bash
git clone https://github.com/ofirbeck/devtools-final-project.git
cd devtools-final-project
chmod +x *.sh
```

#### 2. Deploy Joomla Site
```bash
./setup.sh
```

This script will:
- Create Docker network `joomla-net`
- Pull MySQL and Joomla images
- Create persistent volume for Joomla
- Start MySQL container with database joomladb
- Start Joomla container
- Configure database connectivity

#### 3. Initial Joomla Configuration
##### You could either configure it via Joomla installation wizard, or restore the latest backup by running
```bash
./restore.sh
```

#### 4. Create Backups
```bash
./backup.sh
```
This creates timestamped backups in `./backups/`:
- **Database backup**: `joomladb.YYYYMMDD_HHMMSS.sql.gz`
- **Joomla Volume Backup**: `joomla_site_data.YYYYMMDD_HHMMSS.tar.gz`

#### 5. Once you finish using the site, clean the installed containers(and stop them), images, volumes, network(and optionally backup files)
```bash
./cleanup.sh
```

## Scripts Available
setup.sh - Initial deployment script\
backup.sh - Create backups of database and Joomla volume\
restore.sh - Restore from latest backups saved in backups folder by the backup.sh script\
cleanup.sh - Complete environment cleanup
