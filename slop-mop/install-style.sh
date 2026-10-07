#!/bin/sh
# Builds a Claude Code output style from SKILL.md and personal.md. Claude Code
# sends an output style with every request, so the writing rules and the
# writer's voice apply to every reply without the agent deciding to load the
# skill. Re-run after editing either file, then restart Claude Code.
d=$(cd "$(dirname "$0")" && pwd)
out=${1:-$HOME/.claude/output-styles/slop-mop.md}
mkdir -p "$(dirname "$out")"
{
  printf '%s\n' '---' 'name: slop-mop' "description: Plain, factual prose in the writer's own voice" 'keep-coding-instructions: true' '---' ''
  echo "Write every reply to the user, and all other prose (docs, commit messages, PR and issue bodies, comments), by the rules below. Run the \"Check before sending\" list on each reply before you send it."
  if [ -f "$d/personal.md" ]; then
    echo
    echo "The writer's personal rules come first. They set the voice of every reply to this user, including short answers and status reports, and they override the base rules where the two conflict. They never override the rules on facts."
    echo
    cat "$d/personal.md"
  fi
  echo
  awk 'NR == 1 && /^---$/ { fm = 1; next } fm && /^---$/ { fm = 0; next } !fm' "$d/SKILL.md"
} > "$out"
echo "Wrote $out. Set \"outputStyle\": \"slop-mop\" in ~/.claude/settings.json and restart Claude Code."
