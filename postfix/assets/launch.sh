#!/bin/sh

set -eu

DPATH_SELF=$( cd $(dirname "$0") && pwd )
. ${DPATH_SELF}/functions
. ${DPATH_SELF}/mailbond.conf

FPATH_VMBOX_MAPS=/etc/postfix/vmailbox
FPATH_MAILACCOUNT=${DPATH_SELF}/mailaccounts
USER_VMBOX=vmail
GROUP_VMBOX=postdrop

set_vmailbox_domain() {
  postconf virtual_mailbox_domains="$(postconf -h virtual_mailbox_domains), ${MAIL_DOMAIN}"
}

set_vmailbox_maps() {
  cat "${FPATH_MAILACCOUNT}" | sed -e '/^#\|^$/d' | while read acc pw; do
    echo -e "${acc}@${MAIL_DOMAIN}\t${MAIL_DOMAIN}/${acc}/"
  done > "${FPATH_VMBOX_MAPS}"

  postconf virtual_mailbox_maps="hash:${FPATH_VMBOX_MAPS}"
  postmap "${FPATH_VMBOX_MAPS}"

  postconf virtual_uid_maps="static:${ID_MAILBOX_USER}"
  postconf virtual_gid_maps="static:${ID_MAILBOX_GROUP}"
}

create_vmailboxes() {
  mkdir -p "${DPATH_MAILBOX}/${MAIL_DOMAIN}"
  chown ${USER_VMBOX}:${GROUP_VMBOX} "${DPATH_MAILBOX}/${MAIL_DOMAIN}"
  cat "${FPATH_MAILACCOUNT}" | sed -e '/^#\|^$/d' | while read acc pw; do
    mkdir -p "${DPATH_MAILBOX}/${MAIL_DOMAIN}/${acc}/"
    chown ${ID_MAILBOX_USER}:${ID_MAILBOX_GROUP} "${DPATH_MAILBOX}/${MAIL_DOMAIN}/${acc}"
  done

  postconf virtual_mailbox_base="${DPATH_MAILBOX}" 
}

change_owner_of_spool() {
  chown root:root /var/spool/postfix
  chown root:root /var/spool/postfix/pid
}

main() {
  echo "MAIL_DOMAIN
        DPATH_MAILBOX
        ID_MAILBOX_USER
        ID_MAILBOX_GROUP" | check_envvars
  set_vmailbox_domain
  set_vmailbox_maps
  create_vmailboxes
  change_owner_of_spool
}

main
