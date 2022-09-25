FROM python:3.10 AS builder

ARG APP_PATH=/app
WORKDIR ${APP_PATH}
ENV PATH ${APP_PATH}/.venv/bin:$PATH

COPY requirements.txt /tmp
COPY src ./

RUN python -m venv .venv \
  && python -m pip install \
    # --require-virtualenv \
    # --no-cache-dir \
    --upgrade \
      pip \
      setuptools \
      wheel \
  && python -m pip install \
    # --require-virtualenv \
    # --no-cache-dir \
    -r /tmp/requirements.txt

FROM python:3.10-slim

ARG APP_PATH=/app
ARG PORT=8080
WORKDIR ${APP_PATH}

COPY --from=builder ${APP_PATH} ${APP_PATH}

ENV PATH ${APP_PATH}/.venv/bin:$PATH

EXPOSE ${PORT}

CMD [ "gunicorn", "main:app"]
