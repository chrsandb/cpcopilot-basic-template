# Roadmap

This roadmap captures possible improvements for the Check Point OpenCode CoPilot environment over time. It is intentionally user-first: the main goal is to make the repository easier to adopt, safer to use, and more useful for real lab and demo workflows without changing its learning/lab positioning.

Nothing here should be read as a production commitment, compliance claim, or hosted-service promise. Items are directional opportunities for maintainers and contributors.

## Roadmap principles

- Keep first-run success as the top priority.
- Preserve the Check Point-focused workflow and MCP-first operating model.
- Prefer practical safety improvements over heavier process.
- Improve reports, examples, and troubleshooting before expanding scope.
- Treat anything that moves toward production use, hosted services, or automated enforcement as a separately reviewed track.

## Near term

### Onboarding and setup

- Improve the guided setup flow with clearer branch logic for on-premises versus Smart-1 Cloud.
- Add more actionable validation errors before and after setup so users know exactly what is missing.
- Add a simple `doctor` or `status` style helper that summarizes setup state, installed binaries, configured MCP tools, and service health.
- Add a documented reset/reconfigure flow for users who want to switch endpoints, auth methods, or ports cleanly.
- Reduce ambiguity around default models and provider setup so users understand when OpenCode still needs provider configuration.

### Reports and examples

- Improve the `reports/` landing experience with better empty states, clearer timestamps, filtering/sorting, and report metadata.
- Add a small set of starter report templates or examples for common tasks such as rule review, threat prevention review, HTTPS inspection review, and incident-style summaries.
- Add scenario-based prompt packs to the documentation so new users can move from setup to useful analysis faster.
- Add example report screenshots or sample outputs that are clearly synthetic and safe to share.

### Troubleshooting and day-2 usability

- Expand `scripts/validate-environment.sh` to catch more common misconfiguration cases before runtime.
- Add better service status and log discovery guidance for OpenCode and the reports server.
- Harden restart/stop behavior so stale PID files and orphaned processes are easier to diagnose.
- Make the welcome flow more explicit about what it started, what it skipped, and what the user should do next.

## Mid term

### Workflow depth

- Add richer guidance for policy inspection, object analysis, log investigations, Spark management analysis, and documentation-backed troubleshooting.
- Add curated workflow recipes for common audit and investigation tasks with clear scope, expected outputs, and report suggestions.
- Add support assets for generating more consistent HTML reports, including reusable sections for findings, evidence, recommendations, and lab-use disclaimers.

### Quality and maintainability

- Add lightweight automated checks for shell scripts, JSON validity, docs consistency, and repo health.
- Add a small automated test harness for key scripts and setup flows, especially around environment handling and Smart-1 Cloud detection.
- Track dependency/version management more explicitly so OpenCode and MCP package upgrades are easier to validate.
- Reduce accidental repo noise from local package artifacts where practical.

### Safer defaults and governance UX

- Add stronger in-context reminders before users connect real environments or provide sensitive data.
- Add clearer contributor guidance for changes that expand scope toward production or customer-facing usage.
- Add a short architecture and data-flow document explaining where prompts, reports, secrets, and external API calls may flow.

## Long term

### Extensibility

- Offer optional integration patterns for additional guardrails, gateways, or observability without making them part of the default path.
- Provide a cleaner extension model for adding new OpenCode skills, agents, report templates, and environment profiles.
- Consider optional packaging improvements for repeated internal demos, workshops, or lab environments.

### Enterprise-style readiness tracks

- Explore optional profiles for stricter authentication, audit logging, or data-handling controls, while keeping the default template lightweight.
- Add clearer separation between demo-safe defaults and more tightly governed modes of use.
- If the project ever moves toward broader operational use, start a separate review track for legal, privacy, and security implications rather than folding that into the basic template by default.

## Lakera Guard exploration

Lakera Guard is a credible future integration area for this repository as an optional security layer around agent and LLM interactions. Based on Lakera's current official API docs, the main SaaS screening endpoint is `https://api.lakera.ai/v2/guard`, requests use `Authorization: Bearer $LAKERA_GUARD_API_KEY`, and Lakera recommends screening each LLM interaction or agent step with a project-specific policy rather than relying on the default policy.

This should be treated as an optional, separately configured enhancement rather than a default dependency for this template.

### Suggested integration goals

- Screen user inputs before they are sent to external models when data leakage or prompt attack risk is a concern.
- Screen model outputs before they are shown to users or written into reports.
- Optionally screen tool-oriented agent steps for prompt injection, unsafe content, or sensitive data exposure.
- Document how Lakera decisions are advisory versus blocking so the user experience stays understandable.

### Candidate implementation options

#### 1. OpenCode plugin

- Build an OpenCode plugin that intercepts selected chat or agent traffic and calls Lakera Guard before model execution and/or before final response rendering.
- Best fit if the goal is reusable runtime enforcement with centralized logic.
- Likely needs explicit configuration for API key, base URL, region, project ID, fail-open versus fail-closed behavior, and what message roles to screen.
- Good long-term direction if this repository wants guardrails that feel native inside OpenCode rather than bolted on externally.

#### 2. Repository skill

- Create a new repo skill such as `lakera-guard` or `checkpoint-safe-guardrails` that teaches the agent when and how to invoke Lakera-related tooling or workflows.
- Best fit for guidance, policy, and reporting help, but not sufficient on its own for hard runtime enforcement.
- Useful for prompting patterns like "screen this prompt before use", "explain why this interaction was flagged", or "generate a report section summarizing Lakera screening outcomes".
- This is the lightest-weight option and a good first step if the team wants process and guidance before deeper runtime integration.

#### 3. Local wrapper or gateway script

- Add a small local screening proxy or wrapper script that sends content to Lakera Guard before passing it onward to a model or report workflow.
- Best fit if the team wants a practical prototype with minimal OpenCode internals work.
- Could be used for guarded report generation, guarded prompt submission, or a future "safe mode" startup profile.
- A good middle ground between a pure skill and a full plugin.

#### 4. MCP-adjacent guard service

- Introduce a local helper service or MCP-style tool whose job is to screen candidate content and return flagging results, breakdowns, or masking payloads.
- Best fit if the repository wants guardrail checks to be available as explicit tool calls in agent workflows.
- This would work well for reports and manual review flows, but it still would not automatically enforce every chat turn unless paired with a plugin or wrapper.

### Recommended phased approach

1. Start with documentation plus a lightweight skill that explains when to screen content and how to interpret results.
2. Add a local wrapper or helper tool for optional guarded workflows and report generation.
3. Explore a proper OpenCode plugin only if native runtime interception is worth the added maintenance cost.

### Design decisions to resolve before implementation

- What content should be screened: user input only, user plus tool input, model output, or full agent step flows.
- Whether the default behavior should be advisory, warn-and-continue, block, or configurable by profile.
- How flagged results should be surfaced to users without exposing sensitive text unnecessarily.
- Where Lakera secrets and project IDs should live, and how they should be documented in `.env.example`, setup scripts, and user guidance.
- Whether guarded mode should be opt-in globally, per session, or per workflow.

### Related repo changes that would likely be needed

- Add optional env vars such as `LAKERA_GUARD_API_KEY`, `LAKERA_GUARD_BASE_URL`, `LAKERA_GUARD_PROJECT_ID`, and a guard mode toggle.
- Update setup, validation, and docs to explain optional Lakera configuration and expected behavior.
- Add a report pattern for including Lakera screening results in a clearly labeled facts/inference/recommendations section when relevant.
- Add explicit warning language that Lakera integration improves screening posture but does not by itself guarantee safe or compliant deployment.

## Not in focus right now

- Turning the repository into a production-ready managed service.
- Expanding into unrelated non-Check-Point domains by default.
- Making legal, regulatory, certification, or compliance claims.
- Adding heavy governance overhead to the default lab workflow.

## References

- Repo context: `README.md`, `INSTRUCTIONS.md`, `AGENTS.md`, `LAB-GOVERNANCE.md`, `scripts/`
- Lakera Guard docs:
  - API overview: https://docs.lakera.ai/docs/api
  - Guard endpoint: https://docs.lakera.ai/docs/api/guard
  - Integration guide: https://docs.lakera.ai/docs/integration
