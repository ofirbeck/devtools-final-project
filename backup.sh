#!/bin/bash

set -euo pipefail

MYSQL_CONTAINER_NAME="joomla-mysql"
JOOMLA_VOLUME="joomla_site_data"
MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_DATABASE="joomladb"
BACKUP_ROOT="${PWD}/backups"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DB_BACKUP_FILE="${MYSQL_DATABASE}.${TIMESTAMP}.sql.gz"

echo "Installing MySQL-client-core-8.0:"
sudo apt -y update
sudo apt -y install MySQL-client-core-8.0

mkdir -p "${BACKUP_ROOT}"
echo "Saving MySQL dump to ${BACKUP_ROOT}/${DB_BACKUP_FILE}"

docker exec "${MYSQL_CONTAINER_NAME}" sh -c \
  "exec mysqldump --single-transaction --all-databases -uroot -p\"${MYSQL_ROOT_PASSWORD}\"" 2>/dev/null \
  | gzip > "${BACKUP_ROOT}/${DB_BACKUP_FILE}"

echo "Database backup complete"

VOLUME_BACKUP_FILE="${JOOMLA_VOLUME}.${TIMESTAMP}.tar.gz"
echo "Archiving Joomla volume to ${BACKUP_ROOT}/${VOLUME_BACKUP_FILE}"

docker run --rm \
  -v "${JOOMLA_VOLUME}":/data:ro \
  -v "${BACKUP_ROOT}":/backup \
  alpine \
  tar -czf "/backup/${VOLUME_BACKUP_FILE}" -C /data .

echo "Volume backup complete!"

echo "Backup saved in ${BACKUP_ROOT}"
echo "${DB_BACKUP_FILE} – compressed SQL dump"
echo "${VOLUME_BACKUP_FILE} – Joomla site files"
