---
name: Feature Request
about: Add a new MCP failure pattern or extend an existing one
title: "[feat] "
labels: enhancement
---

## The failure pattern

<!-- What's broken? In one paragraph. -->

## How to reproduce

<!-- Minimum config + steps to reproduce. -->

## The expected behavior

<!-- What should the skill say/do when this happens? -->

## Proposed fix

<!-- Either describe in words, paste a config diff, or both. -->

```diff
  "mcpServers": {
+   "your-server": {
+     "type": "stdio",
+     "command": "..."
+   }
  }
```

## Platform impact

<!-- Which platforms does this affect? -->

- [ ] macOS
- [ ] Linux
- [ ] Windows (EN)
- [ ] Windows (ZH)
- [ ] All

## Eval case

<!-- If you can, fill in the evals.json entry. If not, just describe. -->

```jsonc
{
  "id": "your-case-id",
  "user_input": "What the user types",
  "context": { "configs": { "~/.claude.json": "..." } },
  "expected_findings": [ ... ]
}
```

## Notes

<!-- Anything else — links, prior art, alternative designs. -->
