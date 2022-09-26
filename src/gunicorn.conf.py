import multiprocessing
import os

name = "Gunicorn config for FastAPI"

# accesslog = "./gunicorn-access.log"
# errorlog = "./gunicorn-error.log"

APPINSIGHTS_CONNECTIONSTRING = os.environ['APPINSIGHTS_CONNECTIONSTRING']
APPINSIGHTS_INSTRUMENTATIONKEY = os.environ['APPINSIGHTS_INSTRUMENTATIONKEY']
PORT = os.environ['WEBSITES_PORT']
# WEBSITE_HOSTNAME = os.environ['WEBSITE_HOSTNAME']
FORWARDED_ALLOW_IPS = os.getenv('WEBSITE_PRIVATE_IP', '127.0.0.1')
bind = str(f'0.0.0.0:{PORT}')
# forwarded_allow_ips = WEBSITE_HOSTNAME
timeout = 600
worker_class = "uvicorn.workers.UvicornWorker"
workers = multiprocessing.cpu_count() * 2 + 1
