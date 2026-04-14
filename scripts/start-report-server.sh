#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
PID_FILE="${STATE_DIR}/report-server.pid"
LOG_FILE="${STATE_DIR}/report-server.log"

mkdir -p "${STATE_DIR}" "${REPO_ROOT}/reports"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

REPORTS_PORT="${REPORTS_PORT:-8081}"

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "[reports] server already running on port ${REPORTS_PORT}."
  exit 0
fi

cd "${REPO_ROOT}"
nohup python3 "${REPO_ROOT}/scripts/report_server.py" >"${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

echo "[reports] server started on 0.0.0.0:${REPORTS_PORT}."
echo "[reports] local URL: http://localhost:${REPORTS_PORT}"
