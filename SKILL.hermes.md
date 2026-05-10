---
name: cancel
version: 1.0.1
description: Cancel any active task or mode — Hermes Edition
compatible-with: [openclaw, hermes]
---

# Cancel Skill — Hermes Edition

Intelligent cancellation that detects and cancels active tasks, modes, or subagents with proper cleanup. Works with both OpenClaw and Hermes.

## What It Does

- Detects active tasks/subagents
- Graceful cleanup (temp files, git states, orphaned processes)
- State preservation before exit

## Usage (Hermes)

```bash
# Direct invocation
~/.hermes/skills/cancel/cancel.sh

# Force cancel all
~/.hermes/skills/cancel/cancel.sh --force

# As Hermes skill
skill_view(name='cancel')
```

## Usage (OpenClaw)

```bash
openclaw skill run cancel
openclaw skill run cancel --force
```

---

Built by [nerua1](https://github.com/nerua1). Support: [PayPal.me/nerudek](https://www.paypal.me/nerudek)
