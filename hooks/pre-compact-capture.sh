#!/bin/bash
# PreCompact hook: captures learnings before context is compacted
# Fires before long conversations are compressed, ensuring nothing is lost

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "additionalContext": "MANDATORY PRE-COMPACTION STEP: Context is about to be compacted. You MUST review the session for unrecorded mistakes, learnings, and persona-relevant observations (knowledge level changes, gaps surfaced) and append them to ~/.claude/MISTAKES-LOG.md, ~/.claude/LEARNINGS.md, and ~/.claude/persona.md BEFORE compaction proceeds. Use the entry formats defined in each file's preamble. Include scope and severity (for mistakes). Use /reflect's update rules: auto for Technical Knowledge and Knowledge Gaps, explicit approval for Working Style and Identity. If nothing new to record, confirm explicitly. Do not skip this step."
  }
}
EOF
exit 0
