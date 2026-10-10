def decision($kind; $why):
  {hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $kind, permissionDecisionReason: $why}};

# Quoted text (commit messages, echo strings) must not trigger rules, except when it is itself a command run by sh -c or eval.
def without_quotes: gsub("'[^']*'"; "''") | gsub("\"(\\\\.|[^\"\\\\])*\""; "\"\"");
def shell_text: if test("\\b(ba|z|da)?sh\\s+-[A-Za-z]*c\\b|\\beval\\b") then . else without_quotes end;

def deny_rules: [
  ["\\bgh\\s+auth\\s+(switch|login|logout|setup-git)\\b", "gh account switching"],
  ["\\bvercel(@\\S+)?\\s+(switch|login|logout|teams\\s+switch)\\b", "Vercel account or team switching"],
  ["\\bfirebase(-tools)?(@\\S+)?\\s+(login|logout)\\b", "Firebase account switching"],
  ["\\bgcloud\\s+(auth\\s+(login|revoke|activate-service-account)|config\\s+(set\\s+account|configurations\\s+activate))\\b", "gcloud account switching"]
];

# Matched against the raw command because the value that matters sits inside quotes.
# [ \t]+ rather than \s+ so a read-only `git config user.email` followed by a newline is not taken for a write.
def raw_deny_rules: [
  ["\\bGH_CONFIG_DIR=(?![\"']?[^\\s\"']*gh-personal)", "pointing gh at another account's config"],
  ["\\bgit(\\s+-C\\s+\\S+)?\\s+config\\s+(--(global|system|local)\\s+)?user\\.(email|name)[ \\t]+[^-\\s]", "changing the git commit identity"],
  ["\\bgit\\b[^;&|\\n]*\\s-c\\s+user\\.(email|name)=", "overriding the git commit identity"],
  ["\\bGIT_(AUTHOR|COMMITTER)_(EMAIL|NAME)=", "overriding the git commit identity"]
];

def ask_rules: [
  ["\\bgit(\\s+(-[Cc]\\s+\\S+|--[\\w-]+(=\\S+)?))*\\s+push\\b", "git push"],
  ["\\bvercel(@\\S+)?\\b[^;&|\\n]*\\s--prod\\b", "Vercel production deploy"],
  ["\\bvercel(@\\S+)?(\\s+-\\S+)*\\s+(deploy|promote|rollback|redeploy|alias)\\b", "Vercel deploy"],
  ["(^|[;&|(]\\s*|\\bnpx(\\s+-[-\\w]+)*\\s+)vercel(@\\S+)?(\\s+-(?!-?(v|h|version|help)\\b)[-\\w=]+)*\\s*($|[;&|)])", "Vercel preview deploy"],
  ["\\bfirebase(-tools)?(@\\S+)?\\s+(deploy|hosting:channel:deploy|hosting:clone|appdistribution:distribute)\\b", "Firebase deploy"],
  ["\\b(npm|pnpm|yarn)\\s+publish\\b", "package publish"],
  ["\\bgh\\s+(repo\\s+(create|edit|rename|delete|archive|unarchive)|release\\s+create|gist\\s+create|pr\\s+(create|merge)|workflow\\s+run)\\b", "GitHub publish or repo change"],
  ["\\bgh\\s+api\\b[^;&|\\n]*\\s(-X|--method)\\s*(POST|PUT|PATCH|DELETE)\\b", "GitHub API write"],
  ["\\bclasp\\s+(push|deploy)\\b", "Apps Script deploy"],
  ["\\bdocker\\s+push\\b|\\b(netlify|fly|flyctl)\\s+deploy\\b|\\bwrangler\\s+(deploy|publish|pages\\s+deploy)\\b", "deploy"]
];

def hits($rules; $text): [$rules[] | select(.[0] as $re | $text | test($re)) | .[1]];

def bash_decision:
  (.tool_input.command // "") as $raw
  | ($raw | shell_text) as $text
  | (hits(deny_rules; $text) + hits(raw_deny_rules; $raw)) as $denied
  | hits(ask_rules; $text) as $asked
  | if ($denied | length) > 0 then
      decision("deny"; "Guard: \($denied[0]) is blocked for the agent. If it is truly needed, run it yourself with the ! prefix.")
    elif ($asked | length) > 0 then
      decision("ask"; "Guard: \($asked[0]) needs your explicit go.")
    else empty end;

def artifact_decision:
  (.tool_input.action // "publish") as $action
  | if $action == "publish" or $action == "delete" then
      decision("ask"; "Guard: artifact \($action) needs your explicit go.")
    else empty end;

def mcp_decision:
  if (.tool_name | test("deploy|publish|send|share"; "i")) then
    decision("ask"; "Guard: \(.tool_name) publishes or sends, so it needs your explicit go.")
  else empty end;

if .tool_name == "Bash" then bash_decision
elif .tool_name == "Artifact" then artifact_decision
elif ((.tool_name // "") | startswith("mcp__")) then mcp_decision
else empty end
