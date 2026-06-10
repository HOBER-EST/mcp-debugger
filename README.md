# mcp-debugger

A Claude Code skill for diagnosing and fixing MCP (Model Context Protocol) server configuration issues.

## What It Does

When MCP servers don't show up, fail to start, or tools are missing, this skill systematically scans your configuration, finds every problem, and fixes them in one pass.

### Covered Issues

- 🔴 **Global MCP servers in wrong file** — `~/.claude/mcp.json` is legacy, silently ignored in 2.x; servers must be in `~/.claude.json`
- 🔴 **JSON syntax errors** — invalid JSON kills all servers in that file
- 🟡 **Missing `type` field** — server silently ignored without `"type": "stdio"`
- 🟡 **Windows `cmd /c` wrapper** — `npx` commands need wrapping on Windows
- 🟡 **Wrong npm packages** — not every package with "mcp" in the name is an MCP server
- 🟡 **Missing environment variables** — API keys required but not set
- 🟡 **Project servers not enabled** — `.mcp.json` servers need `enableAllProjectMcpServers`
- 🟡 **Stale config in wrong files** — `mcpServers` in `settings.json` conflicts

## Quick Start

### Install the skill in Claude Code

```bash
claude mcp add --scope user skill-creator
```

Then copy `skill.md` to `~/.claude/skills/mcp-debugger/skill.md`.

Or install via the marketplace if published there.

### Trigger the skill

Just describe your MCP issue in Claude Code — it triggers automatically on:
- "MCP not showing"
- "MCP server won't start"
- "MCP tools missing"
- Any MCP config question

Or invoke explicitly:
```
/mcp-debugger
```

## MCP Configuration Model (Claude Code 2.x)

This skill understands the actual config hierarchy:

```
Priority  Location                                    Scope
────────  ──────────────────────────────────────────  ─────────────────
  1       CLI --mcp-config flag                       Single invocation
  2       ./.mcp.json                                 Project (team-shared)
  3       ~/.claude.json → projects.<cwd>.mcpServers  Local (project-only)
  4       ~/.claude.json → mcpServers                 Global (all projects)
  5       ~/.claude/mcp.json                          ❌ LEGACY — ignored!
```

## Usage Example

```
User: "我的全局MCP服务器都不显示了，只有项目级的能看到"

mcp-debugger:
  → Scans ~/.claude.json, ./.mcp.json, settings.json
  → Finds: 6 servers in legacy ~/.claude/mcp.json
  → Migrates to ~/.claude.json → mcpServers
  → Deletes legacy file
  → Reminds to restart Claude Code
```

## Files

```
mcp-debugger/
├── skill.md          # The skill definition (loaded by Claude Code)
├── evals/
│   └── evals.json    # Evaluation test cases
├── README.md         # This file
└── README.zh-CN.md   # Chinese documentation
```

## License

MIT
