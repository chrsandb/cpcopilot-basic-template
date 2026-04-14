#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=./lib/url_helpers.sh
source "${SCRIPT_DIR}/lib/url_helpers.sh"

USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
PID_FILE="${STATE_DIR}/opencode-web.pid"
LOG_FILE="${STATE_DIR}/opencode-web.log"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"

export PATH="${HOME}/.local/npm-global/bin:${PATH}"
export BROWSER="/bin/true"

PREFERRED_URL="$(service_url_for_port "${OPENCODE_PORT}")"
LOCAL_URL="http://localhost:${OPENCODE_PORT}"

if ! command -v opencode >/dev/null 2>&1; then
  echo "[opencode] binary not found. Run scripts/setup-opencode.sh first."
  exit 1
fi

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "[opencode] already running on port ${OPENCODE_PORT}."
  exit 0
fi

rm -f "${STATE_DIR}/opencode-intro-seeded" "${STATE_DIR}/opencode-intro-session.json"

cd "${REPO_ROOT}"
nohup env -C "${REPO_ROOT}" opencode web --hostname 0.0.0.0 --port "${OPENCODE_PORT}" </dev/null >"${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

echo "[opencode] web mode started on 0.0.0.0:${OPENCODE_PORT}."
echo "[opencode] preferred URL: ${PREFERRED_URL}"
if [[ "${PREFERRED_URL}" != "${LOCAL_URL}" ]]; then
  echo "[opencode] local URL    : ${LOCAL_URL}"
fi
echo "[opencode] log file : ${LOG_FILE}"
