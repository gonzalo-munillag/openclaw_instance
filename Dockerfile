# --- Build stage ---
FROM node:22-bookworm AS builder

RUN corepack enable && \
    curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /build

RUN git clone --depth 1 https://github.com/openclaw/openclaw.git .

RUN pnpm install --frozen-lockfile
RUN pnpm build
RUN pnpm ui:install
RUN pnpm ui:build

# --- Production stage ---
FROM node:22-bookworm-slim

ARG OPENCLAW_DOCKER_APT_PACKAGES=""
RUN if [ -n "$OPENCLAW_DOCKER_APT_PACKAGES" ]; then \
      apt-get update && \
      apt-get install -y --no-install-recommends $OPENCLAW_DOCKER_APT_PACKAGES && \
      rm -rf /var/lib/apt/lists/*; \
    fi

RUN corepack enable

WORKDIR /app

COPY --from=builder /build/dist ./dist
COPY --from=builder /build/package.json ./package.json
COPY --from=builder /build/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /build/pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --from=builder /build/.npmrc ./.npmrc
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/ui ./ui
COPY --from=builder /build/scripts ./scripts
COPY --from=builder /build/skills ./skills
COPY --from=builder /build/extensions ./extensions
COPY --from=builder /build/packages ./packages

RUN mkdir -p /home/node/.openclaw/workspace && \
    chown -R node:node /home/node

USER node
ENV NODE_ENV=production
ENV HOME=/home/node

EXPOSE 18789 18790

CMD ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789"]
