#!/bin/sh
# Feeds every case in cases.jsonl through the guard and compares the decision with the expected one.
dir=${0%/*}
guard=${1:-$dir/../hooks/guard.sh}
pass=0
fail=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  expect=$(printf '%s' "$line" | jq -r '.expect')
  output=$(printf '%s' "$line" | jq -c '{tool_name, tool_input}' | /bin/sh "$guard")
  got=$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null)
  [ -n "$got" ] || got=allow
  if [ "$got" = "$expect" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf 'FAIL expected %s, got %s: %s\n' "$expect" "$got" "$(printf '%s' "$line" | jq -c '.tool_input')"
  fi
done < "$dir/cases.jsonl"
printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
