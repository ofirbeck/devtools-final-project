#!/bin/bash

set -euo pipefail

JOOMLA_CONTAINER_NAME="joomla-site"
MYSQL_CONTAINER_NAME="joomla-mysql"
MYSQL_USER="root"
MYSQL_PASS="my-secret-pw"
DB_NAME="joomla"
BACKUP_ROOT="${PWD}/backups"
JOOMLA_VOLUME="joomla_site_data"
MYSQL_DATABASE="joomladb"

DB_BACKUP_FILE=""
JOOMLA_BACKUP_FILE=""

DB_BACKUP_FILE=$(ls -1t "${BACKUP_ROOT}"/${MYSQL_DATABASE}.*.sql.gz 2>/dev/null | head -n 1 || true)
if [[ -z "${DB_BACKUP_FILE}" ]]; then
  echo "No db backup file specified and none found in ${BACKUP_ROOT}" >&2
  exit 1
fi

if [[ ! -f "${DB_BACKUP_FILE}" ]]; then
  echo "DB Backup file '${DB_BACKUP_FILE}' not found." >&2
  exit 1
fi

JOOMLA_BACKUP_FILE=$(ls -1t "${BACKUP_ROOT}"/${JOOMLA_VOLUME}.*.tar.gz 2>/dev/null | head -n 1 || true)
if [[ -z "${JOOMLA_BACKUP_FILE}" ]]; then
  echo "No joomla backup file specified and none found in ${BACKUP_ROOT}" >&2
  exit 1
fi

if [[ ! -f "${JOOMLA_BACKUP_FILE}" ]]; then
  echo "joomla Backup file '${JOOMLA_BACKUP_FILE}' not found." >&2
  exit 1
fi

echo "Using DB backup file: ${DB_BACKUP_FILE}"

echo "Using Joomla backup file: ${JOOMLA_BACKUP_FILE}"

echo "Dropping existing database (if any)"
docker exec "${MYSQL_CONTAINER_NAME}" sh -c \
"exec mysql -u${MYSQL_USER} -p\"${MYSQL_PASS}\" -e \"DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME};\"" 2>/dev/null

echo "Importing database"
gunzip < "${DB_BACKUP_FILE}" | docker exec -i "${MYSQL_CONTAINER_NAME}" sh -c \
  "exec mysql -u${MYSQL_USER} -p\"${MYSQL_PASS}\"" 2>/dev/null

if docker ps --format '{{.Names}}' | grep -q "^${JOOMLA_CONTAINER_NAME}$"; then
  echo "Restoring Joomla container '${JOOMLA_CONTAINER_NAME}'"
  docker run --rm \
  -v "${JOOMLA_VOLUME}":/target \
  -v "${BACKUP_ROOT}":/backup \
  alpine \
  sh -c "rm -rf /target/* && tar -xzf /backup/$(basename "$JOOMLA_BACKUP_FILE") -C /target"
  docker restart "${JOOMLA_CONTAINER_NAME}" >/dev/null
  echo "Joomla container restarted."
else
  echo "Joomla container '${JOOMLA_CONTAINER_NAME}' not running"
fi

echo "Restore process finished successfully."
