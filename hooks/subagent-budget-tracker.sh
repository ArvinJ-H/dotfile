#!/bin/bash
# PreToolUse hook: quality reinforcement for subagent investigations.
# Two mechanisms:
#   1. Investigation awareness: on Write, inject the agent's investigation
#      state (sources touched, tool types, recommended min) so the agent
#      can decide whether it has enough evidence. Soft signal, not a gate.
#   2. Tool diversity nudge: on investigation tools, nudge when one tool
#      type dominates.
#
# Only activates for subagents (agent_id present in hook input).

INPUT=$(cat)

# Skip parent calls (no agent_id)
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // empty')
[ -z "$AGENT_ID" ] && exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Per-agent state
TRACKER="/tmp/claude-budget-${AGENT_ID}"
SOURCES="/tmp/claude-sources-${AGENT_ID}"

# Initialize if missing
[ ! -f "$TRACKER" ] && echo "0 0 0 0 0 0 0" > "$TRACKER"
[ ! -f "$SOURCES" ] && touch "$SOURCES"

read -r TOTAL N_READ N_GREP N_GLOB N_BASH N_WSEARCH N_WFETCH < "$TRACKER"
for var in TOTAL N_READ N_GREP N_GLOB N_BASH N_WSEARCH N_WFETCH; do
  eval "[[ \"\$$var\" =~ ^[0-9]+$ ]] || $var=0"
done

# Count distinct tool types used so far
TYPES_USED=0
[ "$N_READ" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_GREP" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_GLOB" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_BASH" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_WSEARCH" -gt 0 ] && TYPES_USED=$((TYPES_USED + 1))
[ "$N_WFETCH" -gt 0 ]  && TYPES_USED=$((TYPES_USED + 1))

DISTINCT_SOURCES=$(sort -u "$SOURCES" 2>/dev/null | wc -l | tr -d ' ')

# Recommended minimum sources (set by skill via env, default 3)
REC_MIN=${CLAUDE_AGENT_MIN:-3}

# --- Mechanism 1: Investigation awareness on Write ---
case "$TOOL_NAME" in
  Write)
    # Build usage summary
    USAGE=""
    [ "$N_READ" -gt 0 ]    && USAGE="${USAGE}Read=${N_READ} "
    [ "$N_GREP" -gt 0 ]    && USAGE="${USAGE}Grep=${N_GREP} "
    [ "$N_GLOB" -gt 0 ]    && USAGE="${USAGE}Glob=${N_GLOB} "
    [ "$N_BASH" -gt 0 ]    && USAGE="${USAGE}Bash=${N_BASH} "
    [ "$N_WSEARCH" -gt 0 ] && USAGE="${USAGE}WebSearch=${N_WSEARCH} "
    [ "$N_WFETCH" -gt 0 ]  && USAGE="${USAGE}WebFetch=${N_WFETCH} "

    cat << EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"INVESTIGATION STATUS before write: ${TOTAL} calls, ${TYPES_USED} tool types, ${DISTINCT_SOURCES} distinct sources (${USAGE}). Recommended minimum: ${REC_MIN} sources. Proceed if evidence is sufficient for all assigned questions."}}
EOF
    exit 0
    ;;
esac

# --- Track investigation tools ---
SOURCE=""
case "$TOOL_NAME" in
  Read)
    N_READ=$((N_READ + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    ;;
  Grep)
    N_GREP=$((N_GREP + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.pattern // empty')
    ;;
  Glob)
    N_GLOB=$((N_GLOB + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.path // .tool_input.pattern // empty')
    ;;
  Bash)
    N_BASH=$((N_BASH + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | grep -oE '/[^ ]+' | head -1)
    [ -z "$SOURCE" ] && SOURCE=$(echo "$INPUT" | jq -r '.tool_input.command // empty' | cut -c1-60)
    ;;
  WebSearch)
    N_WSEARCH=$((N_WSEARCH + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.query // empty')
    ;;
  WebFetch)
    N_WFETCH=$((N_WFETCH + 1))
    SOURCE=$(echo "$INPUT" | jq -r '.tool_input.url // empty')
    ;;
  mcp__*) ;;
  *) exit 0 ;;
esac

TOTAL=$((TOTAL + 1))
echo "$TOTAL $N_READ $N_GREP $N_GLOB $N_BASH $N_WSEARCH $N_WFETCH" > "$TRACKER"
[ -n "$SOURCE" ] && echo "$SOURCE" >> "$SOURCES"

# Recount after update
TYPES_USED=0
[ "$N_READ" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_GREP" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_GLOB" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_BASH" -gt 0 ]    && TYPES_USED=$((TYPES_USED + 1))
[ "$N_WSEARCH" -gt 0 ] && TYPES_USED=$((TYPES_USED + 1))
[ "$N_WFETCH" -gt 0 ]  && TYPES_USED=$((TYPES_USED + 1))

DISTINCT_SOURCES=$(sort -u "$SOURCES" 2>/dev/null | wc -l | tr -d ' ')

# --- Mechanism 2: Tool diversity nudge ---
MAX_SINGLE=0
for n in $N_READ $N_GREP $N_GLOB $N_BASH $N_WSEARCH $N_WFETCH; do
  [ "$n" -gt "$MAX_SINGLE" ] && MAX_SINGLE=$n
done

NUDGE=""
if [ "$TOTAL" -ge 3 ] && [ "$TYPES_USED" -lt 2 ]; then
  NUDGE=" Only 1 tool type used. Consider Read for context, Grep for patterns, Glob for discovery."
elif [ "$TOTAL" -ge 4 ] && [ "$MAX_SINGLE" -ge $((TOTAL * 2 / 3)) ]; then
  NUDGE=" One tool type dominates. Consider complementary tools for different angles."
fi

if [ -n "$NUDGE" ]; then
  cat << EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Investigation (${TOTAL} calls, ${TYPES_USED} tool types, ${DISTINCT_SOURCES} sources):${NUDGE}"}}
EOF
fi

exit 0
