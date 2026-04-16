#!/usr/bin/env bash
set -euo pipefail

mkdir -p /home/sandbox/.ssh /workspace /var/run/sshd
chown -R sandbox:sandbox /home/sandbox /workspace
chmod 700 /home/sandbox/.ssh

# Incoming SSH keys
cp /authorized_keys/authorized_keys /home/sandbox/.ssh/authorized_keys
chown sandbox:sandbox /home/sandbox/.ssh/authorized_keys
chmod 600 /home/sandbox/.ssh/authorized_keys

# Outgoing SSH key/config
cp /ssh-out/id_ed25519_into_joplin_container /home/sandbox/.ssh/id_ed25519_into_joplin_container
chown sandbox:sandbox /home/sandbox/.ssh/id_ed25519_into_joplin_container
chmod 600 /home/sandbox/.ssh/id_ed25519_into_joplin_container

cp /ssh-out/config /home/sandbox/.ssh/config
chown sandbox:sandbox /home/sandbox/.ssh/config
chmod 600 /home/sandbox/.ssh/config

# cp /joplin-safe /usr/bin/joplin-safe
# chmod +x /usr/bin/joplin-safe

cp /joplin-safe /opt/tools/joplin-safe/joplin-safe
chmod +x /opt/tools/joplin-safe/joplin-safe

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

exec /usr/sbin/sshd -D -e