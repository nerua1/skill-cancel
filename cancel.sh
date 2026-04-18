#!/bin/bash
# Cancel skill - stop active tasks
FORCE=false
if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then FORCE=true; fi
if [[ "$1" == "--all" ]] || [[ "$1" == "-a" ]]; then FORCE=true; fi

echo "🔴 CANCELLING"
echo "Force: $FORCE"

# Kill subagents
if [[ "$FORCE" == true ]]; then
  echo "Killing all subagents..."
  openclaw sessions list 2>/dev/null | grep -E "active|running" | while read line; do
    session_id=$(echo "$line" | awk '{print $1}')
    [[ -n "$session_id" ]] && openclaw sessions kill "$session_id" 2>/dev/null
  done
fi

echo "✅ Cancel complete"
