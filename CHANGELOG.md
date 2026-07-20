# Changelog

All notable changes to `mcp-debugger` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive English README with hero, comparison table, symptom reference, and demo
- Bilingual parity for Chinese README (was previously thinner)
- `LICENSE` file (MIT) — was referenced but missing
- `evals/evals.json` with 10 real-world failure patterns — was referenced but missing
- `examples/broken-mcp.json` — config with 6 stacked failure patterns for testing
- `examples/fixed-mcp.json` — same config after the skill resolves everything
- `examples/README.md` — walk-through of what each broken line demonstrates
- `CONTRIBUTING.md` — guide for adding new failure patterns and eval cases
- GitHub issue templates (`bug_report.md`, `feature_request.md`) and PR template

### Changed
- `README.md` now opens with a pain-point narrative instead of a feature list
- ZH README title corrected from personal "新手向" note to consistent branding

## [0.1.0] — 2025-06-10

### Added
- Initial release of the `mcp-debugger` skill for Claude Code
- 4-phase diagnostic flow: Scan → Diagnose → Fix → Verify
- Coverage for 8 failure patterns:
  - Global MCP in legacy `~/.claude/mcp.json`
  - JSON syntax errors
  - Missing `type` field
  - Windows `cmd /c` wrapper requirement
  - Wrong npm package (no `@modelcontextprotocol/sdk` dependency)
  - Missing env vars / API keys
  - Project servers not enabled
  - Stale `mcpServers` in `settings.json`
- Bilingual README (English + 中文)
- Symptom → Diagnosis → Fix quick reference table
