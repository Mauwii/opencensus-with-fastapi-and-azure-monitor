#!/usr/bin/env bash
set -e

echo "--------------------------------------------------------"
echo -e "\e[1;33m THIS CONTAINER IS INTENDED TO BE USED IN AZURE WEBAPPS\e[0m"
echo "--------------------------------------------------------"

echo "Starting SSH ..."
service ssh start

# persistent logs
PERSISTENT_LOGS_DIR="${WEBAPP_STORAGE_HOME:-/home/LogFiles}"
PERSISTENT_LOGS="${PERSISTENT_LOGS_DIR}/gunicorn"
mkdir -p "${PERSISTENT_LOGS_DIR}"
touch "${PERSISTENT_LOGS}.log"
touch "${PERSISTENT_LOGS}-access.log"
touch "${PERSISTENT_LOGS}-error.log"
tail -n 0 -f "${PERSISTENT_LOGS}"*.log &

# [[ "$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')" -gt 12 ]] && workers=12
echo "Starting fastapi ..."
gunicorn \
  --bind "0.0.0.0:${WEBSITES_PORT:-8080}" \
  --name "${WEBSITE_SITE_NAME:-fastapi-opencensus}" \
  --forwarded-allow-ips "${WEBSITE_HOSTNAME:-${HOSTNAME:-127.0.0.1}}" \
  --worker-class uvicorn.workers.UvicornWorker \
  --workers 2 \
  --log-level "${LOGLEVEL:-info}" \
  --log-file "${PERSISTENT_LOGS}.log" \
  --access-logfile "${PERSISTENT_LOGS}-access.log" \
  --error-logfile "${PERSISTENT_LOGS}-error.log" \
  --timeout 240 \
  'main:app'
#  --workers ${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')} \

# uvicorn main:app \
#   --port "${WEBSITES_PORT:-8080}" \
#   --host="0.0.0.0" \
#   --log-level="info" \
#   --proxy-headers \
#   --forwarded-allow-ips "${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
#   --workers="${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')}"
