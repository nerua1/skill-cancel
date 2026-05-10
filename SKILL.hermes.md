---
name: cancel
version: 1.1.0
description: Cancel any active task or mode with intelligent cleanup — Hermes Edition
compatible-with: hermes-agent
---

# Cancel Skill — Hermes Edition

Intelligent cancellation that detects and cancels active tasks, subagents, or background processes with proper state preservation.

## What It Does

- Detects active subagents (delegate_task children)
- Kills background processes cleanly via `process(action='kill')`
- Cleans temp files and stale locks
- Preserves partial results before exit

## Usage (Hermes)

### Check what's running
```
process(action='list')
```

### Cancel specific process
```
process(action='kill', session_id='<id>')
```

### Cancel all background processes
```python
from hermes_tools import terminal

# List all hermes-owned processes
ps_output = terminal("ps aux | grep -E 'hermes|delegate_task' | grep -v grep")["output"]

# Kill leftover temp files
terminal("find /tmp/hermes_* -type f -mmin +60 -delete")
terminal("rm -f ~/.hermes/sessions/*.lock")
```

### Force cleanup
```bash
# Kill stubborn processes
pkill -f "delegate_task" 2>/dev/null
pkill -f "lmstudio" 2>/dev/null

# Clear session locks
rm -f ~/.hermes/sessions/*.lock
```

## When to Use

| Scenario | Action |
|----------|--------|
| Task complete naturally | `process(action='kill')` for leftover processes |
| Need to stop and fix | Kill active tasks, keep partial files |
| Emergency stop | Force kill everything, minimal cleanup |
| Reset workspace | Clear locks, temp files, stale sessions |

## State Preservation

Cancel preserves:
- Files already written to disk
- Session logs
- Partial results in working directory

Cancel removes:
- Running background processes
- File locks
- Temp files older than 1 hour

## Hermes-Native Pattern

Hermes `process` tool is the native equivalent of OpenClaw `/cancel`:
- `process(action='list')` = `openclaw sessions list --active`
- `process(action='kill', session_id='x')` = `openclaw sessions kill x`
- `process(action='close', session_id='x')` = graceful stdin close

No external dependencies. All cleanup happens through Hermes process management.

---

Built by [nerua1](https://github.com/nerua1). Support: [PayPal.me/nerudek](https://www.paypal.me/nerudek)
