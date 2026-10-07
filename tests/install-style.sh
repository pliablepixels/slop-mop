#!/bin/sh
# Builds the output style from a fixture personal.md and checks what lands in it.
set -e
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cp "$root/slop-mop/SKILL.md" "$root/slop-mop/install-style.sh" "$tmp/"
cat > "$tmp/personal.md" <<'P'
# Personal rules

## Rules
- Uses em dashes. Example: "a - b". [overrides: No dashes]

## Samples
x

```
one two three four five
```

```
one two three
```
P
sh "$tmp/install-style.sh" "$tmp/out.md" > /dev/null
out="$tmp/out.md"
fail() { echo "FAIL: $1"; exit 1; }
head -1 "$out" | grep -qx -- '---' || fail "frontmatter"
grep -qx 'keep-coding-instructions: true' "$out" || fail "keep-coding-instructions"
grep -q '^\*\*No dashes\.\*\*' "$out" && fail "overridden rule kept"
grep -q '^\*\*No forced triads\.\*\*' "$out" || fail "rule after the dropped one lost"
grep -qx '## Voice' "$out" && fail "Voice section kept with personal.md"
grep -qx '## Four jobs' "$out" && fail "procedures kept"
[ "$(grep -cx '## Rules' "$out")" = 2 ] || fail "template code block leaked into the style"
grep -q 'stay within their length (3 to 5 words)' "$out" || fail "sample word range"
printf '# Personal rules\n\n## Rules\n- Short.\n' > "$tmp/personal.md"; sh "$tmp/install-style.sh" "$out" > /dev/null
grep -q 'stay within their length unless' "$out" || fail "length wording without samples"
rm "$tmp/personal.md"; sh "$tmp/install-style.sh" "$out" > /dev/null
grep -qx '## Voice' "$out" || fail "Voice section dropped without personal.md"
grep -q '^\*\*No dashes\.\*\*' "$out" || fail "base rule dropped without personal.md"
echo "ok"
