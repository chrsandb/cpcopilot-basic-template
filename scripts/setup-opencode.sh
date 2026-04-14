#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

NPM_GLOBAL_DIR="${HOME}/.local/npm-global"
OPENCODE_CONFIG_DIR="${HOME}/.config/opencode"
SKILL_SRC="${REPO_ROOT}/templates/skills/checkpoint-copilot/SKILL.md"
SKILL_DEST_DIR="${OPENCODE_CONFIG_DIR}/skills/checkpoint-copilot"
SKILL_DEST="${SKILL_DEST_DIR}/SKILL.md"

mkdir -p "${NPM_GLOBAL_DIR}/bin" "${OPENCODE_CONFIG_DIR}" "${SKILL_DEST_DIR}" "${HOME}/.local/state/checkpoint-copilot"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "[setup] Node.js/npm are required but not found. Ensure devcontainer build installs Node 20+."
  exit 1
fi

npm config set prefix "${NPM_GLOBAL_DIR}" >/dev/null 2>&1 || true

PATH_LINE='export PATH="$HOME/.local/npm-global/bin:$PATH"'
if ! grep -Fq "$PATH_LINE" "${HOME}/.bashrc" 2>/dev/null; then
  echo "$PATH_LINE" >> "${HOME}/.bashrc"
fi
if ! grep -Fq "$PATH_LINE" "${HOME}/.profile" 2>/dev/null; then
  echo "$PATH_LINE" >> "${HOME}/.profile"
fi

export PATH="${NPM_GLOBAL_DIR}/bin:${PATH}"

echo "[setup] Installing/updating OpenCode..."
npm install -g opencode-ai@latest >/dev/null

if [[ -f "${SKILL_SRC}" ]]; then
  cp "${SKILL_SRC}" "${SKILL_DEST}"
fi

mkdir -p "${REPO_ROOT}/reports"

cat <<'MSG'
[setup] OpenCode runtime prepared.
[setup] Global skill installed: checkpoint-copilot
[setup] Run scripts/first-run-checkpoint-setup.sh to complete Check Point MCP setup if needed.
MSG
