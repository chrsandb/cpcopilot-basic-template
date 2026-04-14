#!/usr/bin/env bash

codespaces_forwarded_base_url() {
  local port="${1:-}"

  if [[ -z "${port}" ]]; then
    return 1
  fi

  if [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
    printf 'https://%s-%s.%s' "${CODESPACE_NAME}" "${port}" "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
    return 0
  fi

  return 1
}

service_url_for_port() {
  local port="${1:-}"
  local path="${2:-}"
  local base_url

  if base_url="$(codespaces_forwarded_base_url "${port}")"; then
    printf '%s%s' "${base_url}" "${path}"
  else
    printf 'http://localhost:%s%s' "${port}" "${path}"
  fi
}
