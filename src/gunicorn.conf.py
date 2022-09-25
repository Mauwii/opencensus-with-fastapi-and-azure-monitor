import multiprocessing
import os

name = "Gunicorn config for FastAPI"

# accesslog = "./gunicorn-access.log"
# errorlog = "./gunicorn-error.log"

APPINSIGHTS_CONNECTION_STRING = os.environ['APPINSIGHTS_CONNECTION_STRING']
PORT = os.environ['SERVER_PORT']
WEBSITE_HOSTNAME = os.environ['WEBSITE_HOSTNAME']

bind = str(f'{WEBSITE_HOSTNAME}:{PORT}')
# forwarded_allow_ips = WEBSITE_HOSTNAME
timeout = 600
worker_class = "uvicorn.workers.UvicornWorker"
workers = multiprocessing.cpu_count() * 2 + 1
