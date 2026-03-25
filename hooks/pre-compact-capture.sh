#!/bin/bash
# PreCompact hook: captures learnings before context is compacted
# Fires before long conversations are compressed, ensuring nothing is lost

cat << 'EOF'
{
  "systemMessage": "MANDATORY PRE-COMPACTION STEP: Context is about to be compacted. You MUST review the session for unrecorded mistakes, learnings, and persona-relevant observations and append them to ~/.claude/MISTAKES-LOG.md and ~/.claude/LEARNINGS.md BEFORE compaction proceeds. Use the entry formats defined in each file's preamble. Include scope and severity (for mistakes). For persona observations (knowledge level changes, gaps surfaced), note them for the Reflect workflow (/meta) to process (do not update persona.md directly). If nothing new to record, confirm explicitly. Do not skip this step."
}
EOF
exit 0
