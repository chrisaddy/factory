# Repository Guidelines

## 1) Project Overview
`factory` is a small Bash-based bootstrap/update utility for installing and maintaining a project-local harness checkout.

- Install/update entrypoint: `install.sh`
- Runtime helper entrypoint: `bin/factory` (symlinked to `./factory` in target projects)
- Core behavior: clone/update this repo into `.factory`, then expose a local helper command for updates/status/path.

## 2) Architecture & Data Flow
High-level flow:

1. User runs installer (`bash install.sh ...` or documented `curl | bash`).
2. `install.sh` resolves:
   - project directory (`--path`, default `PWD`)
   - repo URL (`--repo`, `FACTORY_REPO_URL`, local `origin`, or default GitHub URL)
   - branch (`--branch` or `FACTORY_BRANCH`, default `main`)
3. Installer updates existing `.factory` git checkout or clones fresh (`--reinstall` forces replacement).
4. Installer validates `.factory/bin/factory`, then creates/refreshes `./factory` symlink.
5. User runs `./factory <command>`; helper performs git operations inside the harness checkout.

State/config inputs:
- Environment: `FACTORY_BRANCH`, `FACTORY_REPO_URL`
- CLI flags: `--path`, `--repo`, `--branch`, `--reinstall`
- Persistent state: `.factory/` git checkout + its branch history

## 3) Key Directories
- `bin/` — executable helper scripts (`bin/factory` is the command dispatcher).
- `.omp/` — local OMP workspace directory (present but empty in current repo snapshot).
- Root (`/`) — installer and docs (`install.sh`, `README.md`).

## 4) Development Commands
Primary commands used in this repo:

```bash
# Installer usage
bash install.sh --help

# Install/update into current directory
bash install.sh

# Install into another directory or from fork/branch
bash install.sh --path ~/projects/my-project --repo https://github.com/<you>/<fork>.git --branch main

# Helper usage (after install)
./factory help
./factory status
./factory update
./factory path
```

Useful local script sanity checks:

```bash
bash -n install.sh
bash -n bin/factory
```

## 5) Code Conventions & Common Patterns
This codebase is shell-first and intentionally minimal.

- **Shell mode**: Bash with strict mode (`set -euo pipefail`) in both scripts.
- **CLI parsing pattern**: `while [[ $# -gt 0 ]]; do case "$1" in ...`.
- **Usage/help pattern**: `usage()` function + heredoc output.
- **Error handling**:
  - Guard checks with explicit message + `exit 1` for expected failure paths.
  - Otherwise rely on fail-fast strict mode for command failures.
- **Git safety pattern**:
  - Always `fetch --all --prune` before checkout/pull.
  - Use `git pull --ff-only` to avoid implicit merge commits.
- **Configuration injection**: environment variables + CLI flags; no config file/state container abstraction.
- **Async/state management**: no async model; state lives in filesystem (`.factory`) and git metadata.

## 6) Important Files
- `README.md` — canonical user-facing install and usage documentation.
- `install.sh` — install/update orchestrator; parses options and provisions `./factory` symlink.
- `bin/factory` — runtime helper command dispatcher (`update`/`status`/`path`/`help`).

Not present in this repository snapshot:
- Test directories/files
- CI workflows (`.github/workflows`)
- Language package/build manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, etc.)

## 7) Runtime/Tooling Preferences
- **Required runtime/tools**: `bash` + `git`.
- **OS assumptions**: Unix-like shell environment with symlink support.
- **Package manager**: none (no Node/Bun/Python/Rust package manifest in repo).
- **Tooling scope**: scripts are self-contained; no formatter/linter configured in-repo.

OMP skills reference (for future extension work):
- Current repo has no committed skills.
- If adding skills for OMP, follow: `https://github.com/can1357/oh-my-pi/blob/main/docs/skills.md`.

OMP hooks reference (for future extension work in `oh-my-pi`):
- Runtime path is extension-first (`--hook` is treated as alias of `--extension`).
- Legacy hook subsystem still exists at `src/extensibility/hooks/*` and uses module default-export factories.
- Core interception events to know: `tool_call` (pre-exec block/allow) and `tool_result` (post-exec output override).

OMP custom tools reference (for future extension work in `oh-my-pi`):
- Use custom tools when the model must call executable code directly (skills are guidance only; hooks/extensions are lifecycle/interception layers).
- A tool module exports a factory returning one tool or an array, each with a TypeBox `parameters` schema and `execute(toolCallId, params, onUpdate, ctx, signal)`.
- Active integration paths are SDK `options.customTools` and loader APIs (`discoverAndLoadCustomTools` / `loadCustomTools`).
- Design constraints: globally unique tool names, deterministic `details` payloads, cooperative cancellation via `AbortSignal`, and `hasUI` checks before UI calls.

Custom tool examples (upstream reference):
- `https://github.com/can1357/oh-my-pi/tree/main/packages/coding-agent/examples/custom-tools`
- Includes `hello/` (minimal) and `todo/` (stateful + `onSession` + custom rendering) examples.
- Discovery layout expectation in examples: `subdirectory/index.ts` (e.g., `todo/index.ts`).

## 8) Testing & QA
Current QA is manual/smoke-test driven (no automated test framework in repo).

Recommended smoke checks after script changes:

```bash
# 1) Syntax checks
bash -n install.sh
bash -n bin/factory

# 2) Installer help path
bash install.sh --help

# 3) End-to-end in temp project (example)
mkdir -p /tmp/factory-smoke && cd /tmp/factory-smoke
bash /path/to/factory/install.sh --repo /path/to/factory --branch main
./factory path
./factory status
```

Coverage expectations are currently undefined; treat installer + helper command smoke checks as the minimum bar.