#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
STATUS_FILE="${HOME}/.config/opencode/checkpoint-setup-status.json"
USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
PROMPT_SENTINEL="/tmp/checkpoint-copilot-setup-prompted-${USER}"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"
SETUP_COMPLETE="false"

if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

bash "${REPO_ROOT}/scripts/start-opencode-web.sh" >/dev/null 2>&1 || true
bash "${REPO_ROOT}/scripts/start-report-server.sh" >/dev/null 2>&1 || true

echo ""
echo "🚀 Check Point CoPilot terminal ready"
echo "- Instructions   : ${REPO_ROOT}/INSTRUCTIONS.md"
echo "- OpenCode UI    : http://localhost:${OPENCODE_PORT}"
echo "- Reports        : http://localhost:${REPORTS_PORT}"

if [[ "${SETUP_COMPLETE}" == "true" ]]; then
  echo "- Setup status   : complete"
  exit 0
fi

echo "- Setup status   : pending"
echo "- Guided setup   : bash scripts/first-run-checkpoint-setup.sh"

echo ""
echo "Missing mandatory values can be provided from Codespaces secrets or directly in the guided terminal setup."

if [[ -t 0 && -t 1 && ! -f "${PROMPT_SENTINEL}" ]]; then
  touch "${PROMPT_SENTINEL}"
  echo ""
  echo "[welcome] Starting guided first-run setup now..."
  bash "${REPO_ROOT}/scripts/first-run-checkpoint-setup.sh" || true
fi
