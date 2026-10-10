---
name: jump
description: Use when the owner says "jump into", "jump back into", "pull up", "let's continue", "pick up where we left off", "what's pending" or "what's the status" for one of their projects.
argument-hint: "[project, as the owner names it]"
model: sonnet
effort: low
---

# Jump into a project

Read-only status brief so work can resume fast. Never edit, commit, push or deploy from this skill.

1. **Resolve the name.** Match `$ARGUMENTS` (or the project named in the request) against the `aka` lines in `<projects-root>/ASSETS.md`. No match: show the 3 closest entries and ask.
2. **Boundary (origin rule).** Projects written or kicked off from the other Claude profile belong to it: this brief may read them when asked, and never writes to them.
3. **Memory.** Find the project's line in the memory index (`MEMORY.md`) and read that file. Memory is a point-in-time note; verify before repeating it as fact.
4. **Live state** for each repo the entry names:
   - `git -C <repo> status -sb` and `git -C <repo> log -5 --format='%cs %h %s'`
   - No upstream shown? Compare `git -C <repo> rev-parse HEAD` with `gh api repos/<owner>/<repo>/commits/<branch> --jq .sha`, or report "no remote" when `git remote` is empty.
5. **Reply in this shape, 15 lines max:**
   - **Where it lives:** folder, branch, live URL
   - **Last work:** date plus the last 2 or 3 commits or memory notes
   - **Open items:** from memory, re-checked against git
   - **Unpushed or uncommitted:** counts
   - **Next step:** one line

## Common mistakes
- Trusting `git status -sb` alone: a repo without an upstream never shows "ahead".
- Reading an old memory as the current state.
