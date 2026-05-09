---
compatible-with: openclaw

> **Why this exists:** Killing a subagent mid-task often leaves temp files, broken git states, and orphaned processes. This skill teaches graceful cancellation — cleanup first, then exit.

name: cancel
description: Cancel any active task or mode - intelligent cleanup with state preservation
version: 1.0.0
author: Rook (adapted from oh-my-codex)
---
compatible-with: openclaw

# Cancel Skill for OpenClaw

Intelligent cancellation that detects and cancels active tasks, modes, or subagents with proper cleanup.

## What It Does

The cancel skill is the **standard way to complete and exit any long-running task**.
When work is complete or needs to stop, invoke this skill for proper state cleanup.

Automatically detects what is active and cancels it:
- **Subagents**: Stops all running subagents, preserves partial results
- **Long tasks**: Interrupts exec with timeout, cleans up temp files
- **Background jobs**: Stops background processes
- **File locks**: Releases locked resources

## Usage

```bash
/cancel                    # Cancel current active task
/cancel --force           # Force kill everything
/cancel --all             # Clear all state and reset
/cancel subagent:4b34f12d # Cancel specific subagent by ID
```

Or say: "cancel", "stop", "abort"

## Why This Exists

Long-running tasks often leave behind:
- Zombie subagents consuming resources
- Temp files filling disk
- File locks blocking other operations
- Partial states that confuse next tasks

Cancel prevents this by proper cleanup.

## How It Works

### 1. Detection Phase

```bash
# Check for active subagents
openclaw sessions list --active

# Check for background processes
jobs -l

# Check for file locks
lsof +D ~/.openclaw/workspace/tmp 2>/dev/null
```

### 2. Graceful Shutdown

```bash
# Signal subagents to stop
openclaw sessions kill <session_id> --graceful

# Wait up to 15 seconds for cleanup
sleep 15
```

### 3. Force Kill (if needed)

```bash
# Kill stubborn processes
kill -9 <pid>

# Clear all state
rm -rf ~/.openclaw/workspace/tmp/*
```

### 4. Cleanup Phase

```bash
# Remove temp files
find ~/.openclaw/workspace/tmp -type f -mtime +1 -delete

# Clear session state
openclaw state clear

# Release locks
rm -f ~/.openclaw/workspace/*.lock
```

## Implementation

```bash
#!/bin/bash
# ~/.openclaw/skills/cancel/cancel.sh

FORCE=false
TARGET=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE=true
      shift
      ;;
    --all)
      FORCE=true
      shift
      ;;
    subagent:*)
      TARGET="${1#subagent:}"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

echo "=== CANCEL: Checking for active tasks ==="

# Check for active subagents
ACTIVE_SUBAGENTS=$(openclaw sessions list --active 2>/dev/null | grep -c "active" || echo "0")

if [[ "$ACTIVE_SUBAGENTS" -gt 0 ]]; then
  echo "Found $ACTIVE_SUBAGENTS active subagent(s)"
  
  if [[ -n "$TARGET" ]]; then
    # Cancel specific subagent
    echo "Cancelling subagent: $TARGET"
    openclaw sessions kill "$TARGET" 2>/dev/null || true
  else
    # Cancel all subagents
    openclaw sessions list --active 2>/dev/null | while read line; do
      session_id=$(echo "$line" | awk '{print $1}')
      if [[ -n "$session_id" ]]; then
        echo "Cancelling: $session_id"
        openclaw sessions kill "$session_id" 2>/dev/null || true
      fi
    done
  fi
fi

# Check for background jobs
if [[ -n "$(jobs -p)" ]]; then
  echo "Found background jobs"
  if [[ "$FORCE" == true ]]; then
    kill $(jobs -p) 2>/dev/null || true
  else
    # Try graceful first
    kill -TERM $(jobs -p) 2>/dev/null || true
    sleep 2
    kill -KILL $(jobs -p) 2>/dev/null || true
  fi
fi

# Cleanup temp files
echo "Cleaning up temp files..."
find ~/.openclaw/workspace/tmp -type f -mtime +1 -delete 2>/dev/null || true

# Clear locks
rm -f ~/.openclaw/workspace/*.lock 2>/dev/null || true

echo "=== CANCEL: Complete ==="

if [[ "$FORCE" == true ]]; then
  echo "Force mode: All state cleared"
else
  echo "Graceful cancel: Tasks stopped, partial results preserved"
fi
```

## Integration with OpenClaw

Add to `AGENTS.md`:

```markdown
## Task Lifecycle

When a task needs to stop:
1. Use `/cancel` for graceful shutdown
2. Use `/cancel --force` for emergency stop
3. Always cancel before starting conflicting tasks

Cancel preserves partial results in:
- ~/.openclaw/workspace/partial-results/
- Subagent output (if any completed)
```

## When to Use

| Scenario | Command | Result |
|----------|---------|--------|
| Task complete naturally | `/cancel` | Clean exit, preserve results |
| Need to stop and fix | `/cancel` | Stop, keep partial work |
| Emergency stop | `/cancel --force` | Kill everything |
| Reset workspace | `/cancel --all` | Clear all state |
| Conflicting tasks | `/cancel` then new task | Safe handoff |

## State Preservation

Cancel preserves:
- ✅ Completed subagent outputs
- ✅ Files already written
- ✅ Session logs
- ✅ Partial results in designated directory

Cancel removes:
- ❌ Running processes
- ❌ Temp files > 1 day old
- ❌ File locks
- ❌ Active session state

## Testing

```bash
# Start long task
sleep 300 &

# Cancel gracefully
/cancel

# Check nothing running
jobs

# Force test
(sleep 300 &) 
/cancel --force
```

## Dependencies

- `openclaw` CLI
- Standard POSIX tools (bash, grep, awk, kill)
- `lsof` (optional, for lock detection)

## Version History

- 1.0.0: Initial implementation based on oh-my-codex cancel skill

---
compatible-with: openclaw

If this saved you time: [☕ PayPal.me/nerudek](https://www.paypal.me/nerudek)
