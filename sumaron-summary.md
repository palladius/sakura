---
sumaron_version: 0.3.0
date: 2026-09-07
path: /Users/riccardo/.gemini/antigravity/worktrees/sumaron/sumaron_repo_analysis_skills/bin/sumaron
hostname: mini-lobby
timestamp: 2026-09-07T08:20:16+02:00
model: gemini-flash-latest
files:
  - CHANGELOG.md
  - GEMINI.md
  - README.md
  - docs/sumaron/AGGREGATED_TODOS.md
  - docs/sumaron/HOW_TO_MAKE_THIS_BETTER.md
  - docs/sumaron/about.md
  - docz/gemini-cli/GEMINI.md
  - docz/gemini-cli/README.md
  - index.html
  - lib/recipes/README.md
  - skills/how-to-use-sakura/SKILL.md
  - tasklis/reclaim-disk-space/.talk-script.md
  - tasklis/reclaim-disk-space/GEMINI.md
  - tasklis/reclaim-disk-space/README.md
---

# 🌸 Sakura (*Swiss Army Knife Unnecessary Repository yet Awesome*) 🇨🇭🔪🍕

**Sakura** is a modular, personal productivity monorepo and "dotfiles on steroids" created by Riccardo (`@palladius`). Accumulating decades of personal dev tools, it brings color, humor, and rich POSIX utilities to shell environments, containerized workspaces, and LLM-assisted workflows.

---

### 📂 Repository Structure & Key Components

* 🚀 **CLI Utilities (`bin/`)**:
  * Single-purpose executable scripts and shell utilities.
  * Notable tools include `git-bloat-analyzer`, `gcp-mcp-pinger`, `richelp` (cheatsheet runner), `minicook`, and text/visual mappers (`rainbow`, `act`).

* 💎 **Ruby Core & System Recipes (`lib/`)**:
  * **`lib/sakura.rb`**: Core Ruby support library (modern replacement for the retired `sakuric` gem).
  * **`lib/recipes/` (MiniCook)**: A minimalist, experimental Chef/Puppet-style configuration management engine based on `facter`.

* 🤖 **AI Agents, Skills, and Gemini CLI Demos (`skills/`, `ricc-skills/`, `docz/gemini-cli/`)**:
  * Contains structured agent operational skills (e.g., `skills/how-to-use-sakura/SKILL.md`).
  * Catalog of interactive LLM demos (`sqlite-investigation`, `git-investigation`, `nanobanana`).
  * Automation tasks under `tasklis/` (such as disk space reclamation and node_modules bloat cleanup scoped by `${HOSTNAME}`).

* 🐚 **Shell Integration & Templates (`templates/`)**:
  * **`templates/bashrc.inject`**: Shell bootstrapping template to inject `SAKURADIR`, PATH additions, aliases, and custom multi-national PS1 prompt colorings.

* 📊 **Repository Health & Audit Reports (`docs/sumaron/`)**:
  * Generated reports tracking technical debt, open issues, and a prioritized security/defect audit (`HOW_TO_MAKE_THIS_BETTER.md`).

---

### ⚙️ Key Configuration & Meta Files

* 🏷️ **`VERSION` & `CHANGELOG.md`**: Tracks semantic releases (currently `v2.8.6`) using strict [Gitmoji](https://gitmoji.dev/) conventions.
* 🤖 **`GEMINI.md`**: Behavioral rules for AI assistants (mandates Italian humor/proverbs 🤌, Gitmoji commits, semver increments, and filing GitHub issues before non-trivial changes).
* 🐳 **`Dockerfile` & `Makefile` & `index.html`**: Container packaging files and a lightweight static landing page showing the current version and history.
