# slop-mop

A writing skill for coding agents. It makes the agent write the way a careful person explains something to a friend who does not know the subject: plain words, short sentences, no selling, nothing invented.

It works in three modes. When the agent drafts text, it applies the rules as it writes. When you give it a draft, it makes the smallest edit that removes AI patterns and keeps your voice. When you ask whether text sounds like AI, it names each pattern with the line it appears on and does not rewrite.

## What it enforces

- Facts only. No invented names, numbers, dates, quotes, or sources. No stretching a small fact into a bigger claim. Failures reported as failures.
- No boasting. No superlatives about the work, no "excited to announce," no "stands as a testament." A benchmark comes with its conditions.
- Plain language. Common words, terms defined on first use, one idea per sentence, an example when the idea is abstract.
- No staging. No "not X but Y," no throat clearing, no one-line closers, no colon reveals, no "the key point is," no sentences that frame the work as a philosophy instead of saying what happens.
- Sounds like a person. No em dashes, no forced triads, no synonym rotation, no bold labels on every list item, no chatbot wrappers.

The full rules are in `slop-mop/SKILL.md`.

When the agent delegates slop-mop work to subagents, the skill tells it to run them on Opus or a more capable model. Smaller models miss the rules that need judgment, such as the framing check.

## Install

Copy the skill directory into your agent's skills folder. For Claude Code:

```
cp -r slop-mop ~/.claude/skills/slop-mop
```

Then tell your agent to use it for prose. In Claude Code, add a line like this to `~/.claude/CLAUDE.md`:

```
Use the slop-mop skill for all prose: replies, docs, READMEs, reports, commit messages, and PR bodies.
```

## Where it came from

slop-mop merges three earlier skills:

- [humanizer](https://github.com/blader/humanizer) by blader, which ranks AI writing patterns by strength and explains why models produce them.
- [stop-slop](https://github.com/hardikpandya/stop-slop) by Hardik Pandya, which adds the rules against false agency ("the decision emerged") and vague declaratives ("the implications are significant").
- [no-ai-slop](https://github.com/petergyang/no-ai-slop) by Peter Yang, which adds the detect mode, the minimum edit, the portability test, and protecting the specific number.

The pattern list itself traces back to Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).

slop-mop drops the parts of those skills that pull toward punchy or opinionated copy: blanket bans on adverbs and passive voice, scoring rubrics, and instructions to preserve edge and profanity. It adds rules for two things none of them covered: writing for a reader outside the field, and writing about your own work without praising it.

## License

MIT, same as the skills it is built from.
