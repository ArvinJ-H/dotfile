# Operational Rules

Rules moved from Working Philosophy for context savings. Still active constraints.

- **Sequence edits on the same file.** Parallel Edit calls on one file cause transient invalid states that trigger hooks between edits. Edit the same file sequentially; parallelize across different files.
- **Persist intermediate findings.** For any multi-agent task or research spanning multiple steps, save findings to disk incrementally — don't hold everything in context. Applies regardless of which skill is active. Follow research workspace conventions (see /think Research workflow) when creating research artifacts.
- **Subagent prompts are self-contained.** No CLAUDE.md, no history, no prior context. Every prompt needs: role, complete task, all background, explicit deliverable format. Match format across agents when outputs will be synthesized. Include persona when the consumer lacks a soul; skip when one exists. For prompt construction patterns (evidence depth, tool diversity, budget awareness, authority framing), see `~/.claude/reference/subagent-prompting-patterns.md`.
- **Dotfiles-first for persistent `~/.claude/` content.** Two categories of `~/.claude/` dirs:
  - **Persistent** (symlinked via setup.sh): agents, audit, hooks, investigations, reference, skills, tools. Must live in `dotfiles/public/` (general) or `dotfiles/private/` (project-specific) with symlink created by `setup.sh`. Creating a real dir here means it's lost on fresh setup.
  - **Runtime** (intentionally local): backups, cache, chrome, debug, downloads, file-history, ide, paste-cache, plans, plugins, projects, session-env, shell-snapshots, tasks, teams, telemetry, todos.
  When creating a new top-level dir under `~/.claude/` for persistent content: create in `dotfiles/public/{dir}` or `dotfiles/private/{dir}`, add to `setup.sh` symlink + verify sections. Then run `./setup.sh symlinks` to activate.
