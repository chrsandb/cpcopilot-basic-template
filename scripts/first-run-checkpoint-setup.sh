#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_DIR}/opencode.json"
USER_ENV_FILE="${OPENCODE_CONFIG_DIR}/checkpoint-secrets.env"
STATUS_FILE="${OPENCODE_CONFIG_DIR}/checkpoint-setup-status.json"
MCP_FRAGMENT_FILE="${REPO_ROOT}/templates/opencode/checkpoint-mcp-fragment.json"

mkdir -p "${OPENCODE_CONFIG_DIR}" "${HOME}/.local/state/checkpoint-copilot"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

CHECKPOINT_MGMT_HOST="${CHECKPOINT_MGMT_HOST:-}"
CHECKPOINT_USERNAME="${CHECKPOINT_USERNAME:-admin}"
CHECKPOINT_PASSWORD="${CHECKPOINT_PASSWORD:-}"
CHECKPOINT_DOC_CLIENT_ID="${CHECKPOINT_DOC_CLIENT_ID:-}"
CHECKPOINT_DOC_SECRET_KEY="${CHECKPOINT_DOC_SECRET_KEY:-}"
CHECKPOINT_MGMT_PORT="${CHECKPOINT_MGMT_PORT:-443}"
CHECKPOINT_DOC_REGION="${CHECKPOINT_DOC_REGION:-EU}"
CHECKPOINT_DOC_AUTH_URL="${CHECKPOINT_DOC_AUTH_URL:-}"
OPENCODE_PORT="${OPENCODE_PORT:-4096}"
REPORTS_PORT="${REPORTS_PORT:-8081}"
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"

is_interactive=false
if [[ -t 0 && -t 1 ]]; then
  is_interactive=true
fi

prompt_if_missing() {
  local var_name="$1"
  local prompt_text="$2"
  local default_value="${3:-}"
  local is_secret="${4:-false}"

  local current_value="${!var_name:-}"
  if [[ -n "${current_value}" ]]; then
    return
  fi

  if [[ "${is_interactive}" != "true" ]]; then
    return
  fi

  if [[ "${is_secret}" == "true" ]]; then
    read -r -s -p "${prompt_text} " input_value
    echo
  else
    if [[ -n "${default_value}" ]]; then
      read -r -p "${prompt_text} [${default_value}] " input_value
      input_value="${input_value:-${default_value}}"
    else
      read -r -p "${prompt_text} " input_value
    fi
  fi

  printf -v "${var_name}" '%s' "${input_value}"
}

prompt_if_missing "CHECKPOINT_MGMT_HOST" "Check Point management host (DNS/IP):"
prompt_if_missing "CHECKPOINT_USERNAME" "Check Point username:" "admin"

if [[ -z "${CHECKPOINT_PASSWORD}" && "${is_interactive}" == "true" ]]; then
  read -r -s -p "Check Point password (leave blank to use temporary lab suggestion demo123): " pass_input
  echo
  if [[ -z "${pass_input}" ]]; then
    CHECKPOINT_PASSWORD="demo123"
    echo "[setup] Using temporary lab suggestion for password. Replace with a real secret ASAP."
  else
    CHECKPOINT_PASSWORD="${pass_input}"
  fi
fi

prompt_if_missing "CHECKPOINT_DOC_CLIENT_ID" "Documentation tool CLIENT_ID:"
prompt_if_missing "CHECKPOINT_DOC_SECRET_KEY" "Documentation tool SECRET_KEY:" "" true

if [[ "${is_interactive}" == "true" && -z "${CHECKPOINT_DOC_AUTH_URL}" ]]; then
  read -r -p "Optional documentation AUTH_URL (press Enter to skip): " auth_url_input
  CHECKPOINT_DOC_AUTH_URL="${auth_url_input:-}"
fi

cat > "${USER_ENV_FILE}" <<EOF
# User-scoped secrets/state for Check Point OpenCode Codespaces setup.
# File permissions are restricted and this file is intentionally not tracked by git.
CHECKPOINT_MGMT_HOST=${CHECKPOINT_MGMT_HOST}
CHECKPOINT_USERNAME=${CHECKPOINT_USERNAME}
CHECKPOINT_PASSWORD=${CHECKPOINT_PASSWORD}
CHECKPOINT_MGMT_PORT=${CHECKPOINT_MGMT_PORT}
CHECKPOINT_DOC_CLIENT_ID=${CHECKPOINT_DOC_CLIENT_ID}
CHECKPOINT_DOC_SECRET_KEY=${CHECKPOINT_DOC_SECRET_KEY}
CHECKPOINT_DOC_REGION=${CHECKPOINT_DOC_REGION}
CHECKPOINT_DOC_AUTH_URL=${CHECKPOINT_DOC_AUTH_URL}
OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD}
OPENCODE_PORT=${OPENCODE_PORT}
REPORTS_PORT=${REPORTS_PORT}
EOF
chmod 600 "${USER_ENV_FILE}"

BASE_CONFIG_JSON="$(mktemp)"
cat > "${BASE_CONFIG_JSON}" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "server": {
    "port": ${OPENCODE_PORT},
    "hostname": "0.0.0.0"
  },
  "share": "manual"
}
EOF

MERGED_JSON="$(mktemp)"
if [[ -f "${OPENCODE_CONFIG_FILE}" ]] && jq empty "${OPENCODE_CONFIG_FILE}" >/dev/null 2>&1; then
  jq -s '.[0] * .[1] * .[2]' "${OPENCODE_CONFIG_FILE}" "${BASE_CONFIG_JSON}" "${MCP_FRAGMENT_FILE}" > "${MERGED_JSON}"
else
  if [[ -f "${OPENCODE_CONFIG_FILE}" ]]; then
    cp "${OPENCODE_CONFIG_FILE}" "${OPENCODE_CONFIG_FILE}.bak.invalid"
  fi
  jq -s '.[0] * .[1]' "${BASE_CONFIG_JSON}" "${MCP_FRAGMENT_FILE}" > "${MERGED_JSON}"
fi

mv "${MERGED_JSON}" "${OPENCODE_CONFIG_FILE}"

setup_complete=true
for req in CHECKPOINT_MGMT_HOST CHECKPOINT_USERNAME CHECKPOINT_PASSWORD CHECKPOINT_DOC_CLIENT_ID CHECKPOINT_DOC_SECRET_KEY; do
  if [[ -z "${!req:-}" ]]; then
    setup_complete=false
    break
  fi
done

redact() {
  local value="$1"
  if [[ -z "$value" ]]; then
    echo "<missing>"
  else
    local len=${#value}
    if (( len <= 4 )); then
      echo "****"
    else
      echo "${value:0:2}***${value:len-2:2}"
    fi
  fi
}

cat > "${STATUS_FILE}" <<EOF
{
  "setupComplete": ${setup_complete},
  "opencodePort": "${OPENCODE_PORT}",
  "reportsPort": "${REPORTS_PORT}"
}
EOF

echo ""
echo "===== Check Point Codespace Setup Summary (redacted) ====="
echo "Management host         : $(redact "${CHECKPOINT_MGMT_HOST}")"
echo "Management username     : $(redact "${CHECKPOINT_USERNAME}")"
echo "Management password     : $(redact "${CHECKPOINT_PASSWORD}")"
echo "Doc CLIENT_ID           : $(redact "${CHECKPOINT_DOC_CLIENT_ID}")"
echo "Doc SECRET_KEY          : $(redact "${CHECKPOINT_DOC_SECRET_KEY}")"
echo "Doc AUTH_URL            : $(redact "${CHECKPOINT_DOC_AUTH_URL}")"
echo "OpenCode password set   : $( [[ -n "${OPENCODE_SERVER_PASSWORD}" ]] && echo "yes" || echo "no" )"
echo "OpenCode config file    : ${OPENCODE_CONFIG_FILE}"
echo "Setup complete          : ${setup_complete}"

echo ""
if [[ "${setup_complete}" != "true" ]]; then
  echo "[setup] Setup is incomplete. Add missing Codespaces secrets and re-run: bash scripts/first-run-checkpoint-setup.sh"
fi

rm -f "${BASE_CONFIG_JSON}"
