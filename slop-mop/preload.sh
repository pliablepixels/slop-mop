#!/bin/sh
# Output for a SessionStart hook. Claude Code moves hook output over 10,000
# characters to a file and shows the agent only a 2 KB preview, so this
# prints the short parts in full and points at SKILL.md for the rest.
d=$(cd "$(dirname "$0")" && pwd)
limit=9000
echo "Before your first reply in this session, load the slop-mop skill with the Skill tool (or read $d/SKILL.md). Apply it to all prose, including replies to the user."
if [ -f "$d/personal.md" ]; then
  if [ "$(wc -c < "$d/personal.md")" -lt "$limit" ]; then
    echo "The writer's personal rules follow. They apply to every reply in this session."
    echo
    cat "$d/personal.md"
  else
    echo "The writer's personal rules are too long to print here. Read $d/personal.md before your first reply."
  fi
fi
echo
awk '/^## Check before sending/{p=1} /^## Sources/{p=0} p' "$d/SKILL.md"
exit 0
