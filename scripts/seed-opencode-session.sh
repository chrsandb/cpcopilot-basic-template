#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
USER_ENV_FILE="${HOME}/.config/opencode/checkpoint-secrets.env"
STATE_DIR="${HOME}/.local/state/checkpoint-copilot"
SEED_STATE_FILE="${STATE_DIR}/opencode-intro-seeded"

mkdir -p "${STATE_DIR}"

if [[ -f "${USER_ENV_FILE}" ]]; then
  set -a
  # shellcheck source=/dev/null
  source "${USER_ENV_FILE}"
  set +a
fi

OPENCODE_PORT="${OPENCODE_PORT:-4096}"
OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-}"
SEED_TITLE="Check Point CoPilot Intro"
SEED_PROMPT="Tell me about yourself"

export PATH="${HOME}/.local/npm-global/bin:${PATH}"

if [[ -f "${SEED_STATE_FILE}" ]]; then
  exit 0
fi

curl_json() {
  local method="$1"
  local url="$2"
  local body="${3:-}"

  if [[ -n "${OPENCODE_SERVER_PASSWORD}" ]]; then
    if [[ -n "${body}" ]]; then
      curl -sS -u "${OPENCODE_SERVER_USERNAME}:${OPENCODE_SERVER_PASSWORD}" -H 'Content-Type: application/json' -X "$method" "$url" -d "$body"
    else
      curl -sS -u "${OPENCODE_SERVER_USERNAME}:${OPENCODE_SERVER_PASSWORD}" -X "$method" "$url"
    fi
  else
    if [[ -n "${body}" ]]; then
      curl -sS -H 'Content-Type: application/json' -X "$method" "$url" -d "$body"
    else
      curl -sS -X "$method" "$url"
    fi
  fi
}

for _ in $(seq 1 30); do
  if curl_json GET "http://127.0.0.1:${OPENCODE_PORT}/global/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
 done

if ! curl_json GET "http://127.0.0.1:${OPENCODE_PORT}/global/health" >/dev/null 2>&1; then
  echo "[seed] OpenCode server is not reachable yet; skipping intro session seed."
  exit 0
fi

sessions_json="$(curl_json GET "http://127.0.0.1:${OPENCODE_PORT}/session" || echo '[]')"
if echo "${sessions_json}" | jq -e --arg t "${SEED_TITLE}" 'map(select((.title // .info.title // "") == $t)) | length > 0' >/dev/null 2>&1; then
  touch "${SEED_STATE_FILE}"
  exit 0
fi

create_body="$(jq -nc --arg title "${SEED_TITLE}" '{title:$title}')"
session_json="$(curl_json POST "http://127.0.0.1:${OPENCODE_PORT}/session" "${create_body}" || true)"
session_id="$(echo "${session_json}" | jq -r '.id // .ID // .sessionID // .info.id // empty' 2>/dev/null || true)"

if [[ -z "${session_id}" ]]; then
  echo "[seed] Could not create intro session; skipping."
  exit 0
fi

message_body="$(jq -nc --arg agent "checkpoint-copilot" --arg text "${SEED_PROMPT}" '{agent:$agent, parts:[{type:"text", text:$text}]}' )"
curl_json POST "http://127.0.0.1:${OPENCODE_PORT}/session/${session_id}/prompt_async" "${message_body}" >/dev/null 2>&1 || \
  curl_json POST "http://127.0.0.1:${OPENCODE_PORT}/session/${session_id}/message" "${message_body}" >/dev/null 2>&1 || true

touch "${SEED_STATE_FILE}"
echo "[seed] OpenCode intro session created."
