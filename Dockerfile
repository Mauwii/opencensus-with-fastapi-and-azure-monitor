FROM python:3.10

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN python -m venv .venv

ENV PATH /code/.venv/bin:${PATH}

RUN python -m pip install \
    --no-cache-dir \
    --upgrade pip \
  && python -m pip install  \
    --no-cache-dir \
    --upgrade \
    -r /code/requirements.txt

COPY ./src /code/src

ENV PORT 8080
EXPOSE 8080

ENTRYPOINT [ "python", "src/main.py"]
