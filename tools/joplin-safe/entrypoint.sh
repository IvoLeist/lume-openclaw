#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/toolrunner/.ssh /var/run/sshd /data
chown -R toolrunner:toolrunner /home/toolrunner /data
chmod 700 /home/toolrunner/.ssh

if [ -f /authorized_keys/authorized_keys ]; then
  cp /authorized_keys/authorized_keys /home/toolrunner/.ssh/authorized_keys
  chown toolrunner:toolrunner /home/toolrunner/.ssh/authorized_keys
  chmod 600 /home/toolrunner/.ssh/authorized_keys
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

exec /usr/sbin/sshd -D -e