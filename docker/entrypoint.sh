#!/usr/bin/env bash
set -e

echo "----------------------------------------------------------"
echo -e "|\e[1;33m THIS CONTAINER IS INTENDED TO BE USED IN AZURE WEBAPPS \e[0m|"
echo "----------------------------------------------------------"

# start ssh
service ssh start

# persistent logs
PERSISTENT_LOGS_DIR="${WEBAPP_STORAGE_HOME:-/var/log}"
PERSISTENT_LOGS="${PERSISTENT_LOGS_DIR}/gunicorn"
mkdir -p "${PERSISTENT_LOGS_DIR}"
touch "${PERSISTENT_LOGS}.log"
touch "${PERSISTENT_LOGS}-access.log"
touch "${PERSISTENT_LOGS}-error.log"
tail -n 0 -f "${PERSISTENT_LOGS}"*.log &

# start fastapi
gunicorn 'main:app' \
  --bind "0.0.0.0:${WEBSITES_PORT:-8080}" \
  --forwarded-allow-ips "${HOSTNAME:-127.0.0.1}" \
  --worker-class uvicorn.workers.UvicornWorker \
  --workers "${GUNICORN_WORKERS:-2}" \
  --timeout "${GUNICORN_TIMEOUT:-300}" \
  --log-level "${GUNICORN_LOGLEVEL:-info}" \
  --log-file "${PERSISTENT_LOGS}.log" \
  --access-logfile "${PERSISTENT_LOGS}-access.log" \
  --error-logfile "${PERSISTENT_LOGS}-error.log"
