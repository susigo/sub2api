#!/usr/bin/env bash
# Pull latest image from GHCR and restart (recommended for low-memory VPS).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILES=(-f docker-compose.local.yml -f docker-compose.ghcr.yml)

cd "${SCRIPT_DIR}"

if [[ ! -f .env ]]; then
  echo "[ERROR] .env not found in ${SCRIPT_DIR}" >&2
  exit 1
fi

mkdir -p data postgres_data redis_data

echo ">>> docker compose pull sub2api"
docker compose "${COMPOSE_FILES[@]}" pull sub2api

echo ">>> docker compose up -d"
docker compose "${COMPOSE_FILES[@]}" up -d

echo ">>> waiting for health"
for _ in $(seq 1 30); do
  if curl -sf http://127.0.0.1:8080/health >/dev/null 2>&1; then
    echo ">>> healthy"
    docker compose "${COMPOSE_FILES[@]}" ps
    exit 0
  fi
  sleep 2
done

echo "[WARN] health check timeout" >&2
docker compose "${COMPOSE_FILES[@]}" logs --tail=40 sub2api
exit 1
