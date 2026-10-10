#!/bin/sh
# Fail closed: if the rules cannot run, ask instead of letting a push or deploy through unguarded.
/usr/bin/jq -c -f "${0%/*}/guard.jq" 2>/dev/null || printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Guard could not evaluate this call, so it needs your approval."}}'
