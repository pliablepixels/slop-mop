#!/bin/sh
# SessionStart hook output. Claude Code caps each hook's stdout at 10,000
# characters and shows only a 2,000-character preview of anything longer, so
# SKILL.md and personal.md are split at headings into parts under 9,000
# characters, one hook entry per part. `preload.sh N` prints part N, and
# nothing when there is no part N.
d=$(cd "$(dirname "$0")" && pwd)
part=${1:-1}
{
  cat "$d/SKILL.md"
  if [ -f "$d/personal.md" ]; then echo; cat "$d/personal.md"; fi
} | awk -v max=9000 -v want="$part" -v dir="$d" '
  /^```/ { fence = !fence }
  !fence && /^#+ / && sec != "" { secs[++n] = sec; sec = "" }
  { sec = sec $0 "\n" }
  END {
    secs[++n] = sec
    p = 1
    for (i = 1; i <= n; i++) {
      if (length(chunk[p]) > 0 && length(chunk[p]) + length(secs[i]) > max) p++
      chunk[p] = chunk[p] secs[i]
    }
    if (want > p) exit
    if (want == 1)
      printf "The slop-mop skill and the writer'\''s personal rules follow in %d parts. Apply them to all prose in this session, including replies to the user. If a part is missing, read %s/SKILL.md and %s/personal.md before your first reply.\n\n", p, dir, dir
    if (length(chunk[want]) > max)
      printf "[slop-mop part %d of %d is too long to print. Read %s/SKILL.md and %s/personal.md before your first reply.]\n", want, p, dir, dir
    else
      printf "[slop-mop part %d of %d]\n%s", want, p, chunk[want]
  }'
exit 0
