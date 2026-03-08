#!/usr/bin/env bash
# Claude Code status line script
# ~/.claude/statusline-command.sh

input=$(cat)

# --- fields from JSON ---
cwd=$(echo "$input"         | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input"       | jq -r '.model.display_name // .model.id // "unknown"')
used=$(echo "$input"        | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input"   | jq -r '.context_window.remaining_percentage // empty')
session_name=$(echo "$input"| jq -r '.session_name // empty')

# --- current directory: show last 2 path components ---
short_cwd=$(echo "$cwd" | awk -F'/' '{
  n=NF
  if (n >= 2) printf "%s/%s", $(n-1), $n
  else        printf "%s", $n
}')
[ -z "$short_cwd" ] && short_cwd=$(basename "$cwd")

# --- context window bar (10 blocks) ---
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  filled=$(( used_int * 10 / 100 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  for i in $(seq 1 "$filled"); do bar="${bar}#"; done
  for i in $(seq 1 "$empty");  do bar="${bar}-"; done
  ctx_str="[${bar}] ${used_int}%"
else
  ctx_str="[----------] --%"
fi

# --- "working on" tag ---
# Uses the session name set via /rename; falls back to the current directory name.
if [ -n "$session_name" ]; then
  working_on="$session_name"
else
  working_on=$(basename "$cwd")
fi

# --- assemble the line ---
# Format:  dir  |  ctx  |  model  |  tag
printf "\033[36m%s\033[0m  |  \033[33m%s\033[0m  |  \033[35m%s\033[0m  |  \033[32m%s\033[0m" \
  "$short_cwd" \
  "$ctx_str" \
  "$model" \
  "$working_on"
