# AGENTS.md — AI Instructions (Aider)

This file contains instructions for AI coding agents (primarily Aider).
It is AI-specific and takes precedence over other repository docs.
If anything here conflicts with other guidance, follow this file.
If still in doubt, ask before proceeding.

> These rules also apply to any automated system that edits, reviews, or
> generates code in this repository (not just Aider).

## Operating mode

### Default behavior

- Ask clarifying questions first when requirements, scope, or intent are
  ambiguous.
- Propose a brief plan using numbered steps (Markdown `1.`, `2.`, …) and wait
  for approval before making changes.
- Optimize for correctness over speed.
- Prefer small, reviewable diffs over large refactors.
- Ensure all plans, proposed steps, and code changes are **idiomatic for the language or tool used** (e.g., POSIX‑compliant shell, standard Ansible practices, YAML conventions, etc.).
  - Prefer standard modules, syntax, and patterns typical for that ecosystem over ad‑hoc or non‑idiomatic constructs.

## Aider workflow

- Start feature work and refactors in Aider `ask` mode.
- In `ask` mode:
  - If you need to read files to produce an accurate plan or review, **ask for
    access first**.
    - Do this before presenting a full plan or full review notes.
    - If only a quick outline is possible without files, keep it minimal and
      clearly label it as provisional.
  - After reviewing the relevant files, provide the final plan **at the end**
    (so it does not get buried).
  - Present the plan as **numbered steps** using Markdown ordered lists (`1.`,
    `2.`, …).
    - Use sub-bullets only to clarify a numbered step.
    - Use as many steps as needed to be clear; do not artificially compress the
      plan.
  - Refine the plan until it is unambiguous and scoped.
  - **Do not write code.**
  - **Do not generate diffs, patches, or code blocks.**
- Switch to implementation only when the user explicitly approves the plan.
  - Primary approval signal: invoking `/code` (for example, `/code apply the
    current plan`).
  - Secondary approval signals: explicit confirmation such as `yes`,
    `approved`, or `proceed`.
- During implementation:
  - Follow the approved plan exactly.
  - Treat the approved plan as a contract.
  - Do not reinterpret, reorder, or optimize the plan during implementation.
  - Reference step numbers or plan names in commit messages or code comments
    when applicable, to maintain traceability.
  - If any step seems unnecessary, incorrect, or suboptimal, stop and ask
    before deviating.
  - Do not expand scope or introduce opportunistic changes.
  - If you cannot complete the approved plan safely or correctly, stop.
    - Explain what blocks completion.
    - Do not ship partial or speculative implementations without asking.
  - If the plan needs to change, stop and return to `ask` mode behavior (ask
    questions and propose an updated plan).

## Communication style (clear, pragmatic)

- Use clear, simple language and short sentences.
- Be factual and direct; avoid unnecessary verbosity.
- If a suggestion is flawed or risky, say so plainly and explain why in 1–3 sentences.
- Limit alternatives to at most two; briefly describe tradeoffs.
- Express uncertainty explicitly instead of hedging.
- State any assumptions about environment, OS, or variables if they affect outcomes.
- If unsure, say what is uncertain and ask a targeted question.

## Scope control (hard rules)

- Only modify code that is explicitly part of the requested change.
  - Do not “clean up”, reformat, rename, or refactor adjacent code.
  - If a related change seems necessary, ask first.
- Never revert previous changes unless explicitly told to.
  - If reverting seems necessary, ask first.

### Out-of-scope examples (non-exhaustive)

The following are considered out of scope unless explicitly requested:

- Reformatting or rewrapping unrelated YAML.
- Renaming variables, tasks, or files for stylistic consistency.
- Opportunistic refactors or “while I’m here” improvements.
- Upgrading or changing dependencies.
- Changing role, playbook, or directory structure.

### Files and areas (ask-first)

Before doing any of the following, ask for confirmation:

- Creating new files.
- Modifying CI / GitHub Actions / workflow definitions.
- Changing shared defaults in `roles/phdz_defaults/`.
- Any change that alters public interfaces (public variables/facts/role
  behavior).

## Repository conventions

- Follow all rules in `CONVENTIONS.md`.
- Treat `CONVENTIONS.md` as the authoritative source for:
  - naming conventions
  - idempotency requirements
  - Ansible task/handler patterns
  - tags
  - YAML style and formatting
- Do not restate or reinterpret those rules.
- If a proposed change would violate `CONVENTIONS.md`, say so plainly and ask
  before proceeding.

## Change process

### Before editing

- Restate the goal in one sentence.
- List assumptions and unknowns as questions (if any).
- Propose the minimal change set and which files will be touched.

### While editing

- Keep changes surgical.
- Preserve existing structure and patterns.
- Avoid introducing new dependencies or changing versions unless explicitly
  requested.

### After editing

- Summarize what changed and why, referencing files touched.
- Call out any potential impacts to Molecule/CI behavior.
- If tests were not run, say which command(s) would validate the change.

## Code review / PR review instructions

When reviewing a PR (or a set of changes):

- Briefly describe the functional change you believe the PR introduces.
- Provide a **numbered** list of recommended changes, ordered highest to lowest priority.
  - Use numbered items so individual points can be referenced.
  - Use sub-bullets only to clarify a numbered item.
- Clearly flag potential security-related issues.
  - Use an explicit label like `SECURITY:` and explain the risk briefly.
  - Security-relevant areas include (but are not limited to):
    - use of `shell` or `command`
    - credential or secret handling
    - file permissions and ownership
    - network access or downloads
    - privilege escalation (`become`)
  - Prefer conservative guidance (when in doubt, flag and ask).

A review is successful when it verifies:
- correctness and idempotency,
- security and safety,
- conformance with `CONVENTIONS.md` and repository patterns.

## Conflict handling

- If instructions conflict or cannot all be satisfied, stop and ask which constraint to prioritize.
- If a request is incorrect, unsafe, or inconsistent with repo goals:
  - Say so plainly.
  - Explain why briefly.
  - Propose a safer or more correct alternative.
  - Proceed only if the user explicitly overrides with clear instructions.

## Safety checks (ask-first triggers)

Stop and ask before proceeding if any of these are true:

- You are unsure whether a change is in scope.
- A change could affect multiple roles/playbooks beyond the target.
- A change could alter public variables, defaults, or external behavior.
- A change would modify CI workflows or shared defaults.
