FROM python:3.10-slim

WORKDIR /app

COPY . ./

RUN apt-get update \
  && apt-get install \
    --no-install-recommends \
    -y \
    gcc=4:10.2.1-1 \
    python3-dev=3.9.2-3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && python -m pip install  \
    --no-cache-dir \
    --upgrade \
    -r requirements.txt

ENV PORT 8080
EXPOSE 8080

CMD [ "python", "src/main.py"]
