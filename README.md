# AI Coding Assistant Dotfiles

Configuration system for AI coding assistants. Built for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) but the patterns (behavioral instructions, self-improvement loops, modular skills) transfer to other AI tools.

## Table of Contents

1. [What This Is](#what-this-is)
2. [Quick Start](#quick-start)
3. [Directory Structure](#directory-structure)
4. [Core Configuration](#core-configuration)
5. [Self-Improvement System](#self-improvement-system)
6. [Skills](#skills)
7. [Hooks](#hooks)
8. [Agents](#agents)
9. [Reference Files](#reference-files)
10. [Customization Guide](#customization-guide)
11. [FAQ / Troubleshooting](#faq--troubleshooting)

## What This Is

A portable, version-controlled configuration for AI coding assistants that:

- **Defines behavioral instructions** so the AI matches your working style, not a generic default
- **Tracks mistakes and learnings** across sessions, graduating patterns into hard constraints
- **Provides modular skills** that load on demand (planning, code review, research, etc.)
- **Runs lifecycle hooks** for session management, context preservation, and failure detection

The goal: your AI assistant improves over time based on your actual working patterns, not just prompt engineering.

## Quick Start

```bash
# Fork this repo, then:
git clone https://github.com/<your-username>/dotfile.git
cd dotfile
./setup.sh
```

`setup.sh` creates symlinks from the repo into `~/.claude/`. Re-run anytime to update.

Settings are **copied** (not symlinked) so local permission changes don't dirty the repo. All other files are symlinked so edits in `~/.claude/` flow back to the repo for version control.

## Directory Structure

```
.
├── CLAUDE.md                  # Behavioral instructions (the "soul" file)
├── persona.md                 # Your technical profile
├── settings.json              # Permissions, hooks, plugins
├── setup.sh                   # Installer (symlinks into ~/.claude/)
├── LEARNINGS.md               # Active learning observations
├── LEARNINGS-ARCHIVE.md       # Graduated learnings (audit trail)
├── MISTAKES.md                # Active mistake patterns (hard constraints)
├── MISTAKES-LOG.md            # Individual mistake entries
├── agents/
│   └── verifier.md            # Adversarial verification agent
├── hooks/
│   ├── session-protocol.sh    # Session start: load context
│   ├── session-end-capture.sh # Session end: capture learnings
│   ├── pre-compact-capture.sh # Before compaction: save context
│   └── iteration-guard.sh     # After tool failure: detect loops
├── reference/
│   ├── investigation-loop.md  # Shared ICD methodology for investigation skills
│   ├── operational-rules.md   # Extracted rules (saves context tokens)
│   └── subagent-prompting-patterns.md  # Reusable prompt patterns for subagents
└── skills/
    ├── audit/                 # Systematic multi-artifact evaluation
    ├── challenge/             # Adversarial + divergent review
    ├── chart-master/          # Data visualization
    ├── code-study/            # Spaced repetition codebase learning
    ├── daily/                 # Daily standup and planning
    ├── data-analyst/          # Data analysis and reporting
    ├── deepdive/              # Deep research with subagents
    ├── improve/               # Self-improvement: analyze + amend
    ├── plan/                  # Implementation planning
    ├── recall/                # Knowledge search across all sources
    ├── reflect/               # Session reflection + persona updates
    ├── research/              # External research with workspace output
    ├── review/                # Multi-angle code review
    └── ui-ux/                 # UI/UX design domain knowledge
```

## Core Configuration

### CLAUDE.md (Behavioral Instructions)

The main configuration file. Defines:

- **Working philosophy**: principles like "understand before changing," "code is the source of truth"
- **Communication style**: tone, verbosity, formatting preferences
- **Worldview & opinions**: your stance on types, testing, patterns, AI collaboration
- **Boundaries**: hard always/never rules
- **Engineering checkpoints**: criteria the AI surfaces when genuinely in tension (extraction, coupling, naming, scope)
- **Verification discipline**: before/during/after phases with adaptive depth based on risk
- **Skill discovery protocol**: how skills are found and invoked via the Capability Manifest
- **Session protocol**: what gets recorded during work (corrections, mistakes, gaps, insights)

The template uses `{placeholder}` markers where you fill in your preferences. Every section explains what it controls so you can decide what matters to you.

### persona.md (Your Technical Profile)

Your technical background, comfort levels per domain, knowledge gaps, and learning history. The AI reads this to:

- Calibrate explanation depth (skip known concepts, slow down on unfamiliar ones)
- Connect new ideas to things you already understand
- Track your growth over time (updated by `/code-study` and the Reflect workflow in `/meta`)

### settings.json (Permissions & Plugins)

Controls what the AI can do without asking. Key design decisions:

- **Allowlist model**: tools are denied by default, explicitly allowed per-command
- **Read-heavy permissions**: git, file system reads, and search tools are pre-approved
- **Write-gated**: destructive operations (force push, hard reset, clean) are denied
- **Commit denied**: commits require explicit approval every time
- **Hook paths use `__HOME__`**: replaced with your actual home directory during setup

## Self-Improvement System

The core feedback loop that makes the AI get better over time.

### How It Works

```
 Session work
     │
     ├─ Mistake happens ──► MISTAKES-LOG.md (individual entry)
     │                           │
     │                     3+ entries in same category?
     │                           │
     │                     ▼ /meta improve escalates
     │                  MISTAKES.md (pattern = hard constraint)
     │                           │
     │                     Applied to CLAUDE.md or skill?
     │                           │
     │                     ▼ Delete from MISTAKES.md
     │                     (git preserves history)
     │
     ├─ Learning observed ──► LEARNINGS.md (active, with confidence)
     │                           │
     │                     confidence: high + 2+ sessions?
     │                           │
     │                     ▼ /meta improve graduates
     │                  LEARNINGS-ARCHIVE.md
     │                     + amendment in CLAUDE.md or skill
     │
     └─ Session ends ──► /meta reflect captures persona updates
```

### LEARNINGS.md / LEARNINGS-ARCHIVE.md

Learnings track observations with confidence levels (`low`, `medium`, `high`) and session counts. When a learning reaches high confidence across multiple sessions, the Improve workflow (`/meta`) graduates it into a CLAUDE.md amendment or skill change. The original entry moves to the archive for audit trail.

### MISTAKES.md / MISTAKES-LOG.md

Individual mistakes are logged with category, scope, severity, and root cause. When a category accumulates 3+ entries across 2+ sessions, the Improve workflow (`/meta`) escalates it to a pattern in MISTAKES.md. Patterns are read on session start as hard constraints. Once the pattern is applied (amendment in CLAUDE.md), it's deleted from MISTAKES.md (git history preserves it).

## Skills

### What Skills Are

Skills are modular capabilities that load on demand. Each skill is a markdown file (`skills/{name}/SKILL.md`) with YAML frontmatter declaring its name, trigger conditions, and allowed tools. They're tool-agnostic: any AI that can read markdown instructions can follow them.

Skills keep CLAUDE.md focused on principles and behavior. Domain knowledge, methodologies, and workflows live in skills instead.

### Available Skills

| Skill | Trigger | What It Does |
|-------|---------|-------------|
| `audit` | Audit, evaluate, or assess a defined scope | ICD loop with rubric-driven evaluation, cross-cutting synthesis, remediation |
| `challenge` | "Poke holes", "what's wrong with", review before committing | Adversarial + divergent review of any deliverable |
| `chart-master` | Chart/diagram/visualization requests | Selects chart type from data shape, renders via Mermaid |
| `code-study` | Understanding a system, educational questions | Explains systems calibrated to your level, spaced repetition scheduling |
| `daily` | Daily standup, planning | Activity summary across tools, next-actions |
| `data-analyst` | Data analysis, statistics, BI | Acquire, clean, transform, analyze, visualize data |
| `deepdive` | Deep research, multi-component investigation | Self-regulating investigation loop with subagents and adversarial teams |
| `improve` | Self-improvement, accumulated entries | Analyzes mistakes/learnings, proposes CLAUDE.md amendments |
| `plan` | Multi-step tasks, implementation planning | Investigation, breakdown, audit hardening, execution-ready output |
| `recall` | "What do I know about X?" | Searches all knowledge sources, ranked by confidence |
| `reflect` | Session end, persona updates | Captures session learnings, updates persona |
| `research` | External research | Web research with workspace output and source attribution |
| `review` | Code review | Multi-angle verification with defect classification |
| `ui-ux` | Design decisions, layout, interaction patterns | Grounded design decisions with trade-off analysis |

### Creating New Skills

Create `skills/{name}/SKILL.md` with this structure:

```yaml
---
name: my-skill
description: One-line description. TRIGGER: when this skill activates.
allowed-tools: Read, Glob, Grep, Edit
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Skill instructions here. Steps, formats, rules.
```

Key frontmatter fields:
- **`name`**: skill identifier (matches directory name)
- **`description`**: trigger conditions and summary (the AI sees this in the skill listing)
- **`allowed-tools`**: which tools the skill can use

Capability routing (which skill hands off to which) is managed in the **CLAUDE.md Capability Manifest**, not in frontmatter. Scope-boundary instructions go in the skill body text.

## Hooks

> Hooks are Claude Code-specific. They use CC's lifecycle events and permission model. If you're adapting this for another tool, these serve as reference for what lifecycle automation to implement.

Hooks run shell commands at specific points in the session lifecycle.

### Session Lifecycle

```
Session start
  └─► session-protocol.sh (load context, check pending items)
        │
      Working...
        │
      Context getting large?
  └─► pre-compact-capture.sh (save context before compaction)
        │
      Tool failure?
  └─► iteration-guard.sh (detect repeated failures, suggest stopping)
        │
      Session ending
  └─► session-end-capture.sh (flag sessions for reflection)
```

### Available Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `session-protocol.sh` | `SessionStart` | Load MISTAKES.md patterns, check pending improvements, set session context |
| `session-end-capture.sh` | `SessionEnd` | Flag the session transcript for the Reflect workflow (`/meta`) to process |
| `pre-compact-capture.sh` | `PreCompact` | Save in-progress context to disk before the AI compresses its memory |
| `iteration-guard.sh` | `PostToolUseFailure` (Bash) | Count consecutive failures; after 2-3, suggest the user stop and rethink |

Hooks are defined in `settings.json` under the `hooks` key. The `Stop` hook runs a prompt-based verification check that ensures code changes were reviewed before the AI stops working.

## Agents

Agents are specialized sub-processes the AI can spawn for specific tasks.

| Agent | Purpose |
|-------|---------|
| `verifier` | Adversarial verification. Reviews deliverables for gaps, incorrect assumptions, and blind spots. Five modes: scanner (default), adversarial, debate, feedback, completeness. Spawned automatically for high-stakes changes (>3 files, irreversible, doubt from self-review). |

## Reference Files

| File | Purpose |
|------|---------|
| `reference/investigation-loop.md` | Shared ICD (Investigate-Challenge-Decide) loop methodology. Used by deepdive, research, plan, and any skill doing multi-step investigation. Defines loop structure, stopping criteria, adversarial team escalation, and workspace formats. |
| `reference/operational-rules.md` | Rules extracted from CLAUDE.md to save context tokens. Covers edit sequencing, intermediate finding persistence, and subagent prompt requirements. Loaded by reference, not included in every prompt. |
| `reference/subagent-prompting-patterns.md` | Reusable prompt construction patterns for spawning subagents. Evidence depth, tool diversity, budget awareness, authority framing, and applicability matrix by task type. |

## Customization Guide

### Filling in Templates

1. **Start with `CLAUDE.md`**. Fill in the `{placeholder}` sections. Each section has guidance on what it controls. Focus on the sections that matter most to you first; you can iterate later.
2. **Fill in `persona.md`**. Your role, comfort levels per technical area, knowledge gaps. This drives how skills like `/code-study` calibrate.
3. **Review `settings.json`**. The defaults are conservative (deny destructive ops, require commit approval). Adjust the allowlist for your toolchain.

### Adding Skills

1. Create `skills/{name}/SKILL.md` with frontmatter (see [Creating New Skills](#creating-new-skills))
2. Re-run `./setup.sh` to symlink the new skill
3. The AI discovers it via the Capability Manifest in the Skill Discovery Protocol

### Adjusting Permissions

Edit `settings.json` directly. Key sections:

- `permissions.allow`: commands the AI can run without asking
- `permissions.deny`: commands that are always blocked
- `hooks`: lifecycle hooks (add your own shell scripts)
- `enabledPlugins`: MCP server plugins

### Extension Points

You can extend this system by:

- **Adding skills**: new `skills/{name}/SKILL.md` directories
- **Adding hooks**: new shell scripts in `hooks/`, registered in `settings.json`
- **Adding agents**: new agent definitions in `agents/`
- **Adding reference files**: extracted knowledge in `reference/` to save context window

The `<!-- PRIVATE:... -->` markers in some skills are fragment injection points. If you maintain a separate overlay repo, you can use these to inject additional content during assembly without modifying the base files.

## FAQ / Troubleshooting

**Q: setup.sh says BLOCKED for a file.**
A: A real file (not a symlink) already exists at that path. Move or delete it manually, then re-run setup.

**Q: Settings changes aren't taking effect.**
A: `settings.json` is copied, not symlinked. Re-run `setup.sh` to re-copy, or edit `~/.claude/settings.json` directly (local changes are intentionally kept separate).

**Q: How do I reset the self-improvement files?**
A: Clear the entries in LEARNINGS.md, MISTAKES-LOG.md, etc. The templates show the expected format with empty sections. Git history preserves everything.

**Q: Can I use this with a non-Claude AI tool?**
A: Skills are tool-agnostic: they're markdown files with structured instructions that any AI can follow. CLAUDE.md and persona.md work as system prompts for any AI that reads project-level config. Hooks and settings.json are Claude Code-specific (they use CC's hook events and permission model), but the lifecycle patterns they implement apply broadly.

**Q: How do I add project-specific configuration?**
A: Create a `CLAUDE.md` in your project root with project-specific instructions. The AI reads both the global `~/.claude/CLAUDE.md` and the project-level one. Same for skills: project-level skills go in `<project>/.claude/skills/`.
