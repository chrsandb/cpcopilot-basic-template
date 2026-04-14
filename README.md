# Check Point OpenCode Codespaces Template

Private-template repository for spinning up a Check Point-focused OpenCode environment in GitHub Codespaces.

When a Codespace starts from this template, it:

- installs OpenCode automatically
- configures Node.js/npm runtime support for Check Point MCP servers
- runs OpenCode in web mode
- forwards the OpenCode web port and report server port
- provisions a global `checkpoint-copilot` OpenCode skill
- runs first-run setup for required secrets (with interactive prompts when possible)
- validates setup and prints a redacted summary

## Required Codespaces secrets

Set these in your repository/user Codespaces secrets before creating a Codespace:

- `CHECKPOINT_MGMT_HOST`
- `CHECKPOINT_USERNAME`
- `CHECKPOINT_PASSWORD`
- `CHECKPOINT_DOC_CLIENT_ID`
- `CHECKPOINT_DOC_SECRET_KEY`
- `OPENCODE_SERVER_PASSWORD`

Optional:

- `CHECKPOINT_MGMT_PORT` (default `443`)
- `CHECKPOINT_DOC_REGION` (default `EU`)
- `CHECKPOINT_DOC_AUTH_URL`
- `OPENCODE_PORT` (default `4096`)
- `REPORTS_PORT` (default `8081`)

A non-secret template is provided in `.env.example`.

## MCP servers preconfigured

Based on the official Check Point MCP packages:

- `management` → `@chkp/quantum-management-mcp`
- `management-logs` → `@chkp/management-logs-mcp`
- `threat-prevention` → `@chkp/threat-prevention-mcp`
- `https-inspection` → `@chkp/https-inspection-mcp`
- `documentation-tool` → `@chkp/documentation-mcp`

## Runtime flow

- `postCreateCommand` runs `scripts/setup-opencode.sh` and quick validation.
- `postStartCommand` runs `scripts/post-start.sh` which:
  1. runs first-run setup (`scripts/first-run-checkpoint-setup.sh`)
  2. starts OpenCode web (`scripts/start-opencode-web.sh`)
  3. starts report server (`scripts/start-report-server.sh`)
  4. runs quick validation (`scripts/validate-environment.sh --quick`)

If secrets are missing and startup is non-interactive, setup remains pending and you can complete it manually:

- `bash scripts/first-run-checkpoint-setup.sh`

## Access URLs in Codespaces

- OpenCode Web UI: forwarded `4096`
- HTML reports server: forwarded `8081`

Use the Codespaces **Ports** panel to open forwarded private URLs.

## Reports

Save generated HTML reports in `reports/`.

The local report server publishes this directory for easy sharing/review within the Codespace session.

## Security notes

- No real credentials are stored in this repository.
- Secrets are resolved from Codespaces environment variables and stored only in user-scoped runtime files under `~/.config/opencode`.
- Validation output is redacted and does not print secrets.
