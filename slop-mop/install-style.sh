#!/bin/sh
# Builds a Claude Code output style from personal.md and the drafting rules in
# SKILL.md. Claude Code sends an output style with every request, so the rules
# apply to every reply without the agent deciding to load the skill. Re-run
# after editing either file, then restart Claude Code.
#
# With a personal.md, the style leaves out each base rule that a personal rule
# names with [overrides: <rule name>], and the base Voice section, so no base
# rule contradicts the writer's voice. The edit, detect, and personalize
# procedures stay in the skill.
d=$(cd "$(dirname "$0")" && pwd)
out=${1:-$HOME/.claude/output-styles/slop-mop.md}
personal="$d/personal.md"
mkdir -p "$(dirname "$out")"

# Word range of the samples, so the style can state a concrete length target.
range=""
[ -f "$personal" ] && range=$(awk '/^## Samples/ { on = 1; next } on && /^```/ { if (inb) { print w; w = 0 } inb = !inb; next } inb { w += NF }' "$personal" | sort -n | awk 'NR == 1 { lo = $1 } { hi = $1 } END { if (NR) print lo " to " hi }')

overrides=""
[ -f "$personal" ] && overrides=$(grep -o '\[overrides: [^]]*\]' "$personal" | sed 's/^\[overrides: //; s/\]$//' | sort -u | tr '\n' '|')

{
  printf '%s\n' '---' 'name: slop-mop' "description: Plain, factual prose in the writer's own voice" 'keep-coding-instructions: true' '---' ''
  if [ -f "$personal" ]; then
    echo "Write every reply to the user, and all other prose (docs, commit messages, PR and issue bodies, comments), in the writer's voice described by the personal rules below. They decide length, openings, punctuation, and formatting for every reply, including diagnoses and status reports. A reply to the user should read like one of the samples at the end of the personal rules, with the same dashes and openings, and stay within their length (${range:-similar} words) unless the user asks for more detail. To fit, give the answer and only the evidence the reader needs to act on it, and leave the rest out. The base rules after them apply where the personal rules say nothing. Neither set may change a fact."
    echo
    cat "$personal"
    echo
    echo "# Base rules"
  else
    echo "Write every reply to the user, and all other prose (docs, commit messages, PR and issue bodies, comments), by the rules below."
  fi
  echo
  awk -v overrides="$overrides" -v personal="$([ -f "$personal" ] && echo 1)" '
    BEGIN { n = split(overrides, o, "|"); for (i = 1; i <= n; i++) if (o[i] != "") drop["**" o[i] ".**"] = 1 }
    /^```/ { fence = !fence }
    /^## / && !fence {
      keep = ($0 ~ /^## (Rules|Words and phrases to cut|When not to act|Check before sending)$/) || ($0 == "## Voice" && !personal)
    }
    !keep { next }
    /^\*\*/ { skip = 0; for (k in drop) if (index($0, k) == 1) skip = 1 }
    /^$/ && skip { skip = 0; next }
    !skip
  ' "$d/SKILL.md"
  if [ -f "$personal" ]; then
    echo
    echo "Before you send a reply, reread it against the personal rules at the top: its length, how it opens, its dashes, bold, and lists. Then run the check above."
  fi
} > "$out"
echo "Wrote $out. Set \"outputStyle\": \"slop-mop\" in ~/.claude/settings.json and restart Claude Code."
