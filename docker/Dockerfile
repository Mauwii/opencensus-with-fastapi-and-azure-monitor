# -----------
# Build Stage
# -----------
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION} AS builder

ARG APP_PATH=/usr/src/app
WORKDIR ${APP_PATH}
ENV PATH ${APP_PATH}/.venv/bin:${PATH}

COPY requirements.txt /tmp
COPY src ./

RUN python -m venv .venv \
  && python -m pip install \
    --require-virtualenv \
    --no-cache-dir \
    -r /tmp/requirements.txt

# ----------
# Main Stage
# ----------
FROM python:${PYTHON_VERSION}-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# set Workdir
ARG APP_PATH=/usr/src/app
WORKDIR ${APP_PATH}

# install SSH
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssh-server \
  && echo "root:Docker!" | chpasswd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY docker/sshd_config /etc/ssh/

# copy app from builder
COPY --from=builder ${APP_PATH} ${APP_PATH}
ENV PATH ${APP_PATH}/.venv/bin:${PATH}

# expose ports
ARG PORT=8080
EXPOSE ${PORT} 2222

# set entrypoint
COPY docker/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
