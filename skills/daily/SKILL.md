---
name: daily
description: Activity summary and next-actions across Jira, Slack, and GitHub. Self, teammates, or team-wide. Tiered depth. TRIGGER: daily summary, standup prep, or team activity overview requests.
allowed-tools: Read, Glob, Grep, Write, Edit, Task, ToolSearch, AskUserQuestion, Bash
provides:
  - activity-summary
scope-boundary:
  - external-research
---

Activity summary and next-actions across Jira, Slack, and GitHub.

**Scope boundary: `external-research`** — see Skill Discovery Protocol manifest in CLAUDE.md for providers. This skill handles activity data from integrated tools; external research is out of scope.

## Invocation

| Command | Target | Range | Depth |
|---------|--------|-------|-------|
| `/daily` | self | yesterday | quick |
| `/daily this week` | self | this week | quick |
| `/daily @name yesterday` | teammate | yesterday | quick |
| `/daily team this week` | team | this week | quick (auto-escalates) |
| `/daily --detailed` | self | yesterday | detailed |
| `/daily next` | self | — | quick, "what's next" only |

Parse arguments from free-text. Defaults: **self**, **yesterday**, **quick**.

## Tiers

### Tier 1 — Quick (default)

- Inline output, no workspace files
- Sequential data collection (single person doesn't warrant subagent overhead)
- 3 source queries + synthesis -> bullet-point summary
- Target: ~15-30 seconds

### Tier 2 — Detailed

- Writes to workspace: `~/.claude/daily/{target}-{date-slug}/` (runtime dir — not persisted across fresh setups, intentionally ephemeral)
- Spawns up to 3 subagents in parallel (one per source: Jira, Slack, GitHub)
- Cross-references: links PRs <-> Jira issues, Slack threads <-> issues
- Timeline reconstruction
- Priority-scored "what's next"

**Auto-escalation triggers** (Tier 1 -> Tier 2):
- Team-wide target (multiple people = too much for inline)
- Date range > 1 week
- User passes `--detailed` (skip the ask — go directly to Tier 2)
- Otherwise: ask before escalating

## Execution

### Step 0: Load tools and verify sources

Load MCP tools dynamically. Each source is independent — if one fails, mark degraded and continue.

```
ToolSearch -> "+atlassian searchJiraIssuesUsingJql"  (loads Jira query tool)
ToolSearch -> "+slack search"                        (loads Slack search tools)
Bash -> "gh auth status 2>&1"                        (verify GitHub CLI)
```

Track which sources loaded successfully. Never fail the whole skill because one source is down.

### Step 1: Parse arguments

Extract from the user's free-text input:
- **Target**: `self` (default) | `@name` (teammate) | `team`
- **Range**: `yesterday` (default) | `today` | `this week` | `last week` | explicit date/range
- **Depth**: `quick` (default) | `--detailed`
- **Mode**: `full` (default) | `next` (what's next only, skip "done")

Compute date boundaries:
- `yesterday`: previous calendar day (start of day to end of day)
- `today`: current calendar day so far
- `this week`: Monday 00:00 to now
- `last week`: previous Monday 00:00 to Sunday 23:59
- Explicit: parse as provided

Use the current date from context. Format dates for each system:
- Jira JQL: `"YYYY-MM-DD"` or `"YYYY/MM/DD HH:mm"`
- Slack search: `after:YYYY-MM-DD before:YYYY-MM-DD`
- GitHub `gh`: `YYYY-MM-DD`

### Step 2: Resolve person identity

**For self:**
- Jira: use `currentUser()` in JQL (no lookup needed)
- Slack: skip lookup — use `from:me` or derive from auth
- GitHub: `gh api user --jq '.login'` or `git config user.name`

**For @name (teammate):**
Resolve across all 3 systems:
1. `lookupJiraAccountId` with the name
2. `slack_search_users` with the name
3. GitHub: infer from convention or ask user

**For team:**
Get team members from Jira sprint board or ask user for the team list. Resolve each member.

### Step 3: Collect data

#### Determine tier

If auto-escalation triggers match (team target, range > 1 week, `--detailed`), go to Tier 2.
Otherwise, proceed with Tier 1 (sequential collection).

#### Tier 1: Sequential collection

Query each available source in sequence. For the `next` mode, skip "what was done" queries.

#### Tier 2: Parallel collection

Spawn up to 3 subagents (Task tool, subagent_type: general-purpose), one per source.

Each subagent prompt must be self-contained (per operational rules):
- Role: "Data collection agent for {source}"
- Task: exact queries to run, exact tool names to use
- Background: target person identity for that system, date range, what to collect
- Deliverable: write findings to `~/.claude/daily/{target}-{date-slug}/{source}.md`
- Format: match across all agents — each file uses the same structure (## What Was Done, ## What's Next, ## Raw Data) so synthesis can read them uniformly

After agents complete, verify each expected file exists. If missing, re-spawn once. If still missing, note the gap.

### Step 3a: Jira queries

**Tool**: `searchJiraIssuesUsingJql` (loaded via ToolSearch)

**"What was done" queries:**

Issues transitioned to Done/Closed:
```
assignee = {id} AND status CHANGED TO Done DURING ("{start}", "{end}")
```

Issues updated (comments, status changes):
```
assignee = {id} AND updated >= "{start}" AND updated <= "{end}"
```

Issues created by user:
```
reporter = {id} AND created >= "{start}" AND created <= "{end}"
```

For self, replace `{id}` with `currentUser()`.

**"What's next" queries:**

Current sprint items (ordered by priority):
```
assignee = {id} AND sprint IN openSprints() AND status != Done ORDER BY priority DESC, rank ASC
```

Overdue items:
```
assignee = {id} AND due < now() AND status != Done
```

Blocked items:
```
assignee = {id} AND status = Blocked
```

**Extract per issue**: key, summary, status, priority, assignee, updated, resolved, due date.

### Step 3b: Slack queries

**Tool**: `slack_search_public_and_private` (loaded via ToolSearch)

**"What was done":**
- Search: `from:@{user}` with date filters (`after:{start} before:{end}`)
- Count messages per channel
- For threads with replies, optionally read top threads via `slack_read_thread` for context

**"What's next":**
- Search: `@{user}` or `to:@{user}` for mentions awaiting response
- Look for unanswered questions directed at the user
- DMs with pending questions (if accessible)

**Fallback**: If Slack MCP unavailable, output: `*Slack data unavailable -- MCP not connected*`

### Step 3c: GitHub queries

**Tool**: `gh` CLI via Bash

**"What was done":**

Merged PRs (fetch all merged, filter by date from JSON output):
```bash
gh pr list --author={user} --state=merged --limit=50 --json number,title,url,mergedAt
```
Then filter results where `mergedAt >= {start}`. The `--search="merged:>="` qualifier does not work with per-repo `gh pr list` — use JSON output and post-filter.

Closed (non-merged) PRs:
```bash
gh pr list --author={user} --state=closed --limit=50 --json number,title,url,closedAt,mergedAt
```
Filter where `closedAt >= {start}` and `mergedAt` is empty (abandoned/closed PRs).

Reviews given (if in a repo context):
```bash
gh api graphql -f query='{ viewer { contributionsCollection(from: "{start}T00:00:00Z") { pullRequestReviewContributions(first: 20) { nodes { pullRequestReview { pullRequest { number title url repository { nameWithOwner } } } } } } } }'
```

**"What's next":**

PRs awaiting your review:
```bash
gh pr list --search="review-requested:{user}" --json number,title,url,author,createdAt
```

Your open PRs (check for stale ones):
```bash
gh pr list --author={user} --state=open --json number,title,url,createdAt,reviewDecision
```

CI status on open PRs:
```bash
gh pr list --author={user} --state=open --json number,title,statusCheckRollup
```
Surface PRs with failing checks as high-priority items.

**Fallback**: If `gh auth status` fails or not in a repo context, output: `*GitHub data unavailable -- gh CLI not authenticated or no repo context*`

### Step 4: Synthesize

#### "What's Next" priority ordering

Combine signals into a priority-ordered list. No numeric scores — just ordered by importance:

1. **Blocked items** — action needed to unblock
2. **Overdue items** — past due date, not done
3. **Due soon** — due within 2 days
4. **Stale PRs** — open > 2 days without activity (review needed or respond to feedback)
5. **Sprint backlog** — highest priority unstarted items in current sprint
6. **Unresolved Slack threads** — mentions/questions awaiting response

#### Cross-referencing (Tier 2 only)

Link related items across sources:
- Match Jira issue keys mentioned in PR titles/descriptions (regex: `[A-Z]+-\d+`)
- Match PR URLs mentioned in Jira issue comments
- Match Jira issue keys mentioned in Slack threads
- Write cross-references to `~/.claude/daily/{target}-{date-slug}/cross-references.md`

### Step 5: Output

#### Quick (Tier 1) — inline

```markdown
## {Person} -- {Date Range}

### Done
- [Jira] PROJ-123: Fixed widget alignment (-> Done)
- [GitHub] PR #456: Merged -- refactor auth middleware
- [Slack] Active in #team-frontend (4 messages), #incidents (2 threads)

### What's Next
1. [Blocked] PROJ-789: Waiting on API team for endpoint spec
2. [Overdue] PROJ-012: Due yesterday -- update migration script
3. [PR Review] PR #345 from @colleague -- requested 3 days ago
4. [Sprint] PROJ-567: Next priority item (High)
```

For `next` mode: skip the "Done" section entirely.

If any source was degraded, note at the bottom:
```
*{Source} data unavailable -- {reason}*
```

#### Detailed (Tier 2) — workspace files

Write to `~/.claude/daily/{target}-{date-slug}/`:

```
README.md              -- synthesized report (written last)
jira.md                -- raw Jira findings
slack.md               -- raw Slack findings
github.md              -- raw GitHub findings
cross-references.md    -- PR<->issue<->thread links
```

README.md format:
```markdown
# {Person} Activity Report -- {Date Range}

**Generated**: {timestamp}
**Sources**: Jira {ok/degraded}, Slack {ok/degraded}, GitHub {ok/degraded}

## Summary

{2-3 sentence executive summary}

## What Was Done

### Jira
{Issue-level detail with status transitions}

### GitHub
{PRs merged, reviews given, with links}

### Slack
{Channel activity summary with key thread contexts}

## What's Next

{Priority-ordered list with full context per item}

## Cross-References

{Links between PRs, issues, and Slack threads}
```

#### Team-wide

Per-person summaries (quick format for each), then a team-level section:

```markdown
## Team -- {Date Range}

### {Person 1}
{quick summary}

### {Person 2}
{quick summary}

### Team-Wide What's Next
{Combined blockers, dependencies, and coordination items}
```

## Graceful degradation

Each source is independent. Track availability from Step 0.

| Source | Degraded when | Behavior |
|--------|--------------|----------|
| Jira | ToolSearch fails to load atlassian tools, or query returns auth error | Note in output, continue with other sources |
| Slack | ToolSearch fails to load slack tools, or search returns error | Note in output, continue with other sources |
| GitHub | `gh auth status` fails, or not in a git repo | Note in output, continue with other sources |

If ALL sources are degraded, report the situation and stop — no point synthesizing nothing.
