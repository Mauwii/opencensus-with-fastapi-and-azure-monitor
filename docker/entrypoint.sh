#!/bin/bash
set -e

echo "--------------------------------------------------------------"
echo -e "\e[1;33m THIS CONTAINER IS ONLY INTENDED TO BE USED IN A AZURE WEBAPP\e[0m"
echo "--------------------------------------------------------------"

echo "Starting SSH ..."
service ssh start

echo "Starting fastapi ..."
gunicorn main:app
