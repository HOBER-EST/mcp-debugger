# Contributing

Thanks for your interest in `mcp-debugger`. The project is small on purpose — every contributor can realistically own one failure pattern and keep it sharp.

## Quick Decision Tree

| You want to... | Then... |
|----------------|---------|
| **Report a new MCP failure pattern** that the skill doesn't catch | [Open an issue](#reporting-a-new-failure-pattern) |
| **Add a regression test** for an existing pattern | [Add an eval case](#adding-an-eval-case) |
| **Improve a diagnostic or fix** in `skill.md` | [Edit the skill](#editing-skillmd) |
| **Fix a bug or polish docs** | [Submit a PR](#submitting-a-pr) |

---

## Reporting a New Failure Pattern

The most valuable contribution is a **new failure pattern the skill doesn't catch yet**. Open an issue with the following template:

```markdown
### Failure Title
Short, specific, action-oriented ("SSE server starts then loses connection after 30s")

### Symptoms
What does the user see? ("All tools disappear midway through a session")

### Configuration that reproduces it
The exact MCP server config that triggers the bug. Use a code block.
Sanitize API keys.

### Platform
macOS / Windows / Linux / all

### Claude Code version
The first version where this started appearing, if known.

### Expected behavior
What should happen instead?

### Observed behavior
What actually happens?

### Proposed fix
What's the one-paragraph fix? If you can include the exact code change, even better.
```

---

## Adding an Eval Case

The repo ships with 10 eval cases in [`evals/evals.json`](evals/evals.json). Each case is a structured test:

```jsonc
{
  "id": "my-new-case",                  // kebab-case, unique
  "name": "Short description",
  "severity": "critical|warning|hidden",
  "user_input": "What the user says to Claude",
  "context": {
    "platform": "any|windows|mac|linux|windows-zh",
    "configs": {
      "~/.claude.json": "<the broken config>"
    }
  },
  "expected_phases": ["scan", "diagnose", "fix", "verify"],
  "expected_findings": [
    {
      "id": "short-id-for-the-issue",
      "severity": "critical|warning|hidden",
      "match_any_phrase": ["phrase1", "phrase2"]
    }
  ],
  "expected_fixes": ["Plain description of what the fix does"]
}
```

**To add a case:**
1. Fork the repo.
2. Add your case to `evals/evals.json` (the schema is in the file header).
3. If you have a real broken config file, place it in `examples/` and reference it.
4. Open a PR. Title: `evals: add case for <your failure pattern>`.

**Quality bar:**
- The `user_input` should sound like a real user typing, not a contrived test.
- The `context.configs` should be valid JSON that could actually be loaded.
- `expected_findings` should be specific enough that a regression would be detectable.

---

## Editing `skill.md`

The `skill.md` file is the actual skill definition loaded by Claude Code. It's structured as:

1. **Core Principle** — what's true regardless of the situation.
2. **Phase 1: Scan** — which files to read, what to inventory.
3. **Phase 2: Diagnose** — each numbered subsection is one failure pattern.
4. **Phase 3: Fix** — copy-paste commands.
5. **Phase 4: Verify** — re-validation + smoke tests.
6. **Quick Reference** — symptom → cause → fix table.

### Adding a new pattern

1. **Add a new `### 2.X` subsection under "Phase 2: Diagnose"** with:
   - Failure description
   - Detection command (or static check)
   - Severity tag (🔴 / 🟡 / 🟠)
2. **Add the fix template** in "Phase 3: Fix" with a copy-pasteable code block.
3. **Add the symptom row** to the "Quick Reference" table.
4. **Add the eval case** to `evals/evals.json`.
5. **Mention it in `README.md`** under "What's Inside".

### Editing an existing pattern

- Be conservative — these patterns affect real users.
- If you change behavior, update the eval case in `evals/evals.json` to match.

---

## Submitting a PR

1. Fork the repo and create a feature branch: `git checkout -b fix/your-pattern-name`.
2. Make your changes.
3. If you added a new pattern, add the eval case.
4. Run `cat evals/evals.json | python3 -m json.tool` to validate JSON.
5. Open a PR with:
   - **Title**: `fix: <what>` or `evals: add case for <what>`
   - **Body**: link to issue if applicable, describe the change, paste the eval diff.
6. Expect a maintainer to run the eval case before merging.

---

## Style Guide

- One sentence per line in markdown headings — keep it scannable.
- Use code fences for all commands and JSON.
- Use tables for any "symptom → cause → fix" mapping — never prose.
- Keep emoji use to severity tags only (🔴 critical, 🟡 warning, 🟠 hidden).
- Avoid second-person ("you should...") in favor of imperative ("Add the field...").

---

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/). Be kind, be specific, ship fixes.

---

## Questions?

Open an issue and tag it `question`. No DMs please — public answers help the next person.
