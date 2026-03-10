#!/bin/bash
# PostToolUseFailure hook: tracks consecutive Bash failures per session.
# After 3 consecutive failures with the same command signature, injects
# a stop-and-rethink reminder. Resets when a different command is tried.
# Fails gracefully (exit 0) like other hooks in this workspace.

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract session ID and command from hook input
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# If we can't parse input, pass through silently
if [ -z "$SESSION_ID" ] || [ -z "$COMMAND" ]; then
  exit 0
fi

# Extract command "signature" — first word (yarn, make, npx, etc.)
SIGNATURE=$(echo "$COMMAND" | awk '{print $1}' | sed 's|.*/||')

TRACKER="/tmp/claude-failures-${SESSION_ID}"

# Read current state
PREV_SIGNATURE=""
COUNT=0
if [ -f "$TRACKER" ]; then
  PREV_SIGNATURE=$(head -1 "$TRACKER" 2>/dev/null || echo "")
  COUNT=$(tail -1 "$TRACKER" 2>/dev/null || echo "0")
  # Validate count is numeric
  if ! [[ "$COUNT" =~ ^[0-9]+$ ]]; then
    COUNT=0
  fi
fi

# Same signature → increment. Different → reset to 1.
if [ "$SIGNATURE" = "$PREV_SIGNATURE" ]; then
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi

# Write updated state
printf '%s\n%s\n' "$SIGNATURE" "$COUNT" > "$TRACKER"

# At threshold, inject stop-and-rethink
if [ "$COUNT" -ge 3 ]; then
  cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "ITERATION GUARD: 3+ consecutive failures with the same command. CLAUDE.md says: 'After 2-3 failures, step back. Revert partial changes. Re-read. Ask.' Stop retrying the same approach. Consider: (1) Is the root cause different from what you assumed? (2) Are there existing patterns/tests that show how this works? (3) Should you ask the user?"
  }
}
EOF
fi

exit 0
