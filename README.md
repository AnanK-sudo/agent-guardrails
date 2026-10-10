# agent-guardrails

The hooks and skills I run Claude Code with.

I build through AI coding agents every day: several sessions at once, two Claude profiles (personal and work), many repos, real deploys. The agents can move fast because of these rails. They cannot switch accounts, change who a commit belongs to, or push, publish or deploy anything without my go.

## The rules

- **Origin decides ownership.** Whatever a profile writes or kicks off belongs to that profile. Either profile may read the other's projects when I ask; neither writes to the other's.
- **Account switching is denied outright.** `gh auth switch/login/logout/setup-git`, Vercel and Firebase logins, gcloud account changes, and any override of the git commit identity. If one is truly needed, I run it myself.
- **Every outward step stops for my go.** `git push`, Vercel and Firebase deploys, `npm publish`, `gh repo create/edit/rename/delete`, GitHub API writes, workflow runs, artifact publishes, and MCP tools that deploy, publish, send or share.
- **Fail closed.** If the rules cannot run, the hook asks instead of letting the call through.

## How the guard works

`hooks/guard.sh` runs `hooks/guard.jq` on every `PreToolUse` event for Bash, Artifact and the matching MCP tools, and answers `deny`, `ask` or nothing.

- Quoted text such as commit messages is stripped before matching, so `git commit -m "do not git push yet"` passes. A quoted command inside `sh -c` or `eval` is still caught.
- The identity rules match the raw command, because the value that matters sits inside quotes.
- `GH_CONFIG_DIR` may only point at the profile's own gh config (`gh-personal` here), which is how two profiles share one machine without sharing a GitHub login.

`tests/run.sh` feeds 32 cases through the guard and checks each decision. One of them exists because the identity rule once denied a read-only `git config --global user.email` that was followed by a newline: `\s+` also matches a newline, so the next command looked like the value. The rule now matches `[ \t]+`.

## Session skills

| Skill | What it does |
|---|---|
| `/jump` | Read-only status brief for a project: where it lives, last work, open items, unpushed work, next step. |
| `/wrap` | Saves decisions and state to memory, lists uncommitted and unpushed work, stops the dev servers the session started. |
| `/ship` | Preflight (right account, clean tree, build), push with an ephemeral credential helper, deploy by target, verify by effect. |
| `/ports` | Lists listening dev servers with their project folders and stops the ones I name. |

"Verify by effect" is the habit behind all of it: after a deploy, load the live page and check the change is really there, instead of trusting a green log.

## Install

1. Copy `hooks/` to `~/.claude/hooks/` and merge `settings.example.json` into `~/.claude/settings.json`.
2. Copy the folders in `skills/` to `~/.claude/skills/`.
3. Replace the placeholders in angle brackets with your own accounts and paths.
4. Run `sh tests/run.sh` to check the guard on your machine. It needs `jq`, which macOS ships at `/usr/bin/jq`.

## License

MIT, see [LICENSE](LICENSE).
