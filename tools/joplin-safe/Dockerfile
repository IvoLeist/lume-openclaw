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
COPY ssh-in/joplin-dispatch /usr/local/bin/joplin-dispatch
COPY entrypoint.sh /entrypoint.sh

# Make scripts executable
RUN chmod +x /app/joplin_api_wrapper.py /entrypoint.sh /usr/local/bin/joplin-dispatch

# Optional: create directories now
RUN mkdir -p /var/run/sshd /data \
 && chown -R toolrunner:toolrunner /data /home/toolrunner

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]