#!/bin/bash
docker buildx build --platform linux/arm64,linux/amd64 -t docker.io/gonzalomg0/openclaw:latest --push .
