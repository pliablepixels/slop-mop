#!/bin/sh
# Prints the skill and the writer's personal rules for a SessionStart hook.
# The agent then has them from the first reply, instead of relying on it to
# decide that a reply counts as prose and load the skill.
d=$(dirname "$0")
echo "The slop-mop skill and the writer's personal rules are loaded below. Apply them to all prose in this session. Do not load slop-mop again with the Skill tool."
echo
cat "$d/SKILL.md"
if [ -f "$d/personal.md" ]; then
  echo
  cat "$d/personal.md"
fi
exit 0
