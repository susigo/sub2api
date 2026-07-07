#!/usr/bin/env bash
# Build frontend on the host (uses swap on low-memory VPS; avoids OOM inside docker build).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo ">>> Building frontend in Node container (repo: ${REPO_ROOT})"

docker run --rm \
  -v "${REPO_ROOT}:/src" \
  -w /src/frontend \
  -e NODE_OPTIONS="--max-old-space-size=768" \
  node:24-alpine \
  sh -c "corepack enable && corepack prepare pnpm@9 --activate && pnpm install --frozen-lockfile && pnpm run build"

test -d "${REPO_ROOT}/backend/internal/web/dist" || {
  echo "ERROR: frontend build did not produce backend/internal/web/dist" >&2
  exit 1
}

echo ">>> Frontend build OK: ${REPO_ROOT}/backend/internal/web/dist"
