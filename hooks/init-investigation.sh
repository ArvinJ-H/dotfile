#!/bin/bash
# init-investigation.sh
# Creates investigation workspace with pre-populated STATE.md template.
# Called by ICD agents at start. Idempotent (exits if workspace exists).
#
# Usage: init-investigation.sh {area} {slug} [--audit]
# Areas: tiny/, personal/, methodology/, a11y/, ai-literacy/, external/, work/

AREA="${1:?Usage: init-investigation.sh {area} {slug} [--audit]}"
SLUG="${2:?Usage: init-investigation.sh {area} {slug} [--audit]}"
AUDIT=false
[ "${3:-}" = "--audit" ] && AUDIT=true

WORKSPACE="$HOME/.claude/investigations/${AREA}/${SLUG}"

# Idempotent: if workspace exists, report and exit
if [ -d "$WORKSPACE" ] && [ -f "$WORKSPACE/STATE.md" ]; then
  echo "Workspace exists: $WORKSPACE. Resume from STATE.md." >&2
  echo "$WORKSPACE"
  exit 0
fi

mkdir -p "$WORKSPACE"
TODAY=$(date +%Y-%m-%d)

cat > "$WORKSPACE/STATE.md" << EOF
# Investigation: ${SLUG}

**Date started**: ${TODAY}
**Status**: iterating
**Current iteration**: 1

## Scope

{FILL: What this investigation covers. Be specific about boundaries.}

## Findings

{No findings yet.}

## Confidence History

| Iteration | Focus | Likelihood | Confidence | Delta | Sources added |
|-----------|-------|------------|------------|-------|---------------|

## Active Gaps

{FILL: Initial questions to investigate.}

## Iteration Log

## Stop Challenge Record
EOF

if [ "$AUDIT" = true ]; then
  cat > "$WORKSPACE/TRACKER.md" << EOF
# Audit: ${SLUG}

**Date**: ${TODAY}
**Status**: iterating

## Scope Inventory

| # | Artifact | Type | Surface | Deep | Remediation |
|---|----------|------|---------|------|-------------|

## Findings

## Cross-Cutting Patterns

## Reclassifications

| Iteration | Trigger | Change | Reason |
|-----------|---------|--------|--------|

## Learnings Extracted
EOF
fi

echo "$WORKSPACE"
