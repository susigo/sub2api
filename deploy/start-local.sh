#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
DATA_DIR="${ROOT_DIR}/data"
LOG_DIR="${ROOT_DIR}/logs"
BINARY="${ROOT_DIR}/sub2api"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy .env.example and configure it first." >&2
  exit 1
fi

if [[ ! -x "${BINARY}" ]]; then
  echo "Missing ${BINARY}. Build the server before starting." >&2
  exit 1
fi

mkdir -p "${DATA_DIR}" "${LOG_DIR}"

if command -v pg_ctlcluster >/dev/null 2>&1; then
  PG_VERSION="$(ls /etc/postgresql 2>/dev/null | head -n1 || true)"
  if [[ -n "${PG_VERSION}" ]]; then
    sudo pg_ctlcluster "${PG_VERSION}" main start >/dev/null 2>&1 || true
  fi
fi

if ! redis-cli ping >/dev/null 2>&1; then
  if command -v redis-server >/dev/null 2>&1; then
    redis-server --daemonize yes >/dev/null 2>&1 || sudo redis-server --daemonize yes >/dev/null 2>&1 || true
  fi
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a
export DATA_DIR

exec "${BINARY}" >>"${LOG_DIR}/sub2api.log" 2>&1
