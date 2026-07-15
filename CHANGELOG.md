# Changelog

All notable changes to this project will be documented in this file.

## [2.8.2] - 2026-07-15
- :wrench: CHORE: Ignore local `.agents` folder in `.gitignore`.

## [2.8.1] - 2026-05-29
- :bug: FIXED: Fix missing slash in `sakura-check-version` when `SAKURADIR` has no trailing slash. 🤌 (fixes #12)
- :bug: FIXED: Fix `SAKURA_VER` export in `bashrc`.

## [2.8.0] - 2026-04-01
- :sparkles: Added `gcp-mcp-pinger` with detailed tool inspection and green bullets. 🟢🤌

## [2.7.0] - 2026-03-24
- :fire: REMOVED(GITHUB-ACTIONS): Removed failing and unused `.github/workflows/repostats-for-nice-project.yml` workflow.

## [2.6.1] - 2026-03-24
- :bug: FIXED(GITHUB-ACTIONS): Fix YAML indentation and syntax error in `.github/workflows/repostats-for-nice-project.yml`. (Reverted by removal in 2.7.0)
- :rocket: Updated repository reference from `bob/nice-project` to `palladius/sakura`.

## [2.6.0] - 2026-03-23
- :sparkles: Renamed `skills` to `ricc-skills`.
- :ghost: Removed "specific workspace" folder and related rejection logic.
- :rocket: Renamed "Gemini Skills Listing" to "Ricc's Skills Listing".
- :package: Removed private and corporate skill paths.
- :wrench: Removed machine-specific identification logic.

## [2.5.0] - 2026-03-06
- :musical_note: Added salsa_ridge.ogg and converted from salsa_ridge.wav -- made with Gemini CLI 🍝

## [2.4.3] - 2026-01-25
- Removed sakuric gem dependency entirely. Replaced lib/sakuric.rb with lib/sakura.rb.

## [2.4.1] - 2025-11-25
- Removed Sakuric with AGY and GCLI and by myself

## [2.4.0] - 2023-01-25
- Removed ruby-version now that 2.7 is deprecated and everyone uses 3.0. I want to believe 3.0 or 3.1 doesnt really move the needle.

## [2.3.0] - 2019-05-04
- Better travis test

## 2.8.3
- 🌸 Added `git-bloat-analyzer` script to analyze local repository bloat and size.

