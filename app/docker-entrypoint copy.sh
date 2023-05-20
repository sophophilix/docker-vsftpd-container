#!/bin/sh

set -euo pipefail

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $*" >&2
}


cat /etc/passwd

cat /etc/group


check_group_exists() {
    if getent group "${FTP_GROUP}" >/dev/null; then
        log "Group ${FTP_GROUP} already exists."
        return 0
    fi
    return 1
}


check_user_exists() {
    if getent passwd "${FTP_USER}" >/dev/null; then
        log "User ${FTP_USER} already exists."
        return 0
    fi
    return 1
}

create_group() {
    log "Adding group ${FTP_GROUP} with GID ${GID}"
    addgroup -g "${GID}" -S "${FTP_GROUP}" || { log "Failed to add group ${FTP_GROUP}"; exit 1; }
}

create_user() {
    log "Adding user ${FTP_USER} with UID ${UID} and home directory /home/${FTP_USER}"
    adduser -D -G "${FTP_GROUP}" -h "/home/${FTP_USER}" -s /bin/false -u "${UID}" "${FTP_USER}" || { log "Failed to add user ${FTP_USER}"; exit 1; }
}

set_ownership() {
    log "Setting ownership of home directory to ${FTP_USER}:${FTP_GROUP}"
    mkdir -p "/home/${FTP_USER}"
    chown -R "${FTP_USER}:${FTP_GROUP}" "/home/${FTP_USER}" || { log "Failed to set ownership of home directory to ${FTP_USER}:${FTP_GROUP}"; exit 1; }
}

set_password() {
    log "Setting password for user ${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASS}" | /usr/sbin/chpasswd || { log "Failed to set password for user ${FTP_USER}"; exit 1; }
}

create_log_files() {
    log "Creating log files"
    touch /var/log/vsftpd.log /var/log/xferlog || { log "Failed to create log files"; exit 1; }
}

start_log_tails() {
    log "Starting tail on log files"
    tail -f /var/log/vsftpd.log | tee /dev/stdout &
    tail -f /var/log/xferlog | tee /dev/stdout &
}

start_vsftpd() {
    log "Starting vsftpd"
    exec /usr/sbin/vsftpd "$@"
}

# Check if group exists
if check_group_exists; then
    log "Group ${FTP_GROUP} already exists. Skipping group creation."
else
    create_group
fi

# Check if user exists
if check_user_exists; then
    log "User ${FTP_USER} already exists. Skipping user creation."
else
    create_user
fi

# list_existing_users
# set_ownership
# set_password
create_log_files
start_log_tails
start_vsftpd
cat /etc/passwd
