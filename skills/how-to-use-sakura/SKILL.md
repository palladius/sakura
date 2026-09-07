---
name: how-to-use-sakura
description: Comprehensive operational guide and skill for AI agents to master, build, test, run, and extend sakura.
metadata:
  creator: sumaron v0.3.0
  date: 2026-09-07
---

# 🌸 How to Use and Hack Sakura (Swiss Army Knife Unnecessary Repository yet Awesome)

> *"Tutte le strade portano a Roma, ma tutte le shell portano a Sakura!"* 🤌🍕
> 
> Welcome, autonomous agent! You have arrived in **Sakura**, Riccardo's (`@palladius`) legendary Swiss Army Knife repository (🇨🇭🔪🍍📦😆). It contains a high-density collection of shell utilities, ruby helper libraries, bash prompt customizations, system management recipes (`minicook`), Gemini CLI automation tasks, and developer productivity hacks accumulated over decades.

---

## 🎯 1. Overview & Architecture

### Mental Model & Core Purpose
Sakura is an open-source "dotfiles on steroids" and shared productivity monorepo. It powers shell sessions, Dockerized toolboxes, AI workflows, and personal machine orchestration.
Rather than a single monolithic app, Sakura is structured as a decentralized suite of lightweight utilities interacting through POSIX conventions, environment variables, and Ruby / Bash scripts.

```
                  ┌──────────────────────────────────────────────┐
                  │                 Sakura Root                  │
                  └──────┬───────────────┬────────────────┬──────┘
                         │               │                │
            Shell & Bin  │     Ruby Core │     Agent/AI   │ Recipes & Configs
            ┌────────────▼──┐ ┌──────────▼─────┐ ┌────────▼───────┐ ┌──────────────▼─────┐
            │ bin/          │ │ lib/sakura.rb  │ │ ricc-skills/   │ │ templates/          │
            │  - git-bloat- │ │ lib/recipes/   │ │ docz/gemini-   │ │  - bashrc.inject    │
            │    analyzer   │ │  (minicook)    │ │   cli/         │ │ VERSION & CHANGELOG │
            │  - gcp-mcp-   │ │                │ │ tasklis/       │ │ Makefile, Dockerfile│
            │    pinger     │ │                │ │                │ │                     │
            └───────────────┘ └────────────────┘ └────────────────┘ └─────────────────────┘
```

### Architectural Pillars
- **`bin/`**: The executable command center. Houses single-purpose CLI utilities (e.g., `git-bloat-analyzer`, `gcp-mcp-pinger`, `richelp`, `minicook`, text mutators like `act` and `rainbow`).
- **`lib/`**: Reusable Ruby modules. Previously relied on `sakuric`, now unified under `lib/sakura.rb`. Also contains `lib/recipes/` for `minicook` (a minimalist Chef/Puppet-like configuration engine using `facter`).
- **`templates/`**: Shell injections like `templates/bashrc.inject` which configure user environments, define `SAKURADIR`, and inject aliases/functions.
- **`ricc-skills/` & `docz/gemini-cli/`**: Agent skills, Gemini CLI demo recipes, and AI prompts.
- **`tasklis/`**: System maintenance tasks (e.g., `tasklis/reclaim-disk-space/` tracking disk bloat across machines).

---

## ⚡ 2. Essential Commands

### Environment Setup & Installation
```bash
# Export the root directory (ensure no missing trailing slash issues!)
export SAKURADIR="$(pwd)"
export PATH="$SAKURADIR/bin:$PATH"

# Test environment detection and version check
sakura-check-version
```

### Build & Container Execution (Make & Docker)
Sakura includes a `Makefile` and `Dockerfile` for containerized environments:
```bash
# Build the Sakura Docker image
make build
# Or directly via docker
docker build -t palladius/sakura .

# Run the Sakura container
make run
# Or with interactive shell
docker run -it --rm palladius/sakura /bin/bash

# Test the local web preview (serves index.html with version info)
make test || curl http://localhost:8080/VERSION
```

### Script Execution & Verification
```bash
# Run git bloat analyzer on current repo
./bin/git-bloat-analyzer

# Verify GCP MCP tool connectivity with green bullets 🟢🤌
./bin/gcp-mcp-pinger --help

# Test minicook recipe discovery
./bin/minicook list

# Shell output filters
echo "Hello Sakura" | rainbow
```

---

## 🔑 3. Key Entry Points

| Path / File | Purpose & Responsibilities |
|---|---|
| `VERSION` | Single source of truth for semantic versioning (e.g., `2.8.6`). Must be bumped on non-trivial changes. |
| `CHANGELOG.md` | Formal release history. Must use Gitmoji and keep-a-changelog semver structure. |
| `GEMINI.md` | Core repository behavioral instructions for AI agents (style, git habits, issue tracking). |
| `bin/` | Primary shell tools. Executables must be executable (`chmod +x`) and handle path variability cleanly. |
| `lib/sakura.rb` | Main Ruby entry point replacing the legacy `sakuric` gem. |
| `templates/bashrc.inject` | Bootstrap template sourced by user shell environments (`~/.bashrc` / `~/.zshrc`). |
| `lib/recipes/` | MiniCook installation recipes (e.g., recipes defining installation, tests, and clean uninstallation). |
| `tasklis/` | Hostname-scoped automated tasks (e.g., `tasklis/reclaim-disk-space/etc/${HOSTNAME}/`). |

---

## 🛡️ 4. Operational Constraints & Gotchas

1. **The Italian Persona & Tone 🤌**:
   - As mandated by `GEMINI.md`, interactions must have a funny, non-serious tone with generous emoji usage (🍕, 🍝, 🤌, 🌸).
   - Occasional Italian proverbs and idioms ("*Mamma Mia!*", "*Chi va piano va sano e va lontano*") are actively encouraged in messages and documentation comments.

2. **Mandatory GitHub Issue Workflow**:
   - **Public Repo Policy**: Any non-trivial code modification, refactor, or feature addition **must** have a corresponding GitHub Issue filed first.
   - Use `gh issue create --title "..." --body "..."` when the `gh` CLI tool is available.

3. **Versioning & Changelog Invariants**:
   - Every change must update `CHANGELOG.md` using **Gitmoji** (e.g., `:sparkles:`, `:bug:`, `:wrench:`, `:rocket:`).
   - Any non-trivial modification **requires** updating the `VERSION` file.

4. **Directory Path Sensitivities (`SAKURADIR`)**:
   - Scripts frequently rely on `$SAKURADIR`. Ensure path joining handles missing trailing slashes cleanly (e.g., `"${SAKURADIR%/}/VERSION"` instead of `"$SAKURADIRVERSION"`).

5. **Ruby Compatibility**:
   - Ruby >= 3.0 is assumed. Legacy Ruby 2.7 support has been intentionally phased out.
   - Do **not** re-introduce the `sakuric` gem; use `lib/sakura.rb`.

6. **Safety Rules for Cleanup Tasks**:
   - In automated scripts (especially under `tasklis/reclaim-disk-space/`), **NEVER delete files without explicit user approval**. Always output before/after sizing and gather confirmation.

---

## 🛠️ 5. Development Recipes

### Recipe A: Adding a New Shell Utility Script to `bin/`
1. **Create GitHub Issue**:
   ```bash
   gh issue create --title ":sparkles: Add git-super-cleaner utility" --body "Utility to wipe stale local branches."
   ```
2. **Implement Script in `bin/`**:
   ```bash
   cat << 'EOF' > bin/git-super-cleaner
   #!/usr/bin/env bash
   set -euo pipefail

   echo "🌸 Running git-super-cleaner... 🤌"
   # Utility logic here
   EOF
   chmod +x bin/git-super-cleaner
   ```
3. **Bump Version & Changelog**:
   - Update `VERSION` (e.g., bump to `2.8.7`).
   - Add an entry under `## [2.8.7] - YYYY-MM-DD` in `CHANGELOG.md` with appropriate Gitmoji.
4. **Commit with Gitmoji**:
   ```bash
   git add bin/git-super-cleaner VERSION CHANGELOG.md
   git commit -m ":sparkles: FEAT: Added git-super-cleaner script 🌸🤌"
   ```

### Recipe B: Adding a New MiniCook Recipe to `lib/recipes/`
1. Navigate to `lib/recipes/`.
2. Define the recipe directory and YAML/Ruby specification with clear:
   - Prerequisites
   - Apply / Install command
   - Test command (post-requisite)
   - Clean uninstall command
3. Test discovery via `bin/minicook list`.

### Recipe C: Updating an Agent Skill or Gemini CLI Task
1. When adding workspace or task scripts under `tasklis/` or `docz/gemini-cli/`:
   - Keep host-specific logs isolated under `log/${HOSTNAME}.md`.
   - Update markdown status tables in the relevant `README.md` with status indicators:
     - 🟢 `<70%` / OK
     - 🟡 `70-90%` / Warning
     - 🔴 `>90%` / Critical Alert
2. Keep demo scripts mapped and launchable with `code <DIR>` and `code add <FILE>`.

