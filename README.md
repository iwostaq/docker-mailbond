# mailbond

The mailbond is a Docker stack providing basic mail functions to receive, read, write and send mails.

It consists of:
- Postfix
- Dovecot
- Roundcubemail

As of now, only the Postfix is ready and others are still in the backlog.

## Installation

After cloning this repository, do `docker-compose up` command like below:

```
$ sudo docker-compose up -d
```

