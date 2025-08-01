#!/bin/bash

NETWORK_NAME="joomla-net"
MYSQL_CONTAINER_NAME="joomla-mysql"
JOOMLA_CONTAINER_NAME="joomla-site"
MYSQL_VOLUME="joomla_mysql_data"
JOOMLA_VOLUME="joomla_site_data"

MYSQL_IMAGE="mysql:latest"
JOOMLA_IMAGE="joomla:latest"

echo "Starting cleanup process"

echo "Stopping and removing Joomla container '${JOOMLA_CONTAINER_NAME}'"
docker rm -f "${JOOMLA_CONTAINER_NAME}" 2>/dev/null || echo "Joomla container already stopped"
 

echo "Stopping and removing MySQL container '${MYSQL_CONTAINER_NAME}'"
docker rm -f "${MYSQL_CONTAINER_NAME}" 2>/dev/null || echo "MySQL container already stopped"


echo "Removing Joomla data volume '${JOOMLA_VOLUME}'"
docker volume rm "${JOOMLA_VOLUME}" 2>/dev/null || echo "Volume already removed"


echo "Removing Docker network '${NETWORK_NAME}'"
docker network rm "${NETWORK_NAME}" 2>/dev/null || echo "Network already removed"


echo "Removing Joomla image '${JOOMLA_IMAGE}'"
docker rmi "${JOOMLA_IMAGE}" 2>/dev/null || echo "Joomla image is already removed"
echo "Removing MySQL image '${MYSQL_IMAGE}'"
docker rmi "${MYSQL_IMAGE}" 2>/dev/null || echo "MySQL image is already removed"

read -p "Remove backups folder and the backup files in it? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo "Removing backup files"
    rm -rf ./backups
    echo "Backup files"
fi

echo "Cleanup completed. System restored to original state."

