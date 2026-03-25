# Ship Methodology

Detailed git-to-PR pipeline for the /work meta-skill. Parent SKILL.md handles: routing, ICD framework, disciplines.

## Pipeline Stages

Each branch is in exactly one stage. Detection is deterministic:

| Stage | Condition | Action |
|-------|-----------|--------|
| Uncommitted | `git status --short` shows changes | Stage, commit |
| Unpushed | No upstream or `git log @{u}..HEAD` shows commits | Push with `-u origin` |
| No PR | `gh pr view` fails | Create PR via `gh pr create` |
| Shipped | PR exists and is open | Report, skip |

Stages are sequential: uncommitted goes through all three action stages.

## Arguments

```
/work ship                           # Ship CWD branch
/work ship <path>                    # Ship branch at worktree path
/work ship <path1> <path2> ...       # Ship multiple worktrees
/work ship --scan <directory>        # Ship all worktrees in directory
```

## Overrides

| Level | How |
|-------|-----|
| Global | Arguments to invocation (`--reviewer alice --milestone v2.1`) |
| Per-target | Prompted during PR creation if targets differ |
| Inherited | Detected from first PR, offered to remaining |

Flags (all optional): `--base`, `--reviewer`, `--milestone`, `--label`, `--template`, `--dry-run`.

## Steps

### 1. Resolve targets

- No args: CWD is target. Verify git repo.
- Paths: each path is a worktree/repo. Verify exists + git.
- `--scan <dir>`: subdirs containing `.git`.

Record per target: absolute path, branch name, remote URL, owner/repo.

### 2. Detect state

For each target, in parallel:
```bash
git status --short
git log @{u}..HEAD --oneline 2>/dev/null
git rev-parse --abbrev-ref @{u} 2>/dev/null
gh pr view --json url,number,title,state 2>/dev/null
```

Classify into pipeline stage. A branch can need multiple actions.

### 3. Plan

Show summary table: Branch, Repo, Stage, Actions. Single target: inline. Multiple: full table. All shipped: report and stop. `--dry-run`: show plan and stop.

### 4. Confirm and execute

Process sequentially (per-branch confirmation).

#### 4a. Commit (if uncommitted)

- Read `git diff` and `git diff --cached`.
- Infer ticket from branch name (strip prefix: feature/, fix/, hotfix/, spike/).
- Propose commit message from: ticket, diff content, existing style (`git log --oneline -5` on base).
- Confirm via AskUserQuestion: use message, edit, or skip.
- Stage specific files (`git add <files>`, never `git add .`). Commit.

**Batch (3+ targets)**: after first confirmation, detect pattern, offer to apply.

#### 4b. Push (if unpushed)

- `git push -u origin <branch>`. No confirmation (reversible).
- Failure: report and skip. Never force-push.

#### 4c. Create PR (if no PR)

- Title: most recent commit message.
- Body: template system (see Templates).
- Apply overrides.
- Confirm via AskUserQuestion: create, edit, or skip.
- Create via `gh pr create`. Report URL.

**Batch (3+ targets)**: after first PR, detect shared overrides, offer to apply.

### 5. Summary

Results table: Branch, Actions Taken, Result (PR link or failure reason).

## Templates

Resolution order:
1. `--template <name>` argument
2. Auto-detect `.github/PULL_REQUEST_TEMPLATE.md`
3. Built-in default

Built-in:
```
## Summary
{description}

## Changes
{file_list}
```

Variables: `{ticket}`, `{description}`, `{file_list}`, `{commit_messages}`.

Custom templates: `~/.claude/config/ship-templates/<key>.md` with `{variable}` placeholders.

## Safety

- **Never force-push.** Report and skip on failure.
- **Never push to main/master.** Refuse with warning.
- **Never `git add .` or `git add -A`.** Stage specific files.
- **Never commit secrets.** Skip `.env`, `credentials.*`, `*.key`, `*.pem`, `secrets.*`. Warn if detected.
- **Confirm before irreversible.** Commits and PRs get confirmation. Pushes don't (reversible).

## Edge Cases

| Situation | Handling |
|-----------|----------|
| Merge conflicts | Detect, report "resolve first", skip |
| Behind remote | Push fails, report "pull/rebase first", skip |
| No `gh` CLI | Detect early, warn PR creation skipped |
| Detached HEAD | Report "checkout a branch", skip |
| Multiple remotes | Use `origin`, or first if no origin. Log which. |
