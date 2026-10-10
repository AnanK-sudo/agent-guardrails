---
name: ship
description: Use when the owner says "push", "push and deploy", "deploy", "ship it", "go live", "is it deployed" or "did the deploy work" for one of their projects.
argument-hint: "[project]"
---

# Push and deploy

The guard hook asks the owner before every push and deploy. That prompt is the go; never route around it.

1. **Project.** Resolve the name through `<projects-root>/ASSETS.md`. Projects that belong to the other Claude profile: never push or deploy them from here.
2. **Preflight.** `gh api user --jq .login` must print `<expected-github-login>`. `git -C <repo> status -sb` must be clean (commit first only if the owner agreed). Ship from `main` unless told otherwise. Run `npm run build` when the repo has a build script.
3. **Push** with an ephemeral credential helper, so nothing is stored and a missing credential fails fast instead of hanging on a keychain prompt:
   ```sh
   GIT_TERMINAL_PROMPT=0 git -C <repo> -c credential.helper= -c credential.helper='!f() { printf "username=x-access-token\npassword=%s\n" "$(gh auth token)"; }; f' push origin <branch>
   ```
   The empty `credential.helper=` clears inherited helpers first. The helper has no `$1` check on purpose: skill arguments get substituted into `$1`, and git ignores helper output for store and erase anyway. Confirm `gh api repos/<owner>/<repo>/commits/<branch> --jq .sha` equals `git -C <repo> rev-parse HEAD`.
4. **Deploy** by target. Keep your own table here:

   | Target | Command |
   |---|---|
   | Vercel projects deployed from the CLI | `npx vercel --prod --yes` in the repo root |
   | Firebase Hosting | `npx firebase-tools deploy --only hosting` |
   | GitHub Pages through Actions | push to `main`, then follow the run with `gh run list` |

5. **Verify by effect.** Load the live URL (`curl -sI` returns 200), then confirm the changed text, or the bundle name from local `dist/index.html`, is what is actually being served. Report the URL and exactly what was checked.

A failed build or deploy: show the error and diagnose it. Never retry blindly, force-push or skip the build.
