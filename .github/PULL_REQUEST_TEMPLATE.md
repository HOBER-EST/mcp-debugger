---
name: Pull Request
about: Submit a change to mcp-debugger
---

## What does this PR do?

<!-- One sentence. -->

## Related issue

<!-- "Fixes #123" or "Adds eval for #45" -->

## Checklist

- [ ] If I added a new failure pattern, I added an entry to `evals/evals.json`
- [ ] If I changed existing behavior, I updated the relevant eval case to match
- [ ] I ran `python3 -m json.tool < evals/evals.json` to validate JSON
- [ ] I read [`CONTRIBUTING.md`](../../CONTRIBUTING.md)
- [ ] Bilingual parity preserved (EN + ZH)
- [ ] No new external dependencies added without discussion

## Type of change

- [ ] Bug fix (non-breaking)
- [ ] New failure pattern (new `### 2.X` section in `skill.md` + eval case)
- [ ] Documentation
- [ ] Tests
- [ ] Refactor (no functional change)

## How was this tested?

<!-- Describe. If you ran the skill, paste a sample invocation. -->

## Screenshots / Diffs

<!-- If applicable, paste the diff or a screenshot of the output. -->

```diff
- before
+ after
```

## Notes

<!-- Anything reviewers should pay attention to. -->
