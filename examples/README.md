# Examples

These example MCP configs deliberately contain **6 different failure patterns**. Use them to verify `mcp-debugger` is working correctly, or to learn what each failure mode looks like.

## Files

| File | Contents | Run on |
|------|----------|--------|
| [`broken-mcp.json`](broken-mcp.json) | One config with 6 stacked failure patterns | macOS / Linux / Windows |
| [`fixed-mcp.json`](fixed-mcp.json) | The same intent, all issues resolved by the skill | Same |

## The 6 Failure Patterns in `broken-mcp.json`

| Server | Issue | Severity | Why it fails |
|--------|-------|----------|--------------|
| `playwright` | Missing `type` field | 🟡 | Silently dropped on load — your server just isn't there |
| `playwright` (Windows) | Missing `cmd /c` wrapper | 🟡 | `npx` won't resolve correctly on Windows |
| `amap-maps` | (fine, the control case) | ✅ | This one works — verify the skill doesn't false-positive |
| `foo-not-really-mcp` | Wrong npm package | 🟡 | Package name ends in `-mcp` but doesn't depend on `@modelcontextprotocol/sdk` — it's a CLI tool, not an MCP server |
| `needs-api-key` | Placeholder API key | 🟡 | `"your-key-here"` is not a real key — server will likely fail at first call |
| `remote-sse` | SSE server missing `url` | 🟡 | Claude won't know where to connect |
| `last-server` | Trailing comma | 🔴 | Breaks JSON parsing — **kills every other server in this file** |

## How to Use as a Regression Test

1. Copy `broken-mcp.json` to `~/.claude.json` (BACK UP your real config first).
2. Open Claude Code, describe your issue: *"My MCP servers don't load"*.
3. `mcp-debugger` should auto-trigger and produce these findings:
   - 🔴 Trailing comma in JSON
   - 🟡 `playwright` is missing the `type` field
   - 🟡 (on Windows) `playwright` and `amap-maps` need `cmd /c` wrapper
   - 🟡 `foo-not-really-mcp` doesn't depend on `@modelcontextprotocol/sdk`
   - 🟡 `needs-api-key` has a placeholder API key (not a real failure, but flag-worthy)
   - 🟡 `remote-sse` is missing the `url` field
4. After the skill runs its fix, the result should be structurally close to [`fixed-mcp.json`](fixed-mcp.json).

⚠️ **DO NOT leave broken-mcp.json as your real config.** It's deliberately broken. After the test, restore your real `~/.claude.json`.

## Why This File Exists

- **Regression test for the skill** — confirms the skill catches each known pattern.
- **Teaching artifact** — anyone reading the project can see what each failure looks like without setting one up.
- **Eval seed** — copy this into `evals/evals.json` as a real, reproducible case.

See [`../evals/evals.json`](../evals/evals.json) for the structured eval format.
