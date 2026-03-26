# Data Analyst Methodology

Detailed data analysis workflow for the /think meta-skill. Parent SKILL.md handles: routing, scope boundaries, learning extraction.

## Modes

Auto-detect from input. If ambiguous, ask.

| Mode | Trigger | Input | Output |
|------|---------|-------|--------|
| **Explore** | Raw data, no specific question | Data file or source | Profile + suggested questions |
| **Analyze** | Specific question + data | Question + data source | Findings with statistical evidence |
| **Report** | "Report on X", multi-metric | Topic + data sources | Structured BI report |
| **Pipeline** | "Clean X", "transform Y" | Data + transformation spec | Transformed data + processing log |

Detection heuristics:
- File/URL with no question -> Explore
- Question word + data reference -> Analyze
- "Report", "summary", multiple metrics -> Report
- "Clean", "transform", "normalize", "join" -> Pipeline

## AQCTAV Pipeline

### 1. Acquire

Ingest data into workspace. Check `~/.claude/analysis/` for related prior work first.

| Source type | Tool | Notes |
|------------|------|-------|
| Local file (CSV, JSON, TSV, SQLite) | Read, Bash (python3) | Copy to raw/ |
| Web API / REST | WebFetch | Save to raw/, note rate limits |
| Jira / Atlassian | Atlassian MCP tools | Query via JQL, save as JSON |
| Web page / table | Playwright MCP or WebFetch | Scrape, save to raw/ |
| SQLite database | Bash (python3 sqlite3) | Query and export to CSV |
| User-provided inline | Write to raw/ | Preserve exactly |

Raw data is immutable. Never modify files in raw/.

### 2. Question

Ensure the question is well-formed before analysis.

- **Explore**: skip (profiling first, questions emerge from data)
- **Analyze/Report**: restate precisely. Check answerability: right fields? sufficient time range? enough data points? If unanswerable, say so and specify what additional data is needed.

### 3. Clean

Profile, then fix.

**Profiling checklist** (via Bash with Python):
- Row/column count, column types
- Missing values per column (count + %)
- Unique values per column (cardinality)
- Numeric: min, max, mean, median, stdev
- Categorical: value distribution (top 10)
- Duplicate detection
- Outlier detection (IQR: below Q1-1.5*IQR or above Q3+1.5*IQR)

**Common cleaning**:

| Issue | Detection | Fix |
|-------|-----------|-----|
| Missing values | None, empty, "N/A", "null" | Drop, fill, or flag (depends on % and analysis) |
| Type mismatches | Mixed types in column | Parse to target, isolate unparseable |
| Duplicates | Exact/key match | Deduplicate by timestamp if available |
| Outliers | IQR | Flag and report (don't auto-remove; may be the finding) |
| Inconsistent categories | "US"/"USA"/"United States" | Normalize via mapping |

Save cleaned data to cleaned/. Save cleaning script to scripts/.

### 4. Transform

Reshape data for the analytical question. Write as Python scripts in scripts/.

Common transforms: aggregate, pivot, join, derive columns (rates, ratios, deltas), bin, window (rolling avg, cumulative), normalize.

**Reproducibility**: every script has input/output paths, clear variable names, comments on business logic.

### 5. Analyze

Match framework to question:

| Question pattern | Framework |
|-----------------|-----------|
| "What does this look like?" | Descriptive profile |
| "How is X changing?" | Trend analysis |
| "How do groups differ?" | Cohort analysis |
| "Where are we losing users?" | Funnel analysis |
| "What drives most of the outcome?" | Pareto analysis |
| "Is A better than B?" | Comparative analysis |
| "Who contributes most?" | Contribution analysis |

**Statistical rigor**: always report sample size (n), central tendency AND spread, effect size for comparisons, confidence intervals where applicable.

### 6. Visualize

Select chart type, then delegate to /create (Chart Master workflow).

| Finding type | Chart | Why |
|-------------|-------|-----|
| Distribution | Bar (histogram) | Frequency, skew, bimodality |
| Trend | Line | Temporal continuity |
| Composition | Pie (max 6 parts) | Part-of-whole |
| Ranking | Horizontal bar | Ordered categories |
| Correlation | Quadrant | Mermaid lacks scatter |
| Flow | Sankey or flowchart | Volume through stages |
| Group comparison | Grouped bar | Side-by-side |
| Timeline | Gantt | Temporal positioning |

Tables for data where exact values matter more than patterns.

## Analytical Frameworks

### Descriptive Profile

1. Shape: rows x columns, types
2. Distribution per numeric: mean, median, stdev, skewness, range, IQR
3. Cardinality per categorical: unique count, top-N, grouping variables
4. Correlations: pairwise for all numeric. Flag |r| > 0.7
5. Missing data map: which columns, %, patterns (MCAR vs systematic)
6. Outlier census: IQR-flagged per column
7. Suggested questions: 3-5 based on data contents

### Trend Analysis

1. Raw values over time
2. Period-over-period deltas and growth rates
3. Moving average (7 for daily, 3-4 for monthly)
4. Seasonality: same-period across years/cycles
5. Trend direction: linear_regression slope + correlation
6. Changepoint detection: significant slope changes
7. Forecast caveat: extrapolation is speculation, state assumptions

### Cohort Analysis

1. Define cohorts by acquisition period
2. Track metric over time-since-acquisition (not calendar time)
3. Build retention table: cohort x period
4. Compare cohorts: newer better? (product improving?)
5. Small cohorts = noisy metrics (flag)

### Funnel Analysis

1. Define stages in order
2. Count at each stage
3. Step-to-step AND cumulative conversion rates
4. Biggest absolute drop-off (not just lowest rate)
5. Segment by dimension for differential drop-off

### Pareto Analysis

1. Rank by contribution (descending)
2. Cumulative percentage
3. Find actual ratio (don't force 80/20)
4. Gini coefficient
5. Validate: is the long tail truly dispensable?

### Comparative Analysis

1. Descriptive stats per group
2. Effect size: Cohen's d (small ~0.2, medium ~0.5, large ~0.8)
3. Confidence interval for difference
4. Simpson's paradox check: does difference hold in subgroups?
5. Practical vs statistical significance

### Contribution Analysis

1. Per-entity metrics
2. Rank by each metric independently
3. Rank divergence: interesting entities rank differently across metrics
4. Concentration: top-N% contribution to total
5. Bias check: would conclusions change without dominant entity?

## Statistical Toolkit

Python stdlib (statistics module):
- Central tendency: mean, fmean, geometric_mean, harmonic_mean
- Median: median, median_low, median_high
- Mode: mode, multimode
- Spread: stdev, pstdev, variance, pvariance
- Relationships: covariance, correlation, linear_regression
- Percentiles: quantiles
- Distributions: NormalDist (CI via inv_cdf)

Other stdlib: csv (DictReader/DictWriter), json, sqlite3, collections.Counter, itertools.groupby, datetime, math, pathlib.

### Key recipes

**Confidence interval** (n >= 30; Z-based, note limitation for smaller samples):
```python
dist = NormalDist(mu=mean(data), sigma=stdev(data)/len(data)**0.5)
ci_lower, ci_upper = dist.inv_cdf(0.025), dist.inv_cdf(0.975)
```

**Outlier detection (IQR)**:
```python
q1, _, q3 = quantiles(data, n=4)
iqr = q3 - q1
outliers = [x for x in data if x < q1 - 1.5*iqr or x > q3 + 1.5*iqr]
```

**Effect size (Cohen's d)**:
```python
pooled_std = ((stdev(a)**2 + stdev(b)**2) / 2) ** 0.5
d = (mean(a) - mean(b)) / pooled_std
```

## Big Data Processing Lifecycle

Conceptual framework: **Collect -> Process -> Store -> Analyse -> Visualise**. Maps to AQCTAV but provides broader perspective.

**Collect** (Acquire step): consider volume (stdlib handles thousands; tens of thousands may need chunked processing; hundreds of thousands -> recommend pandas/polars via `uv`), velocity (one-time -> interactive scripts; recurring -> save for re-execution), variety (structured/semi-structured/unstructured).

**Process** (Clean + Transform): ETL concepts. Data quality dimensions: Completeness, Accuracy, Consistency, Timeliness, Uniqueness.

**Store**: CSV (universal, up to ~100K rows), JSON (nested data), SQLite (multi-table, joins, aggregations, always available). Workspace dirs serve as the analytical store.

**Analyse/Visualise**: see AQCTAV steps 5-6.

**Honest limits**: flag when problem exceeds local processing. >100K rows with complex ops -> pandas/polars. Advanced modeling -> scikit-learn. Real-time -> proper infrastructure. Distributed joins -> database-first.

## Adaptive Dependencies

Default: Python 3 stdlib only (~80% of tasks).

When insufficient:
1. Detect need (>10K rows with complex ops, advanced viz, ML)
2. Check: `python3 -c "import pandas"`
3. Offer: `uv pip install [package]` (never raw pip)
4. If declined: work within limits, note gaps

| Stdlib limit | Package | Trigger |
|-------------|---------|---------|
| Large tabular ops | pandas/polars | >10K rows + groupby/pivot/merge |
| Advanced stats | scipy | Hypothesis tests, non-parametric |
| ML | scikit-learn | Classification, clustering |
| Non-Mermaid viz | matplotlib | Chart types Mermaid can't handle |

## Honesty Rules

1. **State sample sizes.** Every finding includes n.
2. **Correlation is not causation.** Always flag. Explain what evidence would show causation.
3. **Report confidence intervals**, not just point estimates.
4. **Missing data bias.** >10% missing on key variable -> warn. Correlated missingness -> warn loudly.
5. **Simpson's paradox.** Check at least one natural segmentation.
6. **Survivorship bias.** Note what's excluded from the dataset.
7. **Multiple comparisons.** Flag when testing many hypotheses on same data.
8. **Precision theater.** Match output precision to input precision.
9. **Denominator awareness.** Rates require understanding the denominator.

## Workspace

```
~/.claude/analysis/{slug}/
  README.md      # Question, methodology, key findings
  raw/           # Immutable source data
  cleaned/       # Processed data
  scripts/       # Python scripts (reproducible)
  findings/      # Analysis outputs
```

Check `~/.claude/analysis/` for related prior work before starting.

## Output Tiers

**Quick** (Explore default): profile table + 3-5 suggested questions.

**Standard** (Analyze default): finding, evidence (stats + n), caveats, optional chart.

**Comprehensive** (Report default): executive summary, key metrics table, numbered findings with evidence, methodology, caveats, recommendations.

**Pipeline** (Pipeline default): input/output summary, operations list, changes (rows/columns/quality), scripts list, reproducibility command.

## Verification

- Re-run key calculations with different parameters (sensitivity check)
- Cross-reference totals (parts sum to whole? percentages ~100%?)
- Sanity check against domain knowledge
- For reports (>5 metrics): spawn verifier in scanner mode with report + data + scripts
- Reproducibility: can scripts/ be re-run for same results?

## Integration Map

| Capability | Relationship | When |
|------------|-------------|------|
| /create (Chart Master) | Scope boundary (delegate) | Step 6: analyst selects chart type, renderer produces it |
| /think (Recall workflow) | Pre-flight check | Before Acquire: check for prior analyses on this topic |
| /think (Research workflow) | Scope boundary | When data acquisition requires substantial web research |
| /think (Deepdive workflow) | Scope boundary | When analyzing codebase metrics (coverage, complexity, dependencies) |
| verifier agent | Spawn (scanner mode) | Reports with >5 metrics or business-impact findings |
