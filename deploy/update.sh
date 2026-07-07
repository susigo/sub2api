#!/usr/bin/env bash
# =============================================================================
# Sub2API 源码部署更新脚本（在 VPS 的仓库根目录或 deploy/ 下执行）
# =============================================================================
# 首次部署:
#   git clone https://github.com/susigo/sub2api.git /opt/sub2api-app
#   cd /opt/sub2api-app/deploy
#   cp .env.example .env   # 或从旧部署复制 .env
#   # 编辑 .env 后:
#   ./update.sh
#
# 日常更新:
#   cd /opt/sub2api-app/deploy && ./update.sh
#   ./update.sh --no-pull   # 仅重建镜像（不 git pull）
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILES=(-f docker-compose.local.yml -f docker-compose.build.yml)
DO_PULL=1

for arg in "$@"; do
  case "$arg" in
    --no-pull) DO_PULL=0 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

cd "${SCRIPT_DIR}"

if [[ ! -f .env ]]; then
  echo "[ERROR] .env not found in ${SCRIPT_DIR}" >&2
  echo "Copy .env.example to .env and configure secrets first." >&2
  exit 1
fi

mkdir -p data postgres_data redis_data

if [[ "${DO_PULL}" -eq 1 ]]; then
  echo ">>> git pull (${REPO_ROOT})"
  git -C "${REPO_ROOT}" pull --ff-only
fi

echo ">>> build frontend (host)"
"${SCRIPT_DIR}/build-frontend.sh"

echo ">>> docker compose build sub2api"
docker compose "${COMPOSE_FILES[@]}" build sub2api

echo ">>> docker compose up -d"
docker compose "${COMPOSE_FILES[@]}" up -d

echo ">>> waiting for health"
for i in $(seq 1 30); do
  if curl -sf http://127.0.0.1:8080/health >/dev/null 2>&1; then
    echo ">>> healthy"
    docker compose "${COMPOSE_FILES[@]}" ps
    exit 0
  fi
  sleep 2
done

echo "[WARN] health check timeout; recent logs:" >&2
docker compose "${COMPOSE_FILES[@]}" logs --tail=40 sub2api
exit 1
