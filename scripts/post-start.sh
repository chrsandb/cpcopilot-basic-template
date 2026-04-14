#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATUS_FILE="${HOME}/.config/opencode/checkpoint-setup-status.json"

bash "${REPO_ROOT}/scripts/first-run-checkpoint-setup.sh" || true
bash "${REPO_ROOT}/scripts/start-opencode-web.sh" || true
bash "${REPO_ROOT}/scripts/start-report-server.sh" || true
bash "${REPO_ROOT}/scripts/validate-environment.sh" --quick || true

SETUP_COMPLETE="false"
if [[ -f "${STATUS_FILE}" ]] && command -v jq >/dev/null 2>&1; then
  SETUP_COMPLETE="$(jq -r '.setupComplete // false' "${STATUS_FILE}")"
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"

echo ""
echo "🚀 Check Point OpenCode Codespace is up"
echo "- Instructions    : ${REPO_ROOT}/INSTRUCTIONS.md"
echo "- OpenCode Web UI: http://localhost:${OPENCODE_PORT}"
echo "- HTML reports   : http://localhost:${REPORTS_PORT}"

if [[ "${SETUP_COMPLETE}" == "true" ]]; then
  echo "- Setup status   : complete"
else
  echo "- Setup status   : pending (missing mandatory values)"
  echo "  Add Codespaces secrets and re-run: bash scripts/first-run-checkpoint-setup.sh"
fi

echo ""
echo "Tip: Use the Ports panel in Codespaces to open forwarded private URLs."
