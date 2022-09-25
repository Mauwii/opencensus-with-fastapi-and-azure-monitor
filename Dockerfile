# ----- Build Stage -----
FROM python:3.10 AS builder

ARG APP_PATH="/app"
WORKDIR ${APP_PATH}
ENV PATH ${APP_PATH}/.venv/bin:${PATH}

COPY requirements.txt /tmp
COPY src ./

RUN python -m venv .venv \
  && python -m pip install \
    --require-virtualenv \
    --no-cache-dir \
    --upgrade \
      pip \
      setuptools \
      wheel \
  && python -m pip install \
    --require-virtualenv \
    --no-cache-dir \
    -r /tmp/requirements.txt

# ---- Main Stage ----
FROM python:3.10-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# set Workdir
ARG APP_PATH=/app
WORKDIR ${APP_PATH}

# install SSH
ENV SSH_PASSWD "root:Docker!"
COPY docker/ssh_setup /tmp
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    dialog \
    openssh-server \
  && echo ${SSH_PASSWD} | chpasswd \
  && (sleep 1;/tmp/ssh_setup 2>&1 > /dev/null) \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY docker/sshd_config /etc/ssh/
COPY docker/entrypoint.sh /usr/local/bin/

COPY --from=builder ${APP_PATH} ${APP_PATH}
ENV PATH ${APP_PATH}/.venv/bin:${PATH}
ARG PORT=8080
EXPOSE ${PORT} 2222

# CMD [ "gunicorn", "main:app"]
ENTRYPOINT [ "entrypoint.sh" ]
