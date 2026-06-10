---
name: mcp-debugger
description: Diagnose and fix MCP server configuration issues. Use when MCP servers don't show up, fail to start, or tools are missing. Covers: mcp.json validation, Windows cmd/c wrapper, misnamed npm packages (MCP vs non-MCP), env var issues, silent failures, SSE vs stdio, startup smoke tests. Triggers on: MCP not showing, MCP config, mcp.json, MCP tools missing, MCP server won't start.
---

# MCP Configuration & Debugging Assistant

Help users diagnose and fix MCP (Model Context Protocol) server issues. The goal is **scan once, diagnose precisely, fix in one pass**.

## Core Principle

**MCP config lives in TWO locations.** Claude Code 2.x reads global MCP servers from `~/.claude.json` (not a separate file):

```
~/.claude.json → mcpServers   ← ALL global MCP servers (available everywhere)
<project>/.mcp.json            ← Project-scoped MCP servers
```

**The `~/.claude/mcp.json` separate file is LEGACY and silently ignored in 2.x.** If you find servers in that file, they must be migrated into `~/.claude.json`.

### MCP Config Priority (Claude Code 2.x)

| Priority | Location | Scope |
|----------|----------|-------|
| 1 (highest) | CLI `--mcp-config` flag | Single invocation |
| 2 | `./.mcp.json` | **Project-scoped** (team-shared, git-tracked) |
| 3 | `~/.claude.json` → `projects.<cwd>.mcpServers` | Local-scoped (current project only) |
| 4 | `~/.claude.json` → top-level `mcpServers` | **Global scope** (all projects) |
| 5 (legacy) | `~/.claude/mcp.json` | ❌ Silently ignored in 2.x |

---

## Phase 1: Scan — Read Both Config Sources

### 1.1 Read the two canonical sources (ALWAYS)

| # | Source | Role |
|---|--------|------|
| 1 | `~/.claude.json` → `mcpServers` | **Global MCP servers** — available in every project |
| 2 | `<project>/.mcp.json` | **Project MCP servers** — only in this project |

**Check `~/.claude.json` first** — read the file, look for the top-level `mcpServers` key. If it exists, inventory its servers. If it doesn't exist, global MCP is not configured.

### 1.2 Check project server enablement

Project servers in `.mcp.json` need to be enabled. Check `<project>/.claude/settings.local.json` for:

- `"enableAllProjectMcpServers": true` — **all** project servers are enabled (modern, preferred)
- `"enabledMcpjsonServers": ["server-a", "server-b"]` — only **listed** servers are enabled (legacy)

Also check `~/.claude.json` → `projects["<path>"].enabledMcpjsonServers` if it exists (older pattern).

### 1.3 Legacy/Stale config check

These files may contain MCP config in wrong/legacy locations:

| File | What to check |
|------|--------------|
| `~/.claude/mcp.json` | ❌ **LEGACY** — silently ignored in 2.x. Migrate servers to `~/.claude.json` → `mcpServers` |
| `~/.claude/.mcp.json` | ❌ **LEGACY** — same as above (dot-prefixed variant) |
| `~/.mcp.json` | ❌ **LEGACY** — old home-directory location |
| `~/.claude/settings.json` | Should NOT have `mcpServers` — if present, it's stale |
| `<project>/.claude/settings.json` | Should NOT have `mcpServers` |

### 1.4 Build the inventory

After reading, show a concise table:

```markdown
## MCP Inventory

### Global (~/.claude.json → mcpServers)
| Server | Type | Command | Status |
|--------|------|---------|--------|
| playwright | stdio | npx @playwright/mcp | ✅ |
| amap-maps | stdio | npx @amap/amap-maps-mcp-server | ✅ |

### Project (<project>/.mcp.json)
| Server | Type | Command | Enabled? |
|--------|------|---------|----------|
| mcp-hosts-installer | stdio | npx mcp-hosts-installer | ✅ |

### Issues Found
| Severity | Issue | File |
|----------|-------|------|
| 🔴 CRITICAL | Global servers in legacy mcp.json — won't be loaded | ~/.claude/mcp.json |
| 🟡 WARNING | ... | ... |
```

---

## Phase 2: Diagnose — Find Every Problem

Run through ALL checks below. Don't stop at the first issue — collect everything, then fix together.

### 2.1 Global MCP location check (MOST COMMON ISSUE)

**This is the #1 cause of "global MCP servers not showing up."**

- If global servers are defined in `~/.claude/mcp.json` (separate file) → 🔴 **CRITICAL: won't be loaded by 2.x**
- Global servers MUST be in `~/.claude.json` under the top-level `mcpServers` key
- The `~/.claude/mcp.json` file is legacy and silently ignored

**Migration command:**
```bash
python3 -c "
import json
with open('$HOME/.claude/mcp.json') as f: mcps = json.load(f)
with open('$HOME/.claude.json') as f: claude = json.load(f)
claude['mcpServers'] = mcps['mcpServers']
with open('$HOME/.claude.json', 'w') as f: json.dump(claude, f, indent=2, ensure_ascii=False)
print('Migrated', len(mcps['mcpServers']), 'servers to claude.json')
"
# Then remove the legacy file:
rm ~/.claude/mcp.json
```

### 2.2 Required fields validation

Every server entry MUST have:

```json
{
  "server-name": {
    "type": "stdio",        // REQUIRED: "stdio" or "sse"
    "command": "...",       // REQUIRED for stdio: the executable
    "args": ["..."],        // Optional but common: command arguments
    "env": {}               // Optional: environment variables
  }
}
```

**Common mistakes:**
- Missing `type` → server silently ignored
- `type: "sse"` without `url` → won't connect
- `type: "stdio"` without `command` → won't start
- Extra trailing commas → invalid JSON, whole file fails to parse
- Comments in JSON (`//` or `/* */`) → invalid JSON

### 2.3 JSON syntax validation

```bash
python3 -c "import json; json.load(open('$FILE')); print('valid')" || echo "INVALID JSON"
```

A single syntax error in a config file kills ALL servers in that file. Always validate first.

**For `~/.claude.json`**, use UTF-8 encoding explicitly (the file often contains Unicode characters from user prompts):
```bash
python3 -c "import json; json.load(open('$HOME/.claude.json', encoding='utf-8')); print('valid')" || echo "INVALID JSON"
```

### 2.4 Windows: `cmd /c` wrapper requirement

On Windows, `npx`-based servers MUST use the `cmd /c` wrapper:

```json
// ✅ CORRECT on Windows:
{ "command": "cmd", "args": ["/c", "npx", "-y", "package-name"] }

// ❌ WRONG on Windows — will fail:
{ "command": "npx", "args": ["-y", "package-name"] }
```

This applies to `npx`, `npm exec`, and any npm-bin-based command. Direct executables (`node`, `python`) don't need the wrapper.

**Check:** For every server on Windows, if `command` is `npx` (not `cmd`), flag it.

### 2.5 NPM package verification

Not every npm package is an MCP server. A package named `something-mcp` might still be a CLI tool, and a package without `mcp` in its name might actually be an MCP server.

**Quick check — does the package depend on the MCP SDK?**

```bash
# Check if package has @modelcontextprotocol/sdk as a dependency
npm view <package-name> dependencies --json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print('YES' if '@modelcontextprotocol/sdk' in d else 'NO')"
```

If NO → the package is likely NOT an MCP server. It might be a CLI tool, a library, or something else entirely.

**Common confusion cases:**
| Package | Is MCP Server? | Notes |
|---------|---------------|-------|
| `@playwright/mcp` | ✅ Yes | Official Playwright MCP |
| `firecrawl-mcp` | ✅ Yes | Firecrawl MCP server |
| `prompt-optimizer-mcp` | ✅ Yes | Prompt optimizer MCP |
| `prompt-optimizer` | ❌ No | It's a promptfoo CLI tool |
| `mcp-hosts-installer` | ✅ Yes | MCP installer |

### 2.6 Server startup smoke test

Test if each server actually starts and stays alive (MCP servers should hang waiting for stdio input, not exit immediately):

```bash
# Test a server — it should NOT exit within 5 seconds
timeout 5 <command> <args> 2>&1 && echo "EXITED (BAD)" || echo "HUNG (GOOD)"
```

A server that exits immediately won't work. Common causes:
- Missing required environment variable
- Package not installed / not found
- Node.js version too old
- Binary crash on startup

**Test all servers in parallel:**

```bash
# Quick parallel smoke test for all servers
for name in server1 server2 server3; do
  (timeout 3 <cmd> 2>&1 | head -3 && echo "--- $name: EXITED (BAD)" || echo "--- $name: OK") &
done
wait
```

### 2.7 Environment variable issues

Check `env` blocks for:
- Missing required API keys (server may start but return errors)
- Hardcoded keys that might be expired
- Keys that should use shell variable expansion (not supported in MCP config — must be literal values)

### 2.8 Enablement issues (project servers only)

- If `.mcp.json` has servers but `enableAllProjectMcpServers` is not `true` AND no `enabledMcpjsonServers` lists them → won't load
- If `enabledMcpjsonServers` lists a server not defined in any `.mcp.json` → orphan entry, silently skipped
- If both `enableAllProjectMcpServers: true` AND `enabledMcpjsonServers` exist → the boolean wins (all enabled)

### 2.9 Duplicate server names

Same server name in BOTH `~/.claude.json` → `mcpServers` AND `.mcp.json` → project one wins, global one is shadowed. Usually unintentional.

### 2.10 SSE-specific checks

For `type: "sse"` servers:
- Must have `url` field (e.g., `"url": "http://localhost:8080/sse"`)
- Server must be running before Claude Code starts
- Check: `curl -s <url>` returns SSE events

---

## Phase 3: Fix — Resolve All Issues

### 3.1 Fix priority order

1. **Global servers in wrong file** — migrate from `~/.claude/mcp.json` to `~/.claude.json` → `mcpServers` (this is the #1 fix)
2. **JSON syntax errors** — fix next, they block everything
3. **Missing `type` fields** — add `"type": "stdio"` or `"type": "sse"`
4. **Windows `cmd /c` wrapper** — wrap npx commands
5. **Wrong npm packages** — correct the package name
6. **Missing env vars** — add required keys
7. **Enablement** — set `enableAllProjectMcpServers: true` or add to list
8. **Legacy cleanup** — remove `~/.claude/mcp.json` after migration, remove stale `mcpServers` from settings.json

### 3.2 Configuration templates

**Global server — add to `~/.claude.json` under top-level `mcpServers`:**

The `~/.claude.json` file already contains user settings (`numStartups`, `tipsHistory`, `projects`, etc.). Add a top-level `mcpServers` key alongside them:

```json
{
  "numStartups": 160,
  "tipsHistory": { ... },
  "projects": { ... },
  "mcpServers": {
    "my-global-server": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "npx", "-y", "my-mcp-server"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

⚠️ **Important:** When modifying `~/.claude.json`, always use `encoding='utf-8'` in Python — the file contains Unicode characters from user prompts that will break with default GBK encoding on Windows.

**Global server template (stdio via node, cross-platform):**
```json
{
  "mcpServers": {
    "my-server": {
      "type": "stdio",
      "command": "node",
      "args": ["/absolute/path/to/server.js"],
      "env": {}
    }
  }
}
```

**SSE server template:**
```json
{
  "mcpServers": {
    "my-sse-server": {
      "type": "sse",
      "url": "http://localhost:8080/sse",
      "env": {}
    }
  }
}
```

**Project server template (in `<project>/.mcp.json`):**
```json
{
  "mcpServers": {
    "my-project-server": {
      "type": "stdio",
      "command": "cmd",
      "args": ["/c", "npx", "-y", "my-mcp-server"],
      "env": {}
    }
  }
}
```

### 3.3 Project server enablement

In `<project>/.claude/settings.local.json`:
```json
{
  "enableAllProjectMcpServers": true
}
```

Or, for selective enablement (legacy):
```json
{
  "enabledMcpjsonServers": ["server-a", "server-b"]
}
```

---

## Phase 4: Verify — Confirm Everything Works

### 4.1 JSON re-validation

```bash
# Validate ~/.claude.json (use utf-8!)
python3 -c "import json; json.load(open('$HOME/.claude.json', encoding='utf-8')); print('claude.json: valid')"
# Validate project .mcp.json
python3 -c "import json; json.load(open('<project>/.mcp.json')); print('project .mcp.json: valid')"
```

### 4.2 Server count check

Count servers defined vs servers expected. Flag any mismatch.

### 4.3 No servers left in legacy files

```bash
# These should NOT exist or should be empty:
test -f ~/.claude/mcp.json && echo "⚠️ LEGACY: ~/.claude/mcp.json still exists — remove it" || echo "✅ clean"
test -f ~/.mcp.json && echo "⚠️ LEGACY: ~/.mcp.json still exists — remove it" || echo "✅ clean"
```

### 4.4 No stale mcpServers in wrong files

```bash
# Should return NOTHING:
grep -rn '"mcpServers"' ~/.claude/settings.json 2>/dev/null
grep -rn '"mcpServers"' <project>/.claude/settings.json 2>/dev/null
```

Note: `~/.claude.json` WILL have `mcpServers` (both top-level for global and inside `projects` for local) — that's correct.

### 4.5 Final state summary

```markdown
## Final State

### ~/.claude.json → mcpServers (global — 6 servers)
| Server | Command | Tested |
|--------|---------|--------|
| playwright | npx @playwright/mcp | ✅ |
| amap-maps | npx @amap/amap-maps-mcp-server | ✅ |

### <project>/.mcp.json (project — 1 server)
| Server | Command | Enabled |
|--------|---------|---------|
| mcp-hosts-installer | npx mcp-hosts-installer | ✅ |

### Actions Required
- Restart Claude Code for changes to take effect
```

---

## Quick Reference: Symptoms → Diagnosis → Fix

| Symptom | Most Likely Cause | Fix |
|---------|------------------|-----|
| **Global MCP servers not showing (project ones work)** | Servers in `~/.claude/mcp.json` (legacy, ignored) instead of `~/.claude.json` → `mcpServers` | Migrate servers to `~/.claude.json` top-level `mcpServers`, delete legacy file |
| **No MCP servers appear at all** | JSON syntax error in config | Validate & fix JSON |
| **One server missing, others work** | Missing `type` field, wrong package name, or Windows needs `cmd /c` | Add type, verify package, add wrapper |
| **Server in .mcp.json not loading** | Not enabled | Set `enableAllProjectMcpServers: true` |
| **npx server fails on Windows** | Missing `cmd /c` wrapper | `"command": "cmd", "args": ["/c", "npx", ...]` |
| **Server starts but exits immediately** | Missing env var or package crash | Check env vars, test manually |
| **Server loads but no tools appear** | Wrong package (not an MCP server) | Verify with `npm view <pkg> dependencies` |
| **SSE server won't connect** | Server not running or wrong URL | curl the URL, check server is up before Claude |
| **All servers suddenly disappeared** | Stale `mcpServers: {}` in settings.json | Remove mcpServers from settings.json |

---

## After Fixing

Always remind the user: **"MCP configuration is read at startup. Please restart Claude Code for changes to take effect."**

## Pro Tips

1. **Global MCP goes in `~/.claude.json`, NOT `~/.claude/mcp.json`** — this is the #1 misconfiguration. The separate `mcp.json` file is legacy and silently ignored in 2.x.
2. **One server per test** — if you add 3 new servers and none work, remove 2 and debug 1 at a time.
3. **Test the command directly** — run the exact `command` + `args` in a terminal. If it doesn't work there, it won't work in Claude.
4. **Check Node.js version** — some MCP servers need Node 18+. Run `node --version`.
5. **npm cache issues** — if `npx` fails with cryptic errors, try `npx -y <pkg>` (the `-y` skips the confirmation prompt).
6. **Absolute paths over relative** — for `node`-based servers, always use absolute paths. Relative paths are resolved from Claude Code's working directory, which may not be what you expect.
7. **Use UTF-8 when editing `~/.claude.json`** — the file contains Unicode characters from user prompts. Default GBK encoding on Windows will corrupt it.
