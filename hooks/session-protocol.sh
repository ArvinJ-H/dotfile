#!/bin/bash
# SessionStart hook: session protocol + pending reflection check + config validation
# Fails gracefully (exit 0) like other hooks in this workspace

PENDING_FILE="$HOME/.claude/pending-reflect"
PENDING_MSG=""

if [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
  ENTRY_COUNT=$(wc -l < "$PENDING_FILE" | tr -d ' ')
  PENDING_MSG=" PENDING REFLECTIONS: $ENTRY_COUNT previous session(s) flagged for learning capture. Run /meta reflect to process, then the file will be cleared. Transcripts: $(cat "$PENDING_FILE")"
fi

# Validate hook script paths in settings.json
SETTINGS_FILE="$HOME/.claude/settings.json"
STALE_HOOKS=""

if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
  HOOK_PATHS=$(jq -r '.. | objects | select(.type == "command") | .command // empty' "$SETTINGS_FILE" 2>/dev/null)
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    # Skip paths with variable substitution (plugin paths like ${CLAUDE_PLUGIN_ROOT})
    echo "$path" | grep -q '^\$\|^\${' && continue
    if [ ! -f "$path" ]; then
      STALE_HOOKS="${STALE_HOOKS} WARNING: Hook script not found: $path."
    fi
  done <<< "$HOOK_PATHS"
fi

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Session protocol: Skim ~/.claude/MISTAKES.md (Patterns section), ~/.claude/LEARNINGS.md (high-confidence entries), and ~/.claude/persona.md (Technical Knowledge comfort levels and Knowledge Gaps) before starting work.${PENDING_MSG}${STALE_HOOKS}"
  }
}
EOF
exit 0
