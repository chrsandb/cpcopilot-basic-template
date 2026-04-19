# Security Policy

This repository is intended to help teams experiment more safely, but it does not by itself ensure secure deployment, legal compliance, or production readiness.

## Supported scope

This repository is a public template and helper environment for running OpenCode with Check Point-focused MCP tooling.

Please report security issues related to:

- repository scripts and configuration
- accidental credential exposure in tracked files
- unsafe defaults in setup or startup behavior
- report-server exposure or authentication issues
- guidance that could cause unintended sensitive-data disclosure
- wording or defaults that could encourage unsafe production use without adequate review

## Reporting a vulnerability

Please do **not** open a public issue for suspected security problems.

Instead, report the issue privately using one of these paths:

- GitHub security advisories for this repository, if enabled
- a private contact method maintained by the repository owner

If you are setting this repository public, replace this section with your preferred reporting address or process.

## What to include

Please include, when possible:

- a clear description of the issue
- affected files or scripts
- reproduction steps
- impact assessment
- any suggested mitigation

## Sensitive data

Do not include live credentials, API keys, production hostnames, or sensitive customer data in reports.

If testing requires realistic examples, prefer synthetic, anonymized, or carefully redacted data.

## Secure use expectations

Users and contributors should treat this repository as a lab environment.

- Validate integrations before operational use.
- Review third-party packages, model providers, and data sources before broader deployment.
- Do not assume the MIT license eliminates security, privacy, or liability obligations.
- Review with qualified counsel and appropriate security reviewers before production or commercial use.

## Response expectations

This repository is maintained on a best-effort basis. Public fixes may be prepared after the issue has been reviewed and sensitive details have been handled appropriately.
