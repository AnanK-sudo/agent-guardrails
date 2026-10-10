---
name: ports
description: Use when the owner asks what is running on localhost, which dev servers or ports are open, to kill the dev servers, vite or next processes, or to make sure nothing is left running before ending a session.
argument-hint: "[kill]"
model: sonnet
effort: low
---

# Dev servers and open ports

1. **List** listening TCP ports owned by the current user:
   `lsof -nP -iTCP -sTCP:LISTEN -a -u "$(id -un)"`
2. **Identify** each PID: `ps -o pid=,etime=,command= -p <pid>` and its folder with `lsof -a -p <pid> -d cwd -Fn | sed -n 's/^n//p'`.
3. **Show a table:** port, process, project folder, uptime. Label each row:
   - **dev server**: node, vite, next, python or similar started from the projects folder
   - **database**: postgres (5432), redis (6379)
   - **system, leave alone**: rapportd, ControlCenter on 5000 and 7000 (AirPlay Receiver), anything under `/System`
4. **Kill** only what the owner named, or every dev server when they said "kill" or "kill all the dev servers": `kill <pid>`, wait 5 seconds, re-run step 1 to confirm. Use `kill -9` only for a survivor.

Ask before stopping a database, this session's MCP servers, or anything outside the projects folder. Explain in plain English.
