#!/bin/bash

set -euo pipefail

NETWORK_NAME="joomla-net"
MYSQL_CONTAINER_NAME="joomla-mysql"
JOOMLA_CONTAINER_NAME="joomla-site"

MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_DATABASE="joomladb"
MYSQL_USER="joomlauser"
MYSQL_PASSWORD="joomlapw"
MYSQL_PORT="3306"

JOOMLA_PORT="8080"

MYSQL_IMAGE="mysql:latest"
JOOMLA_IMAGE="joomla:latest"

MYSQL_VOLUME="joomla_mysql_data"
JOOMLA_VOLUME="joomla_site_data"

echo "Starting Joomla and MySQL deployment"

if docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo "Docker network '${NETWORK_NAME}' already exists"
else
    echo "Creating Docker network '${NETWORK_NAME}'"
    docker network create "${NETWORK_NAME}"
    echo "Network '${NETWORK_NAME}' created"
fi

echo "Pull MySQL image (${MYSQL_IMAGE})…"
docker pull "${MYSQL_IMAGE}"
echo "Pull Joomla image (${JOOMLA_IMAGE})"
docker pull "${JOOMLA_IMAGE}"

if docker volume inspect "${JOOMLA_VOLUME}" >/dev/null 2>&1; then
    echo "Joomla data volume '${JOOMLA_VOLUME}' already exists"
else
    echo "Create Joomla data volume '${JOOMLA_VOLUME}'"
    docker volume create "${JOOMLA_VOLUME}"
fi

echo "Starting new MySQL container '${MYSQL_CONTAINER_NAME}'…"
docker run -d \
  --name "${MYSQL_CONTAINER_NAME}" \
  --network "${NETWORK_NAME}" \
  -p "${MYSQL_PORT}:3306" \
  -v "${MYSQL_VOLUME}:/var/lib/mysql" \
  -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" \
  -e MYSQL_DATABASE="${MYSQL_DATABASE}" \
  -e MYSQL_USER="${MYSQL_USER}" \
  -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" \
  "${MYSQL_IMAGE}"

echo "Waiting for MySQL"

until docker exec "${MYSQL_CONTAINER_NAME}" \
    mysqladmin ping -h127.0.0.1 -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; do
  sleep 5
done
echo "MySQL running."




echo "Starting new Joomla container '${JOOMLA_CONTAINER_NAME}'"
docker run -d \
  --name "${JOOMLA_CONTAINER_NAME}" \
  --network "${NETWORK_NAME}" \
  -p "${JOOMLA_PORT}:80" \
  -v "${JOOMLA_VOLUME}:/var/www/html" \
  -e JOOMLA_DB_HOST="${MYSQL_CONTAINER_NAME}" \
  -e JOOMLA_DB_TYPE="mysqli" \
  -e JOOMLA_DB_PORT="3306" \
  -e JOOMLA_DB_PREFIX="jos_" \
  -e JOOMLA_DB_USER="${MYSQL_USER}" \
  -e JOOMLA_DB_PASSWORD="${MYSQL_PASSWORD}" \
  -e JOOMLA_DB_NAME="${MYSQL_DATABASE}" \
  "${JOOMLA_IMAGE}"
  
echo "Joomla running"

echo "All the running containers are:"
docker ps -a

echo "Access Joomla site at: http://localhost:${JOOMLA_PORT}"
echo "Administrator interface at: http://localhost:${JOOMLA_PORT}/administrator"
