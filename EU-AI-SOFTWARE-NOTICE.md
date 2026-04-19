# EU AI, Software, and Responsible Use Notice

This repository is designed to support learning, lab testing, research, proof-of-concept work, and internal experimentation.

It is intended to help users explore Check Point-focused assistant workflows in a controlled environment. It is not presented as production-ready software, a managed service, or a legal/compliance solution.

## Practical position of this repository

- Learning and lab use first. Use demo environments, synthetic data, anonymized data, or carefully redacted inputs whenever possible.
- Human review required. Outputs, reports, suggestions, and generated content require independent review before operational use.
- No compliance claim. This repository does not claim to be "compliant" with EU law, the EU AI Act, GDPR, product-safety law, or any sector-specific regime.
- No fake assurance. Nothing in this repository should be interpreted as certification, CE marking, legal advice, or a guarantee of lawful or safe deployment.
- MIT license limits. The MIT license is relevant to copyright permissions and warranty disclaimers, but it does not by itself remove statutory liability, regulatory obligations, or duties that may apply under Union or Member State law.

## Intended use

This repository is intended to help with:

- education and familiarization
- lab validation and sandbox testing
- research and proof-of-concept work
- internal experimentation with appropriate oversight
- documentation-backed analysis and reporting in non-production contexts

## Uses that are not safe defaults for this repository

This repository is not a safe default for:

- production deployment
- customer-facing or commercial services without additional review
- high-risk or safety-critical environments
- fully automated operational or legal decision-making
- processing real personal data, customer data, incident data, or regulated data unless separately assessed and governed
- use cases that could affect employment, access to services, security decisions, or other rights without qualified review and human oversight

## EU AI framing

The EU AI Act uses a risk-based approach. This repository is intended to help teams experiment responsibly, but that alone does not determine the legal classification of any downstream system.

In practice:

- if AI-generated content or AI-assisted analysis is shown to users, teams should use clear transparency language
- if a downstream use case moves toward operational decision-making, profiling, or materially affects people, teams should perform a fresh legal and technical assessment
- if general-purpose AI models or third-party AI services are used, teams should understand the provider terms, usage restrictions, documentation, and data-handling model

This repository is designed to support safer experimentation, not to replace the provider's documentation, internal controls, or legal review.

## Personal data and GDPR

If personal data is ever used in prompts, datasets, logs, issues, screenshots, or test artifacts:

- identify a lawful basis and document the purpose
- follow data minimization and storage limitation principles
- avoid unnecessary special category data and sensitive operational data
- prefer anonymized, pseudonymized, or synthetic inputs
- understand where prompts, logs, telemetry, and generated reports may be stored or forwarded

Using this repository does not by itself ensure GDPR compliance.

## Software and liability expectations

Software and AI-related systems can create legal exposure even when shared under an open-source license.

- disclaimers are intended to set expectations and reduce misuse risk
- disclaimers do not by themselves override all statutory liability regimes
- downstream integrators and deployers remain responsible for their own use, packaging, representations, data handling, security posture, and legal assessment

If this repository is later sold, bundled, hosted as a service, integrated into a customer workflow, or marketed as a product capability, a separate legal review should be treated as mandatory.

## Cybersecurity and secure development expectations

This repository is intended to help teams experiment safely, but it does not by itself ensure secure deployment.

Maintainers and users should:

- handle credentials carefully
- report vulnerabilities responsibly
- avoid unsafe defaults where practical
- validate integrations before operational use
- review third-party dependencies, model providers, and MCP tooling before broader deployment

## Copyright, datasets, and third-party materials

Users and contributors should respect:

- third-party software licenses
- documentation usage terms
- dataset provenance and usage restrictions
- model provider terms and output restrictions
- confidentiality and trade secret limits

Do not assume that public availability of code, data, screenshots, or model outputs means unrestricted reuse is allowed.

## Escalation triggers

Review with qualified counsel before production or commercial use, especially if any of the following become true:

- the repository is used with real customer or employee data
- the repository is used in a regulated or safety-relevant workflow
- the repository is distributed as part of a paid service or commercial offering
- the repository is marketed with performance, security, or compliance claims
- the repository is integrated into automated decision support that could materially affect people or organizations

## Short-form notice

Learning and lab use only. Designed to support research, proof-of-concept work, and internal experimentation. Not production-ready. Does not by itself ensure legal compliance. Review with qualified counsel before production or commercial use.
