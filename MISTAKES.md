# Mistakes -- Patterns

Active mistake patterns (3+ occurrences). Read on session start as hard constraints.
New mistakes go in `MISTAKES-LOG.md`. The Improve workflow (/meta) escalates patterns here when threshold is hit. Applied patterns (amendment in CLAUDE.md) are deleted -- git preserves history.

### Entry format (for MISTAKES-LOG.md)

```
### [short category] -- YYYY-MM-DD -- scope:<scope> -- severity:<level>
**What happened**: one-line description
**Root cause**: why it happened
**Prevention**: what to do differently
**Tags**: free-form, comma-separated
```

**Scope** (where the code lives, not where you're working from):
- `global` -> `~/.claude/CLAUDE.md` or global skills/hooks
- `<project-name>` -> project-level CLAUDE.md or skills

**Severity**: `minor` | `moderate` | `major` -- prioritises escalation order.
**Tags**: optional, free-form. Used by the Improve workflow (/meta) for cross-category pattern detection.

## Patterns

<!-- Escalated patterns with root cause and resolution -->
