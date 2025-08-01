# Joomla Docker Deployment Toolkit

A professional Docker-based toolkit for deploying, backing up, and restoring Joomla CMS sites with MySQL database.

## Technologies Used

- **Docker**: Container orchestration and deployment
- **MySQL 8.0**: Database server for Joomla
- **Joomla CMS**: Content Management System (latest version)
- **Alpine Linux**: Lightweight container for backup operations
- **Bash**: Shell scripting for automation
- **MySQL Client Tools**: Database backup and restore operations
- **Gzip**: Compression for database backups

## Architecture

The toolkit creates a containerized environment with:

- **MySQL Container**: Database server with persistent volume
- **Joomla Container**: Web application server with persistent volume
- **Docker Network**: Isolated network for secure container communication
- **Backup System**: Automated database and file backup with compression

## Quick Start Guide

### Prerequisites

- Linux machine with Docker installed
- sudo privileges for package installation
- At least 2GB free disk space

### Step-by-Step Deployment

#### 1. Clone and Prepare Environment

```bash
git clone <repository-url>
cd devtools
chmod +x *.sh
```

#### 2. Deploy Joomla Site

```bash
./setup.sh
```

This script will:

- Create Docker network `joomla-net`
- Pull MySQL and Joomla images
- Create persistent volumes
- Start MySQL container with database `joomladb`
- Start Joomla container
- Configure database connectivity

**Access Points:**

- **Main Site**: http://localhost:8080
- **Admin Panel**: http://localhost:8080/administrator

#### 3. Initial Joomla Configuration

1. Open http://localhost:8080 in your browser
2. Complete the Joomla installation wizard:
   - **Database Type**: MySQLi
   - **Database Host**: joomla-mysql
   - **Database Name**: joomladb
   - **Database Username**: joomlauser
   - **Database Password**: joomlapw
   - **Database Prefix**: jos\_

#### 4. Create Backups

```bash
./backup.sh
```

This creates timestamped backups in `./backups/`:

- **Database**: `joomladb.YYYYMMDD_HHMMSS.sql.gz`
- **Site Files**: `joomla_site_data.YYYYMMDD_HHMMSS.tar.gz`

#### 5. Restore from Backup

```bash
./restore.sh
```

Automatically restores from the most recent backup files.

#### 6. Clean Environment

```bash
./cleanup.sh
```

**WARNING**: This completely removes:

- All containers
- All volumes and data
- Docker images
- Network
- Optionally: backup files

## Container Configuration

### MySQL Container

- **Container Name**: `joomla-mysql`
- **Port**: 3306
- **Root Password**: `my-secret-pw`
- **Database**: `joomladb`
- **User**: `joomlauser`
- **Password**: `joomlapw`

### Joomla Container

- **Container Name**: `joomla-site`
- **Port**: 8080 (mapped to container port 80)
- **Volume**: Persistent storage for site files

## File Structure

```
devtools/
├── setup.sh          # Initial deployment script
├── backup.sh          # Create backups of database and files
├── restore.sh         # Restore from latest backups
├── cleanup.sh         # Complete environment cleanup
└── backups/           # Backup storage directory
    ├── joomladb.*.sql.gz        # Compressed database dumps
    └── joomla_site_data.*.tar.gz # Compressed site files
```

## Backup Strategy

### Automated Backup Process

- **Database**: Full MySQL dump with single transaction consistency
- **Files**: Complete Joomla installation archive
- **Compression**: Gzip compression for space efficiency
- **Timestamping**: Automatic timestamp naming for version control

### Backup Files Location

All backups are stored in `./backups/` directory with timestamp naming:

- Database: `joomladb.YYYYMMDD_HHMMSS.sql.gz`
- Site files: `joomla_site_data.YYYYMMDD_HHMMSS.tar.gz`

## Troubleshooting

### Common Issues

**Container Already Exists Error**

```bash
docker rm -f joomla-mysql joomla-site
./setup.sh
```

**Database Connection Failed**

- Verify MySQL container is running: `docker ps`
- Check logs: `docker logs joomla-mysql`

**Backup Fails**

- Ensure sufficient disk space
- Verify MySQL container is accessible
- Check backup directory permissions

**Port Already in Use**

- Modify ports in `setup.sh` if 8080 or 3306 are occupied
- Update both container and host port mappings

### Useful Commands

```bash
# Check container status
docker ps -a

# View container logs
docker logs joomla-site
docker logs joomla-mysql

# Access container shell
docker exec -it joomla-site bash
docker exec -it joomla-mysql bash

# View container resource usage
docker stats
```

## Cleanup and Data Removal

The `cleanup.sh` script provides complete environment cleanup:

1. **Graceful Container Shutdown**: Stops and removes containers
2. **Volume Cleanup**: Removes all persistent data
3. **Image Cleanup**: Removes Docker images to free space
4. **Network Cleanup**: Removes custom Docker network
5. **Optional Backup Cleanup**: Prompts to remove backup files

**Warning**: Cleanup is irreversible. Ensure backups are stored safely before running cleanup.

## Support

For issues with this toolkit:

1. Check container logs for error details
2. Verify Docker daemon is running
3. Ensure sufficient system resources
4. Review script permissions and dependencies

This toolkit provides a complete solution for Joomla development, testing, and backup scenarios with easy deployment and cleanup capabilities.
