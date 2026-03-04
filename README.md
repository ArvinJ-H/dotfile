# Claude Code Dotfiles

Configuration files for [Claude Code](https://claude.ai/claude-code). A self-improvement system with skills, hooks, learnings, and mistake tracking.

## Quick Start

```bash
# Fork this repo, then:
git clone https://github.com/<your-username>/dotfile.git
cd dotfile
./setup.sh
```

This creates symlinks from the repo into `~/.claude/`. Re-run anytime to update.

## What's Included

### Core Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Behavioral instructions: working philosophy, communication style, session protocol |
| `persona.md` | Template for describing your technical background and working style |
| `settings.json` | Permissions, hooks, plugins |
| `LEARNINGS.md` | Learning observations tracked across sessions |
| `LEARNINGS-ARCHIVE.md` | Graduated learnings (already applied to CLAUDE.md or skills) |
| `MISTAKES.md` | Mistake patterns (3+ occurrences) treated as hard constraints |
| `MISTAKES-LOG.md` | Individual mistake entries, escalated by `/improve` |

### Skills

Skills are modular capabilities loaded on demand. Each lives in `skills/{name}/SKILL.md`.

| Skill | Purpose |
|-------|---------|
| `chart-master` | Data visualization and charting |
| `code-study` | Spaced repetition for codebase learning |
| `daily` | Daily standup and planning |
| `data-analyst` | Data analysis and reporting |
| `deepdive` | Deep research with sequential thinking and subagents |
| `improve` | Self-improvement: analyze mistakes/learnings, propose CLAUDE.md amendments |
| `plan` | Implementation planning methodology |
| `recall` | Knowledge recall from learnings, investigations, skills |
| `reflect` | Session reflection and persona updates |
| `research` | External research with workspace output |
| `review` | Code review with multi-angle verification |
| `ui-ux` | UI/UX design domain knowledge |

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `session-protocol.sh` | SessionStart | Load session context |
| `session-end-capture.sh` | SessionEnd | Capture session learnings |
| `pre-compact-capture.sh` | PreCompact | Save context before compaction |
| `iteration-guard.sh` | PostToolUseFailure (Bash) | Detect repeated failures |

### Other

| Path | Purpose |
|------|---------|
| `agents/verifier.md` | Adversarial verification agent definition |
| `reference/operational-rules.md` | Operational rules extracted from CLAUDE.md for context savings |

## How It Works

The system tracks mistakes and learnings across sessions:

1. **Mistakes** are logged in `MISTAKES-LOG.md` with category, scope, and severity
2. When a category hits 3+ entries, `/improve` escalates it to a pattern in `MISTAKES.md`
3. Patterns become hard constraints that prevent recurrence
4. **Learnings** follow a similar graduation path into CLAUDE.md amendments

Skills extend capabilities without bloating CLAUDE.md. They load on demand based on trigger conditions.

## Customization

- Edit `persona.md` to describe your own technical background
- Modify `CLAUDE.md` to match your working style and principles
- Add project-specific scopes to `LEARNINGS.md` and `MISTAKES.md` format sections
- Create new skills with `/skill-forge`

## Private Overlay

This repo is designed to work standalone or as a submodule inside a private repo. A private overlay can:

- Override `persona.md` with a full version (symlink takes priority)
- Add project-specific skills and hooks
- Merge additional permissions into `settings.json` via jq
- Add workspace data (investigations, audits, blog drafts)

See the fragment markers (`<!-- PRIVATE:... -->`) in some skills for the integration points.
