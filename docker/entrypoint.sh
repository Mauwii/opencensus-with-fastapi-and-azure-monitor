#!/usr/bin/env bash
set -e

echo "--------------------------------------------------------------"
echo -e "\e[1;33m THIS CONTAINER IS ONLY INTENDED TO BE USED IN A AZURE WEBAPP\e[0m"
echo "--------------------------------------------------------------"

echo "Starting SSH ..."
service ssh start

echo "Starting fastapi ..."
[[ "$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')" -gt 12 ]] && workers=12
gunicorn \
  --worker-class uvicorn.workers.UvicornH11Worker \
  --workers "${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')}" \
  --access-logfile '-' \
  --error-logfile '-' \
  --bind="0.0.0.0:${WEBSITES_PORT:-8080}" \
  --forwarded-allow-ips "${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
  --timeout=600 \
  'main:app'
#  --workers ${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')} \

# uvicorn main:app \
#   --port "${WEBSITES_PORT:-8080}" \
#   --host="0.0.0.0" \
#   --log-level="info" \
#   --proxy-headers \
#   --forwarded-allow-ips "${WEBSITE_PRIVATE_IP:-127.0.0.1}" \
#   --workers="${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count() * 2 + 1)')}"
