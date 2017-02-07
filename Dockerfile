FROM alpine:3.5

RUN mkdir /app
COPY . /app
WORKDIR /app
RUN apk add --update \
    build-base \
    postgresql \
    postgresql-dev \
    libpq \
    libevent-dev \
    bsd-compat-headers \
    python \
    python-dev \
    py-pip \
 && pip install -r requirements.txt \
 && adduser -D -h /home/app -s /bin/sh app \
 && chown app:app /app \
 && rm -rf /var/cache/apk/*

USER app
WORKDIR /app
CMD ["sh"]
