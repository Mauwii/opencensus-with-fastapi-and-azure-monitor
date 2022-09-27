#!/usr/bin/env bash
set -e

echo "--------------------------------------------------------"
echo -e "\e[1;33m THIS CONTAINER IS INTENDED TO BE USED IN AZURE WEBAPPS\e[0m"
echo "--------------------------------------------------------"

echo "Starting SSH ..."
service ssh start

# persistent logs
PERSIST_LOGS_DIR=/home/LogFiles
PERSIST_LOGS=${PERSIST_LOGS_DIR}/gunicorn
mkdir -p ${PERSIST_LOGS_DIR}
touch ${PERSIST_LOGS}.log
touch ${PERSIST_LOGS}-access.log
touch ${PERSIST_LOGS}-error.log
tail -n 0 -f ${PERSIST_LOGS}*.log &

# [[ "$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')" -gt 12 ]] && workers=12
echo "Starting fastapi ..."
gunicorn \
  --proxy-protocol \
  --bind "0.0.0.0:${WEBSITES_PORT:-8080}" \
  --name "${WEBSITE_SITE_NAME:-fastapi-opencensus}" \
  --forwarded-allow-ips "${WEBSITE_SITE_NAME:-${HOSTNAME:-127.0.0.1}}" \
  --worker-class uvicorn.workers.UvicornWorker \
  --workers 4 \
  --log-level "${LOGLEVEL:-info}" \
  --log-file "${PERSIST_LOGS}.log" \
  --access-logfile "${PERSIST_LOGS}-access.log" \
  --error-logfile "${PERSIST_LOGS}-error.log" \
  --timeout 600 \
  --chdir /app \
  'main:app'
  # --forwarded-allow-ips "${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
  # --forwarded-allow-ips="${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
#  --workers ${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')} \

# uvicorn main:app \
#   --port "${WEBSITES_PORT:-8080}" \
#   --host="0.0.0.0" \
#   --log-level="info" \
#   --proxy-headers \
#   --forwarded-allow-ips "${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
#   --workers="${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')}"
