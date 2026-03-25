---
name: data-analyst
description: Data analysis, business intelligence, and statistical reasoning. Acquire, clean, transform, analyze, and visualize data from any source. TRIGGER: data analysis, statistical questions, or BI reasoning on provided data.
allowed-tools: Read, Glob, Grep, Bash, Write, Edit, WebSearch, WebFetch, Task, AskUserQuestion, ToolSearch
---

Scope boundary: when you hit the limits of this skill's capability, look up the relevant capability in the CLAUDE.md Capability Manifest and invoke the provider.

Analyze data from any source — files, APIs, databases, web. Profile, clean, transform, analyze, and interpret with statistical rigor. Delegate visualization to `data-visualization` capability.

## When to use

- User invokes `/data-analyst`
- Data needs analysis beyond simple visualization (cleaning, transformation, statistical reasoning)
- Business metrics need interpretation (trends, cohorts, funnels, comparisons)
- Raw data needs profiling before questions can be asked
- Data pipeline needs building (extract, clean, transform, load)

NOT for: `data-visualization` (rendering charts — delegate), `external-research` (general research without data focus), `codebase-investigation` (code structure analysis). Scope boundaries — read manifest for providers.

## Invocation

`/data-analyst [data source, question, or task]`

- `/data-analyst explore sales_data.csv` — Explore mode
- `/data-analyst what's driving the conversion drop in Q4?` — Analyze mode
- `/data-analyst report on team velocity for the last 6 sprints` — Report mode
- `/data-analyst clean and normalize user_events.json` — Pipeline mode
- `/data-analyst` (no args) — ask what to analyze

## Modes

Auto-detect from input. If ambiguous, ask.

| Mode | Trigger | Input | Output |
|------|---------|-------|--------|
| **Explore** | Raw data, no specific question | Data file or source | Data profile + suggested questions |
| **Analyze** | Specific question + data | Question + data source | Findings with statistical evidence |
| **Report** | "Report on X", multi-metric request | Topic + data sources | Structured BI report |
| **Pipeline** | "Clean X", "transform Y", "build pipeline" | Data + transformation spec | Transformed data + processing log |

### Mode detection heuristics

- File/URL with no question → **Explore**
- Question word (what, why, how, which) + data reference → **Analyze**
- "Report", "summary", "dashboard", multiple metrics mentioned → **Report**
- "Clean", "transform", "normalize", "join", "merge", "deduplicate" → **Pipeline**

## AQCTAV Pipeline

Core methodology. Every analysis follows this pipeline — modes determine which steps get emphasis.

### 1. Acquire

Ingest data from the source into the workspace.

**Pre-flight**: Check if `~/.claude/analysis/` has related prior work (via `knowledge-recall` capability). Existing analyses may already have cleaned data or relevant findings.

| Source type | Tool | Notes |
|------------|------|-------|
| Local file (CSV, JSON, TSV, SQLite) | Read, Bash (`python3`) | Copy to `raw/` |
| Web API / REST endpoint | WebFetch | Save response to `raw/`, note rate limits |
| Jira / Atlassian | ToolSearch → Atlassian MCP tools | Query via JQL, save to `raw/` as JSON |
| Web page / table | ToolSearch → Playwright MCP or WebFetch | Scrape structured data, save to `raw/` |
| SQLite database | Bash (`python3 -c "import sqlite3; ..."`) | Query and export to CSV in `raw/` |
| User-provided inline | Write to `raw/` | Preserve exactly as given |

**Acquisition discipline**: Always save raw data before any transformation. Raw data is immutable — never modify files in `raw/`.

### 2. Question

Before analysis, ensure the question is well-formed.

**Explore mode**: Skip — profiling comes first, questions emerge from data.

**Analyze/Report mode**:
- Restate the question precisely. "What's happening with sales?" → "What is the month-over-month revenue change for the last 12 months, and which product lines are contributing to the trend?"
- Check answerability: Does the data contain the fields needed? Is the time range sufficient? Are there enough data points for statistical validity?
- If the question can't be answered with available data, say so and suggest what additional data would be needed.

### 3. Clean

Profile the data, then fix issues.

**Profiling checklist** (run via Bash with Python):
- Row count, column count, column types
- Missing values per column (count + percentage)
- Unique values per column (cardinality)
- Numeric columns: min, max, mean, median, stdev
- Categorical columns: value distribution (top 10)
- Duplicate row detection
- Outlier detection (IQR method: below Q1-1.5*IQR or above Q3+1.5*IQR)

**Common cleaning operations**:

| Issue | Detection | Fix |
|-------|-----------|-----|
| Missing values | `None`, empty string, "N/A", "null" | Drop, fill (mean/median/mode), or flag — depends on % missing and analysis type |
| Type mismatches | Column has mixed types | Parse to target type, isolate unparseable rows |
| Duplicates | Exact row match or key-based | Deduplicate, keeping first/last by timestamp if available |
| Outliers | IQR method | Don't remove automatically — flag and report. Outliers may be the finding |
| Inconsistent categories | "US", "USA", "United States" | Normalize via mapping dict |

Save cleaned data to `cleaned/`. Save the cleaning script to `scripts/`.

### 4. Transform

Reshape data for the analytical question.

**Common transformations** (write as Python scripts in `scripts/`):
- **Aggregate**: Group by dimension, compute sum/mean/count
- **Pivot**: Rows to columns (e.g., monthly metrics as columns)
- **Join**: Merge datasets on shared keys
- **Derive columns**: Computed fields (rates, ratios, deltas, running totals)
- **Bin**: Continuous → categorical (age ranges, revenue tiers)
- **Window**: Rolling averages, cumulative sums, rank within group
- **Normalize**: Scale to 0-1 or z-scores for cross-metric comparison

**Reproducibility requirement**: Every transformation is a Python script in `scripts/` with:
- Input file path, output file path
- Clear variable names (not `df`, `x`, `temp`)
- Comments explaining business logic, not mechanics

### 5. Analyze

Apply the appropriate analytical framework (see Analytical Frameworks section).

**Framework selection** — match to question type:

| Question pattern | Framework |
|-----------------|-----------|
| "What does this data look like?" | Descriptive profile |
| "How is X changing over time?" | Trend analysis |
| "How do different groups of users behave?" | Cohort analysis |
| "Where are we losing users/deals?" | Funnel analysis |
| "What's driving most of the outcome?" | Pareto analysis |
| "Is A better than B?" | Comparative analysis |
| "Who/what is contributing most?" | Contribution analysis |

**Statistical rigor**: Use Python `statistics` module for calculations. Always report:
- Sample size (n)
- Central tendency AND spread (mean +/- stdev, or median + IQR)
- Effect size for comparisons (not just "A > B" — by how much?)
- Confidence intervals where applicable (via NormalDist)

### 6. Visualize

Select chart type based on analytical story, then delegate rendering.

**Chart selection** — analyst perspective (what story to tell):

| Analytical finding | Chart type | Why |
|-------------------|------------|-----|
| Distribution shape | Bar (histogram-style) | Shows frequency, reveals skew/bimodality |
| Trend over time | Line | Continuity implies temporal connection |
| Part-of-whole | Pie (max 6 parts) | Shows composition |
| Ranking | Horizontal bar | Easy to read ordered categories |
| Correlation | Quadrant (qualitative) | Mermaid lacks scatter — quadrant for positioning |
| Flow/conversion | Sankey or flowchart | Shows volume through stages |
| Comparison across groups | Grouped bar | Side-by-side for direct comparison |
| Schedule/timeline | Gantt or timeline | Temporal positioning of events |

**Delegation**: At scope boundary (`data-visualization`), read manifest, present provider. Provide:
- Chart type selected
- Structured data (labels + values)
- Title describing the finding (not the data)

**Tables**: For data best consumed as a table (detailed breakdowns, exact values matter more than patterns), render as markdown table directly — no delegation needed.

## Big Data Processing Lifecycle

Conceptual framework: **Collect -> Process -> Store -> Analyse -> Visualise**. Maps to AQCTAV but provides broader perspective for understanding data systems.

### Collect

Data ingestion patterns. Batch (files, database exports, API pagination) vs stream (webhooks, event logs).

Practical: the Acquire step handles collection. Consider:
- **Volume**: Stdlib handles thousands of rows easily. Tens of thousands may need chunked processing. Hundreds of thousands → recommend pandas/polars via `uv`.
- **Velocity**: One-time analysis vs recurring pipeline? One-time → interactive scripts. Recurring → save scripts for re-execution.
- **Variety**: Structured (CSV, SQL) vs semi-structured (JSON, XML) vs unstructured (text, logs). Stdlib handles all three but with different effort levels.

### Process

ETL concepts applied practically:
- **Extract**: Parse from source format. `csv.DictReader`, `json.load`, `sqlite3.connect`.
- **Transform**: Clean + reshape (AQCTAV steps 3-4).
- **Load**: Write results to analytical store.
- **Data quality dimensions**: Completeness (missing values), Accuracy (correct values), Consistency (no contradictions), Timeliness (current enough), Uniqueness (no duplicates).

### Store

Local analytical storage patterns:
- **CSV**: Universal interchange. Good for tabular data up to ~100K rows. Human-readable.
- **JSON**: Good for nested/hierarchical data. Less efficient for tabular.
- **SQLite**: Best for multi-table analysis, joins, aggregations. Single-file database. Always available via `python3 -c "import sqlite3"`.
- **Workspace files**: The `cleaned/` and `raw/` directories serve as the data store for each analysis.

### Analyse

Statistical and business analysis (AQCTAV step 5). The frameworks below provide the methodology.

### Visualise

Chart selection and delegation (AQCTAV step 6). The analyst selects the chart type based on what the data reveals — the renderer (`data-visualization` capability) handles syntax and presentation.

### Honest limits

Flag when the problem exceeds local processing:
- **Data volume**: >100K rows with complex operations → recommend `uv pip install pandas` or `polars`
- **Statistical complexity**: Advanced modeling (regression beyond linear, clustering, classification) → recommend `uv pip install scikit-learn`
- **Real-time processing**: Not feasible in this context — recommend proper infrastructure
- **Distributed data**: Multiple large sources requiring joins → recommend database-first approach

## Analytical Frameworks

### Descriptive Profile

**When**: First pass on any dataset, or "what does this look like?"

**Method**:
1. Shape: rows x columns, column types
2. Distribution per numeric column: mean, median, stdev, skewness (compare mean vs median), range, IQR
3. Cardinality per categorical column: unique count, top-N values, potential grouping variables
4. Correlations: pairwise `statistics.correlation` for all numeric pairs. Flag |r| > 0.7
5. Missing data map: which columns, what percentage, any patterns (MCAR vs systematic)
6. Outlier census: IQR-flagged values per column
7. Suggested questions: Based on what the data contains, propose 3-5 analytical questions

### Trend Analysis

**When**: Time series data, "how is X changing?"

**Method**:
1. Plot raw values over time (delegate line chart)
2. Period-over-period: compute deltas and growth rates
3. Moving average (window size depends on granularity — 7 for daily, 3-4 for monthly)
4. Seasonality: compare same-period across years/cycles
5. Trend direction: `linear_regression` slope + correlation strength
6. Changepoint detection: where does the slope change significantly?
7. Forecast caveat: extrapolation from trends is speculation — state assumptions explicitly

### Cohort Analysis

**When**: User/entity data with timestamps, "how do groups differ?"

**Method**:
1. Define cohorts by acquisition/creation period (week, month, quarter)
2. Track metric over time-since-acquisition (not calendar time)
3. Build retention table: cohort x period → metric value
4. Compare cohorts: is the product improving (newer cohorts better)?
5. Highlight: cohort size matters — small cohorts produce noisy metrics

### Funnel Analysis

**When**: Sequential conversion steps, "where are we losing people?"

**Method**:
1. Define funnel stages in order
2. Count at each stage
3. Compute step-to-step conversion rate AND cumulative conversion
4. Identify biggest absolute drop-off (not just lowest rate — a 50% drop from 10 users is less important than a 10% drop from 10,000)
5. Segment by dimension if available (device, source, plan) to find differential drop-off

### Pareto Analysis

**When**: Outcome distributions, "what drives most of the result?"

**Method**:
1. Rank entities by contribution to outcome (descending)
2. Compute cumulative percentage
3. Find the 80/20 point (or whatever the actual ratio is — don't force 80/20)
4. Gini coefficient: `1 - 2 * (area under Lorenz curve)` — 0 = perfect equality, 1 = one entity has everything
5. Actionable interpretation: focus efforts on the vital few, but validate that the long tail is truly dispensable

### Comparative Analysis

**When**: Two+ groups or time periods, "is A better than B?"

**Method**:
1. Compute descriptive stats for each group
2. Effect size: difference in means / pooled stdev (Cohen's d). Small ~ 0.2, Medium ~ 0.5, Large ~ 0.8
3. Confidence interval for the difference (via NormalDist, requires sufficient n)
4. Segment comparison: does the difference hold across sub-groups? (Simpson's paradox check)
5. Practical significance: statistically different doesn't mean meaningfully different — interpret in business context

### Contribution Analysis

**When**: Multi-dimensional profiling, "who/what contributes most?"

**Method**:
1. Per-entity metrics: compute key metrics for each entity (person, product, region)
2. Rank by each metric independently
3. Rank divergence: entities that rank very differently across metrics are interesting (high revenue but low margin)
4. Concentration: top-N% contribution to total
5. Bias check: are results driven by a single dominant entity? Would conclusions change if it were excluded?

## Statistical Toolkit

Python 3.14 stdlib — more capable than expected.

### statistics module

```python
from statistics import (
    mean, fmean, geometric_mean, harmonic_mean,  # central tendency
    median, median_low, median_high,              # median variants
    mode, multimode,                               # mode
    stdev, pstdev, variance, pvariance,           # spread
    covariance, correlation, linear_regression,    # relationships
    quantiles,                                     # percentiles
    NormalDist,                                    # distributions + CI
)
```

### Key recipes

**Confidence interval for a mean** (valid for n >= 30; for smaller samples, this Z-based approximation is overconfident — note the limitation when reporting):
```python
dist = NormalDist(mu=mean(data), sigma=stdev(data)/len(data)**0.5)
ci_lower, ci_upper = dist.inv_cdf(0.025), dist.inv_cdf(0.975)  # 95% CI
# Caveat: uses normal approximation. For n < 30, t-distribution would be
# more appropriate but is not available in stdlib. Flag in findings.
```

**Correlation matrix** (all numeric pairs):
```python
for i, col_a in enumerate(numeric_cols):
    for col_b in numeric_cols[i+1:]:
        r = correlation(data[col_a], data[col_b])
        if abs(r) > 0.7: print(f"{col_a} <-> {col_b}: r={r:.3f}")
```

**Linear trend**:
```python
slope, intercept = linear_regression(x_values, y_values)
r = correlation(x_values, y_values)
# slope = change per unit x; r**2 = proportion of variance explained
```

**Outlier detection (IQR)**:
```python
q1, _, q3 = quantiles(data, n=4)  # quartiles
iqr = q3 - q1
outliers = [x for x in data if x < q1 - 1.5*iqr or x > q3 + 1.5*iqr]
```

**Effect size (Cohen's d)**:
```python
pooled_std = ((stdev(group_a)**2 + stdev(group_b)**2) / 2) ** 0.5
cohens_d = (mean(group_a) - mean(group_b)) / pooled_std
```

### Other stdlib tools

- `csv`: `DictReader`/`DictWriter` for tabular data
- `json`: nested data, API responses
- `sqlite3`: SQL queries on local databases (powerful for joins, aggregations, window functions)
- `collections.Counter`: frequency distributions
- `itertools.groupby`: grouped operations (sort first)
- `datetime`: time parsing, period arithmetic
- `math`: `log`, `exp`, `sqrt`, `isnan`
- `pathlib`: file management in workspace

## Adaptive Dependency Management

**Default**: Python 3.14 stdlib only. Covers ~80% of analytical tasks.

**When stdlib is insufficient**:
1. Detect: task requires DataFrame operations on >10K rows, advanced visualization, ML, or complex stats
2. Check availability: `python3 -c "import pandas"` (don't assume installed)
3. If not available, offer: "This analysis would benefit from [pandas/polars/scikit-learn]. Install via `uv pip install [package]`?"
4. **Never** use raw `pip`. Always `uv pip install`.
5. If user declines, work within stdlib limits and note what couldn't be done.

**Common escalation points**:

| Stdlib limit | Package | Trigger |
|-------------|---------|---------|
| Large tabular operations | `pandas` or `polars` | >10K rows with groupby/pivot/merge |
| Advanced statistics | `scipy` | Hypothesis tests, non-parametric tests, distributions beyond normal |
| Machine learning | `scikit-learn` | Classification, clustering, regression beyond linear |
| Data visualization (non-Mermaid) | `matplotlib` | When Mermaid can't represent the chart type faithfully |

## Honesty and Integrity

Analytical discipline — non-negotiable rules.

1. **State sample sizes.** Every finding includes n. "Revenue increased 40%" means nothing without knowing if that's 5 transactions or 5,000.
2. **Correlation is not causation.** Always flag. If the analysis suggests causation, explain what additional evidence would be needed (controlled experiment, temporal precedence, mechanism).
3. **Report confidence intervals**, not just point estimates. A mean of $500 with CI [$100, $900] tells a very different story than mean $500 with CI [$480, $520].
4. **Missing data bias.** If >10% of data is missing for a key variable, warn that conclusions may not generalize. If missingness correlates with the outcome, warn loudly.
5. **Simpson's paradox awareness.** When an aggregate trend reverses within subgroups, flag it. Always check at least one natural segmentation.
6. **Survivorship bias.** If the dataset only contains "survivors" (current users, completed deals, active products), note what's excluded and how that might skew findings.
7. **Multiple comparisons.** When testing many hypotheses on the same data, some will be "significant" by chance. Flag when doing exploratory analysis on many variables.
8. **Precision theater.** Don't report "$1,234,567.89 in revenue" when the input data has $1K granularity. Match output precision to input precision.
9. **Denominator awareness.** Rates and percentages require understanding the denominator. "50% increase" from 2 to 3 is not the same as from 2,000 to 3,000.

## Workspace

Each analysis gets a workspace at `~/.claude/analysis/{slug}/`.

```
~/.claude/analysis/{slug}/
  README.md          # Question, methodology, key findings
  raw/               # Immutable source data
  cleaned/           # Processed data (after cleaning)
  scripts/           # Python scripts (reproducible transforms)
  findings/          # Analysis outputs (tables, stats, interpretations)
```

**README.md** structure:
```markdown
# {Analysis Title}

**Question**: [precise analytical question]
**Data sources**: [list with acquisition dates]
**Date**: [analysis date]
**Status**: [in-progress | complete]

## Key Findings
[numbered findings with evidence references]

## Methodology
[frameworks used, key decisions, limitations]

## Caveats
[sample size, missing data, bias risks]
```

**Workspace lifecycle**:
- Create at analysis start (Acquire step)
- Persist after completion — analyses may be revisited
- Before starting, check if `~/.claude/analysis/` has related prior work (via `knowledge-recall` capability)

## Output Tiers

Adapt output depth to the request.

### Quick (Explore mode default)

Data profile table (rows, columns, types, missing %, key stats) + 3-5 suggested questions.

### Standard (Analyze mode default)

```
Finding: [one-sentence answer]
Evidence: [key statistics with sample sizes]
Caveats: [limitations, confidence, what could change the conclusion]
[Optional: chart delegation if visual would aid understanding]
```

### Comprehensive (Report mode default)

```
## Executive Summary
[2-3 sentences: what, so what, now what]

## Key Metrics
[table of metrics with period-over-period comparisons]

## Findings
[numbered findings, each with evidence and confidence]

## Methodology
[data sources, frameworks used, analytical choices]

## Caveats and Limitations
[sample sizes, missing data, bias risks, what was NOT analyzed]

## Recommendations
[actionable next steps based on findings]
```

### Pipeline (Pipeline mode default)

```
## Pipeline Summary
Input: [source file/format, row count]
Output: [destination file/format, row count]
Operations: [numbered list of transformations applied]

## Changes
- Rows: [input count] -> [output count] ([dropped/added] reason)
- Columns: [input count] -> [output count] ([derived/removed] list)
- Data quality: [issues found and how each was handled]

## Scripts
[list of scripts in scripts/ with one-line description of each]

## Reproducibility
Run: `python3 scripts/[pipeline_script].py`
```

## Verification

### Self-verification (all modes)

- Re-run key calculations with different parameters to check sensitivity
- Cross-reference totals (do parts sum to whole? do percentages sum to ~100%?)
- Sanity check: does this finding pass the "smell test" given domain knowledge?

### Verifier delegation (Report mode, or >5 metrics)

Spawn verifier agent (`adversarial-verification` capability) in scanner mode:
- Input: the report + raw data + scripts
- Do NOT include analytical reasoning (CoVe isolation)
- Checks: arithmetic accuracy, methodology appropriateness, missing caveats, misleading framing

### Reproducibility check

- Can someone re-run `scripts/` and get the same results?
- Are all data sources documented in README.md?
- Are cleaning decisions explained (why fill vs drop, why this outlier threshold)?

## Integration Map

| Capability | Relationship | When |
|------------|-------------|------|
| `data-visualization` | Scope boundary (delegate) | Step 6 — analyst selects chart type, renderer produces it |
| `knowledge-recall` | Pre-flight check | Before Acquire — check for prior analyses on this topic |
| `external-research` | Scope boundary | When data acquisition requires substantial web research |
| `codebase-investigation` | Scope boundary | When analyzing codebase metrics (test coverage, complexity, dependencies) |
| `adversarial-verification` | Spawn (scanner mode) | Reports with >5 metrics, or when findings have business impact |
| Analysis workspace | Write to | Every analysis — `~/.claude/analysis/{slug}/` |
