---
name: wrap
description: Use when the owner says "save to memory", "save progress", "end session", "wrap up", "commit the work before I close", or says they are restarting or continuing later.
argument-hint: "[commit]"
---

# Wrap up a session

Close out so the next session can start cold. Nothing is pushed or deployed here; that is /ship.

1. **Memory.** Save what the next session needs: decisions, current state, open items, gotchas learned, all with absolute dates. Update the existing memory file before creating a new one. Keep `MEMORY.md` one line per file with live projects on top. A new project or asset also gets an entry in `<projects-root>/ASSETS.md` with `aka` and `use for` lines.
2. **Work in progress.** For every repo touched this session run `git -C <repo> status -sb`. Commit only if the owner asked to (clear message, no push). Otherwise list what is uncommitted or unpushed.
3. **Running processes.** List dev servers as /ports does and stop the ones this session started.
4. **Report in 10 lines or fewer:** memory files written or updated, uncommitted and unpushed counts per repo, anything still running, the first move for next session.
