#!/bin/bash
# SessionEnd hook: flags sessions with code changes for reflection at next start
# Reads transcript, checks for Edit/Write tool uses, writes flag if found

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Count Edit/Write tool uses as proxy for "substantive work was done"
EDIT_COUNT=$(grep -c '"Edit"\|"Write"' "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)

if [ "$EDIT_COUNT" -gt 0 ]; then
  echo "$(date +%Y-%m-%d) $TRANSCRIPT_PATH" >> ~/.claude/pending-reflect
fi

# Empty output — SessionEnd can't influence behavior
echo '{}'
exit 0
