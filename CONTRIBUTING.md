# Contributing

Thanks for your interest in improving this repository.

This repository is intended for learning, lab testing, research, proof-of-concept work, and internal experimentation. Contributions should reinforce that framing rather than weaken it.

## What kinds of contributions are welcome

Contributions are especially helpful for:

- documentation improvements
- setup and onboarding fixes
- Debian/Ubuntu and Codespaces usability improvements
- report UI and HTML template improvements
- Check Point workflow guidance improvements
- bug fixes that make the template easier and safer to use

## Before you open a pull request

Please:

1. Keep changes focused and easy to review.
2. Update documentation when behavior changes.
3. Avoid committing real credentials, API keys, hostnames, or other sensitive data.
4. Prefer demo-safe examples and clearly label demo-only defaults.
5. Do not add language that implies legal compliance, certification, CE marking, or guaranteed production safety.
6. Do not suggest that the MIT license removes statutory liability or regulatory obligations.
7. Prefer synthetic, anonymized, or redacted examples over real personal data, customer data, or sensitive incident artifacts.

## Security issues

If you believe you found a security issue, please do **not** open a public issue first.

See `SECURITY.md` for reporting guidance.

## Development notes

- Project-local OpenCode skills live under `.opencode/skills/`.
- Project-local agents live under `.opencode/agents/`.
- Main startup and setup scripts live under `scripts/`.
- Reports are generated into `reports/`.

## Pull request guidance

When opening a pull request:

- describe the problem being solved
- summarize the approach taken
- mention any documentation updates
- keep unrelated formatting or refactoring out of the same PR when possible
- call out any new third-party model, dataset, package, service, or license dependency
- highlight any change that could move the repo closer to production, customer-facing, or commercial use

## Code and documentation style

- Prefer small, readable changes.
- Keep setup instructions practical and concise.
- Preserve the repository’s focus on guided setup, Check Point workflows, and safe demo-friendly defaults.
- Use practical, cautious wording such as "designed to support" and "does not by itself ensure legal compliance" when legal or compliance topics come up.
