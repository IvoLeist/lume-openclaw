#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/sandbox/.ssh /workspace /var/run/sshd
chown -R sandbox:sandbox /home/sandbox /workspace
chmod 700 /home/sandbox/.ssh

if [ -f /authorized_keys/authorized_keys ]; then
  cp /authorized_keys/authorized_keys /home/sandbox/.ssh/authorized_keys
  chown sandbox:sandbox /home/sandbox/.ssh/authorized_keys
  chmod 600 /home/sandbox/.ssh/authorized_keys
fi

# Generate host key if missing
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

exec /usr/sbin/sshd -D -e