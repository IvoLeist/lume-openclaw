FROM python:3.12-slim

WORKDIR /app

# System packages needed for SSH server and shell wrapper
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    bash \
 && rm -rf /var/lib/apt/lists/*

# Python deps
RUN pip install --no-cache-dir requests typer

# Create runtime user for restricted SSH login
RUN useradd -m -s /bin/bash toolrunner

# Copy application files
COPY joplin_api_wrapper.py /app/joplin_api_wrapper.py
COPY ssh-in/joplin-dispatch /app/joplin-dispatch
COPY entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /app/joplin_api_wrapper.py /app/joplin-dispatch /entrypoint.sh

# Optional: create directories now
RUN mkdir -p /var/run/sshd /data \
 && chown -R toolrunner:toolrunner /data /home/toolrunner

EXPOSE 22

# not yet working
# runs into Permission denied (publickey)

# Harden sshd a bit (see sandbox/dockerfile for reference)
# RUN printf '%s\n' \
#   'Port 22' \
#   'Protocol 2' \
#   'HostKey /etc/ssh/ssh_host_ed25519_key' \
#   'UsePAM no' \
#   'PasswordAuthentication no' \
#   'KbdInteractiveAuthentication no' \
#   'ChallengeResponseAuthentication no' \
#   'PermitRootLogin no' \
#   'PubkeyAuthentication yes' \
#   'AuthorizedKeysFile .ssh/authorized_keys' \
#   'AllowUsers toolrunner' \
#   'X11Forwarding no' \
#   'AllowAgentForwarding no' \
#   'AllowTcpForwarding no' \
#   'PermitTunnel no' \
#   'PrintMotd no' \
#   'Subsystem sftp internal-sftp' \
#   > /etc/ssh/sshd_config

ENTRYPOINT ["/entrypoint.sh"]