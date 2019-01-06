FROM alpine:3.8

MAINTAINER iwostaq

WORKDIR /root

RUN apk upgrade --no-cache

COPY ./functions ./assets/
COPY ./postfix/assets/launch.sh ./assets/

RUN apk add --no-cache py2-pip &&\
    easy_install-2.7 supervisor
COPY ./postfix/assets/supervisord.conf /etc

RUN apk add --no-cache postfix rsyslog

COPY ./mailaccounts ./mailbond.conf ./assets/

ENTRYPOINT ["/bin/sh", "-c", "/bin/sh ./assets/launch.sh && /usr/bin/supervisord -n"]
