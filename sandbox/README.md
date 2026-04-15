# Architecture
[Lume macOS VM]
  OpenClaw gateway
      |
      | SSH
      v
[Mac host :2222]  -> forwarded into container
      |
      v
[Linux container with sshd + tools + persistent workspace]

# Build the Sandbox
docker build -t openclaw-ssh-sandbox .

# Try to ssh from the Lume MacOS VM into the sandbox
ssh -i ~/.ssh/openclaw_sandbox -p 2222 sandbox@<HOST_IP>

