FROM alpine:3.8

MAINTAINER iwostaq

WORKDIR /root

RUN apk upgrade --no-cache

COPY ./functions ./assets/
COPY ./dovecot/assets/launch.sh ./assets/
COPY ./dovecot/assets/auth-passwdfile.conf ./assets/

RUN apk add --no-cache dovecot

COPY ./mailaccounts ./mailbond.conf ./assets/

ENTRYPOINT ["/bin/sh", "-c", "/bin/sh ./assets/launch.sh && /usr/sbin/dovecot -F"]
