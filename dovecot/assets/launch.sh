#!/bin/sh

set -eu

DPATH_SELF=$( cd $(dirname "$0") && pwd )
. ${DPATH_SELF}/functions
. ${DPATH_SELF}/mailbond.conf

DPATH_DOVECOT_CONFIG=/etc/dovecot
FPATH_PASSWORDS=${DPATH_DOVECOT_CONFIG}/passwd_${MAIL_DOMAIN}
FPATH_MAILACCOUNT=${DPATH_SELF}/mailaccounts
ALG_USERPW=CRAM-MD5

set_dovecot_configs() {
  # /etc/dovecot/dovecot.conf
  echo "protocols = imap pop3" >> ${DPATH_DOVECOT_CONFIG}/dovecot.conf
  echo "log_path = /var/log/dovecot.log" >> ${DPATH_DOVECOT_CONFIG}/dovecot.conf
  echo "listen = *" >> ${DPATH_DOVECOT_CONFIG}/dovecot.conf

  # conf.d/10-mail.conf
  echo "mail_location = maildir:${DPATH_MAILBOX}/%d/%u" \
    >> ${DPATH_DOVECOT_CONFIG}/conf.d/10-mail.conf

  # conf.d/10-auth.conf
  echo "disable_plaintext_auth = no" >> ${DPATH_DOVECOT_CONFIG}/conf.d/10-auth.conf
  echo "auth_mechanisms = cram-md5 plain" >> ${DPATH_DOVECOT_CONFIG}/conf.d/10-auth.conf

  # conf.d/auth-passwdfile.conf.ext
  replace_envvars ${DPATH_SELF}/auth-passwdfile.conf \
    > ${DPATH_DOVECOT_CONFIG}/conf.d/auth-passwdfile.conf.ext
}

set_dovecot_users() {
  cat "${FPATH_MAILACCOUNT}" | sed -e '/^#\|^$/d' | while read acc pw; do
    printf "%s:%s:%d:%d:::::Maildir:%s\n" \
      ${acc} $(doveadm pw -s ${ALG_USERPW} -p ${pw:-passwd})\
      ${ID_MAILBOX_USER} ${ID_MAILBOX_GROUP} \
      "${DPATH_MAILBOX}/${MAIL_DOMAIN}/${acc}"
  done > ${FPATH_PASSWORDS}

  chown root:root ${FPATH_PASSWORDS}
}

main() {
  echo "MAIL_DOMAIN
        DPATH_MAILBOX
        ID_MAILBOX_USER
        ID_MAILBOX_GROUP" | check_envvars
  set_dovecot_configs
  set_dovecot_users
}

main
