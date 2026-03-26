#!/bin/bash
# PreCompact hook: captures learnings + detects orphaned investigations before compaction

# Check for orphaned investigations (STATE.md without README.md)
ORPHANS=""
for state in "$HOME"/.claude/investigations/*/STATE.md "$HOME"/.claude/investigations/*/*/STATE.md; do
  [ -f "$state" ] || continue
  dir=$(dirname "$state")
  if [ ! -f "$dir/README.md" ]; then
    slug=$(basename "$dir")
    status=$(sed -n 's/^\*\*Status\*\*:[[:space:]]*//p' "$state" 2>/dev/null | head -1)
    [ "$status" = "stopped" ] && continue  # stopped without README is unusual but not orphaned
    ORPHANS="${ORPHANS:+$ORPHANS, }${slug} (${status:-unknown})"
  fi
done

ORPHAN_MSG=""
if [ -n "$ORPHANS" ]; then
  ORPHAN_MSG=" ORPHANED INVESTIGATIONS: ${ORPHANS}. These have STATE.md but no README.md. Before compaction: (1) complete them (write README.md), (2) update Status to paused in STATE.md, or (3) note them for next session."
fi

cat << EOF
{
  "systemMessage": "MANDATORY PRE-COMPACTION STEP: Context is about to be compacted. You MUST review the session for unrecorded mistakes, learnings, and persona-relevant observations and append them to ~/.claude/MISTAKES-LOG.md and ~/.claude/LEARNINGS.md BEFORE compaction proceeds. Use the entry formats defined in each file's preamble. Include scope and severity (for mistakes). For persona observations (knowledge level changes, gaps surfaced), note them for the Reflect workflow (/meta) to process (do not update persona.md directly). If nothing new to record, confirm explicitly. Do not skip this step.${ORPHAN_MSG}"
}
EOF
exit 0
