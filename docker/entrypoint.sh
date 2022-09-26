#!/usr/bin/env bash
set -e

echo "--------------------------------------------------------------"
echo -e "\e[1;33m THIS CONTAINER IS ONLY INTENDED TO BE USED IN A AZURE WEBAPP\e[0m"
echo "--------------------------------------------------------------"

echo "Starting SSH ..."
service ssh start

echo "Starting fastapi ..."
# python main.py
uvicorn main:app \
  --port "${WEBSITES_PORT:-8080}" \
  --host="0.0.0.0" \
  --log-level="info" \
  --workers="${workers:-$(python -c 'import multiprocessing; print(multiprocessing.cpu_count())')}"
