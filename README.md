# OpenClaw Instance

Personal [OpenClaw](https://openclaw.ai/) deployment running on a Raspberry Pi 5 via Docker.

OpenClaw is an open-source personal AI assistant that runs on your own devices, connecting to messaging channels (WhatsApp, Telegram, Slack, Discord, etc.) and powered by LLMs like Anthropic Claude.

## Prerequisites

- Raspberry Pi 5 (8GB RAM) with Raspberry Pi OS 64-bit
- Docker + Docker Compose v2 installed on the Pi
- An Anthropic API key or Claude Pro/Max subscription
- A DockerHub account (to push/pull the image)

## Quick Start

### 1. Build and push the image (from your dev machine)

```bash
# Build for ARM64 (Raspberry Pi) and push to DockerHub
docker buildx create --use
docker buildx build --platform linux/arm64 \
  -t YOUR_DOCKERHUB_USER/openclaw:latest \
  --push .
```

### 2. Deploy on the Raspberry Pi

```bash
# Clone this repo on the Pi
git clone https://github.com/gonzalo-munillag/openclaw_instance.git
cd openclaw_instance

# Create your .env from the template
cp .env.example .env
# Edit .env: set OPENCLAW_IMAGE, OPENCLAW_GATEWAY_TOKEN, etc.

# Create host directories for persistent state
mkdir -p ~/.openclaw/workspace

# Pull the image and run onboarding
docker compose pull openclaw-gateway
docker compose run --rm openclaw-cli onboard --no-install-daemon

# Start the gateway
docker compose up -d openclaw-gateway
```

### 3. Access the Control UI

Open `http://<PI_IP>:18789/` in your browser.

## Configuration

Copy `.env.example` to `.env` and fill in the values. See the file for all available options.

## Adding Channels

```bash
# Telegram
docker compose run --rm openclaw-cli channels add --channel telegram --token "<BOT_TOKEN>"

# Discord
docker compose run --rm openclaw-cli channels add --channel discord --token "<BOT_TOKEN>"

# WhatsApp (QR code pairing)
docker compose run --rm openclaw-cli channels login
```

## Resources

- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [OpenClaw Docs](https://docs.openclaw.ai)
- [Raspberry Pi Guide (Adafruit)](https://learn.adafruit.com/openclaw-on-raspberry-pi/overview)
