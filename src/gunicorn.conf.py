import multiprocessing
import os

name = "Gunicorn config for FastAPI"

# accesslog = "./gunicorn-access.log"
# errorlog = "./gunicorn-error.log"

bind = str("0.0.0.0:" + os.getenv('PORT'))
timeout = 600
worker_class = "uvicorn.workers.UvicornWorker"
workers = multiprocessing.cpu_count() * 2 + 1
