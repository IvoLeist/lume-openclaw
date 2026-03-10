# Port Forwarding and Webhooks for OpenClaw in the Lume VM

When OpenClaw runs inside a Lume VM, the gateway listens inside the VM (default port **18789** for WebSocket, and HTTP for webhooks). For Telegram, WhatsApp, or other channels that use **webhooks**, the external service must be able to reach that gateway. The VM typically has a private IP (e.g. `192.168.64.x`) and is not directly reachable from the internet.

This doc describes how to expose the VM’s gateway so webhooks work.

## Option 1: SSH local port forward (host as relay)

Forward a port on the **host** to the gateway port inside the VM. Then point your channel webhook at the host (and ensure the host is reachable from the internet if needed, e.g. via ngrok on the host).

1. **Get the VM IP** (with the VM running):

   ```bash
   lume get openclaw
   ```

2. **Create an SSH tunnel** (on the host), e.g. forward host port `18789` to VM port `18789`:

   ```bash
   ssh -N -L 18789:127.0.0.1:18789 VM_USER@<VM_IP>
   ```

   Replace `VM_USER` and `<VM_IP>` with your VM user and IP. Leave this running while you need webhooks.

3. **Point channel webhooks at the host:**  
   If your bot config expects the gateway at `https://your-host:18789/...`, configure your router or firewall so the host’s port 18789 is reachable, or run **ngrok** (or similar) on the host against port 18789 and use the ngrok URL for webhooks.

## Option 2: Ngrok (or similar) on the host with SSH forward

1. Start the VM and OpenClaw gateway inside the VM.
2. On the host, create the SSH tunnel so the gateway is on localhost:

   ```bash
   ssh -N -L 18789:127.0.0.1:18789 VM_USER@<VM_IP>
   ```

3. On the host, run ngrok (or another tunnel) against the forwarded port:

   ```bash
   ngrok http 18789
   ```

4. Use the ngrok public URL (e.g. `https://abc123.ngrok.io`) as the webhook base URL in your channel configuration (Telegram, WhatsApp, etc.), with the path your gateway expects (e.g. `/telegram-webhook`).

## Option 3: Ngrok inside the VM (advanced)

You can run ngrok (or another tunnel) **inside** the VM and point it at `127.0.0.1:18789`. Then use the ngrok public URL for webhooks. This avoids SSH forwarding but requires installing and configuring ngrok in the VM and keeping it running.

## Security notes

- Exposing the gateway to the internet increases attack surface. Use authentication, HTTPS, and allowlists where possible (see [OpenClaw gateway security](https://docs.clawd.bot/gateway/security)).
- Prefer VPN or Tailscale if you need remote access without exposing the gateway publicly.

## References

- [OpenClaw Gateway](https://docs.clawd.bot/gateway) (ports, configuration)
- [OpenClaw channels](https://docs.clawd.bot/channels) (webhook setup per channel)
