---
name: chart-master
description: Data visualization using Mermaid diagrams. Auto-selects chart type from data shape. Three modes — direct data, research-backed, and codebase architecture. TRIGGER: chart, diagram, or visualization requests.
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch, Task, AskUserQuestion, ToolSearch
provides:
  - data-visualization
scope-boundary:
  - external-research
  - codebase-investigation
---

Visualize data as Mermaid diagrams. Given raw data, a research question, or a codebase architecture question, produce the most appropriate chart with accurate syntax and honest representation.

## When to use

- User invokes `/chart`
- Data needs visualization (tables, metrics, comparisons, trends)
- Research findings would benefit from a visual summary
- Codebase architecture needs a structural diagram

NOT for: `external-research`, `codebase-investigation` (scope boundaries — read manifest for providers), general diagrams unrelated to data (just write Mermaid directly).

## Invocation

`/chart [data, topic, or question]`

- `/chart revenue by quarter: Q1 $2M, Q2 $3.1M, Q3 $2.8M, Q4 $4.2M` — direct mode
- `/chart how has TypeScript adoption changed over 5 years` — research mode
- `/chart show the module dependency structure of src/` — codebase mode
- `/chart` (no args) — ask what to visualize

## Modes

Auto-detect from input. If ambiguous, ask.

| Mode | Trigger | Data source | Tools used |
|------|---------|-------------|------------|
| **Direct** | Structured data provided (CSV, JSON, table, list, inline values) | User input | — |
| **Research** | Topic or question requiring external data | WebSearch, WebFetch | Web tools |
| **Codebase** | Question about code structure, dependencies, architecture | Glob, Grep, Read | Codebase tools |

## Pre-flight

Before generating any chart:

1. **Parse the intent.** What is the user trying to *understand* — not just what data they gave. A list of quarterly revenues implies a trend question, not a part-of-whole question.
2. **Assess data completeness.** Is there enough data for a meaningful chart? 2 data points don't make a trend. Flag insufficient data rather than charting noise.

## Chart type selection

Select based on **communicative intent** first, data shape second. This is the core domain-expert discipline — the same data can tell different stories depending on chart choice.

### Intent-first selection

| What you want to show | Best Mermaid chart | When to use alternative |
|------------------------|--------------------|------------------------|
| **Ranking / comparison** | `xychart` (bar) | >12 categories → horizontal bars |
| **Composition / part-of-whole** | `pie` | >6 slices → switch to bar. Pie is only valid when parts sum to a meaningful whole |
| **Trend over time** | `xychart` (line) | Dual lines for comparison. >1 series works |
| **Trend + magnitude** | `xychart` (bar + line overlay) | When both absolute values and trend matter |
| **Process / workflow** | `flowchart` | Decision trees, pipelines, request flows |
| **Interactions / API calls** | `sequenceDiagram` | Temporal ordering of messages between actors |
| **Entity relationships** | `erDiagram` | Database schemas, domain models |
| **State machine** | `stateDiagram-v2` | Lifecycle of an entity through states |
| **Hierarchy / breakdown** | `mindmap` | Taxonomies, org structures, feature breakdowns |
| **Chronological events** | `timeline` | Milestones, release history, project phases |
| **2D qualitative positioning** | `quadrantChart` | Priority matrices, effort-impact, risk assessment |
| **Flow quantities** | `sankey` | Budget flows, traffic sources, conversion funnels |
| **Project schedule** | `gantt` | Task timelines with dependencies |

### Mermaid limitations

Be honest about what Mermaid **cannot** do well. When the ideal chart type isn't available:

| Ideal chart | Mermaid gap | Best alternative | What's lost |
|-------------|-----------|-----------------|-------------|
| Scatter plot | Not supported | `quadrantChart` for qualitative positioning, or note the limitation | Precise numeric correlation |
| Heatmap | Not supported | Table in markdown + note | Density visualization |
| Box plot | Not supported | Describe distribution in text | Statistical spread |
| Treemap | Not supported | `mindmap` for hierarchy | Area-proportional sizing |
| Histogram | Not supported | `xychart` (bar) with binned data | Continuous distribution feel |
| Stacked bar | Not natively supported | Multiple `xychart` bars side-by-side, or note limitation | Part-of-whole within comparison |

**Never force data into a wrong chart type.** If Mermaid can't represent the data faithfully, say so and provide the data in the best available format (table, text summary) alongside the closest Mermaid approximation.

## Mermaid syntax reference

Accurate syntax for chart generation. Consult this — don't hallucinate syntax.

### xychart (bar + line)

```
xychart
    title "Chart Title"
    x-axis [Label1, Label2, Label3]
    y-axis "Y Label" 0 --> 100
    bar [10, 20, 30]
    line [12, 18, 28]
```

- `xychart horizontal` for horizontal orientation
- x-axis supports categorical labels `[A, B, C]` or numeric range `min --> max`
- y-axis is numeric only
- Multiple `bar` and `line` series allowed

### pie

```
pie title "Chart Title"
    "Slice A" : 40
    "Slice B" : 35
    "Slice C" : 25
```

### flowchart

```
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action]
    B -->|No| D[Other]
```

- Directions: `TD` (top-down), `LR` (left-right), `BT`, `RL`
- Shapes: `[]` rectangle, `{}` diamond, `()` rounded, `([])` stadium, `[[]]` subroutine

### sequenceDiagram

```
sequenceDiagram
    participant A as Service A
    participant B as Service B
    A->>B: Request
    B-->>A: Response
```

### erDiagram

```
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
```

### stateDiagram-v2

```
stateDiagram-v2
    [*] --> Draft
    Draft --> Review
    Review --> Approved
    Review --> Draft : Rejected
    Approved --> [*]
```

### mindmap

```
mindmap
    root((Central Topic))
        Branch A
            Leaf 1
            Leaf 2
        Branch B
            Leaf 3
```

### timeline

```
timeline
    title Project History
    2023 : Alpha release
    2024 : Beta launch
         : Public API
    2025 : v1.0
```

### quadrantChart

```
quadrantChart
    title Priority Matrix
    x-axis Low Effort --> High Effort
    y-axis Low Impact --> High Impact
    quadrant-1 Do First
    quadrant-2 Schedule
    quadrant-3 Delegate
    quadrant-4 Eliminate
    Item A: [0.8, 0.9]
    Item B: [0.3, 0.7]
```

### sankey

```
sankey
    Source A,Target X,50
    Source A,Target Y,30
    Source B,Target X,20
```

- CSV format: source, target, value
- Experimental (v10.3.0+)

### gantt

```
gantt
    title Project Schedule
    dateFormat YYYY-MM-DD
    section Phase 1
        Task A :a1, 2024-01-01, 30d
        Task B :after a1, 20d
```

## Rendering conventions

Domain-expert heuristics, not decoration rules:

1. **Title every chart.** A chart without a title is an unlabeled diagram.
2. **Clean labels.** Human-readable — no `snake_case` keys, no internal IDs. "Q1 2024" not "q1_2024".
3. **Honest axes.** Bar charts start at zero unless there's a documented reason not to. Truncated axes exaggerate differences.
4. **Color is data.** Only add styling when it encodes information (highlighting an outlier, distinguishing series). No decorative color.
5. **Pie chart discipline.** Max 6 slices. Parts must sum to a meaningful 100%. No pie charts for ranking — use bars.
6. **One chart, one message.** Each chart should answer one question. If data warrants multiple views, offer them as options — don't auto-generate a dashboard.
7. **Label directly.** Prefer labels on the chart over separate legends when Mermaid supports it.

## Mode: Research

When gathering data to visualize:

1. **Pre-flight knowledge check.** Existing research workspaces may already have the data.
2. **Lightweight search.** Use WebSearch to find chartable data — statistics, rankings, time series, comparisons. Focus on numbers, not narrative.
3. **Source credibility.** Follow research source tiers:
   - Tier 1-2 (official docs, reputable publications) → use directly
   - Tier 3 (community — high-vote SO, official forums) → use with attribution, note as `[community source]`
   - Tier 4 (anecdotal — blog posts, low-vote posts) → flag as `[approximate — unverified source]`
4. **Attribution.** Below every research-mode chart, cite the data source with URL and date.
5. **Scope boundary.** If the research question requires more than 2-3 searches to get good data, at scope boundary (`external-research`), read manifest, present providers via AskUserQuestion.
6. **Persist if substantial.** If research mode produces >3 data points from multiple sources, write findings to `~/.claude/investigations/{topic-slug}/chart-data.md`. If the directory already exists from a prior research session, read existing files first — build on previous work, don't overwrite it.

## Mode: Codebase

When visualizing code structure:

1. **Explore systematically.** Use Glob for file patterns, Grep for imports/dependencies, Read for module structures.
2. **Common codebase visualizations:**
   - Module dependency graph → `flowchart`
   - API request flow → `sequenceDiagram`
   - Database schema → `erDiagram`
   - State machine / lifecycle → `stateDiagram-v2`
   - Feature / module breakdown → `mindmap`
   - Release / migration timeline → `timeline`
3. **Scope boundary.** If understanding the architecture requires deep investigation across many files, at scope boundary (`codebase-investigation`), read manifest, present providers via AskUserQuestion.
4. **Accuracy over completeness.** Only chart what you've verified in the code. Don't infer connections that aren't in the source.

## Verification

After generating complex charts (research-mode, codebase-mode, or >5 data points):

Spawn the verifier agent via Task tool (`subagent_type: "verifier"`). The prompt must include:
- **Mode**: `scanner` (explicit — the verifier defaults to scanner but be explicit)
- **Deliverable**: the generated Mermaid code block
- **Source material**: the raw data (numbers, search results, or code references) used to generate the chart
- Do NOT include the chart type selection reasoning (CoVe isolation — verifier assesses independently)

**What the verifier checks:**
- Data accuracy — do the chart values match the source data?
- Chart type appropriateness — does this chart type serve the communicative intent?
- Misleading patterns — truncated axes, wrong proportions, missing context?
- Mermaid syntax — will this actually render correctly?

Skip verification for simple direct-mode charts with <5 data points where the mapping is trivial.

## Output format

```
[Brief context: what this chart shows and why this chart type was chosen — 1-2 sentences]

```mermaid
[chart code]
``` (end code block)

[For research mode: source attribution with URL and date]
[For codebase mode: file references used]
[If alternative views exist: "Other views worth considering: [type] for [different question about this data]"]
```

## Integration map

| Capability | Relationship | When |
|------------|-------------|------|
| `knowledge-recall` | Variable process | Before research mode — check existing knowledge |
| `external-research` | Scope boundary | When data gathering exceeds lightweight search scope |
| `codebase-investigation` | Scope boundary | When codebase exploration exceeds chart-master's scope |
| `adversarial-verification` | Spawn (scanner mode) | After complex charts — data accuracy + misleading pattern check |
| Research workspace | Write to | When research mode produces substantial reusable data |
