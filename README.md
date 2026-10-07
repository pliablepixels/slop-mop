<p align="center"><img src="assets/slop-mop.png" alt="slop-mop logo: a mop sweeping up scribbles" width="200"></p>

# slop-mop

A writing skill for coding agents. It makes the agent write the way a careful person explains something to a friend who does not know the subject: plain words, short sentences, no selling, nothing invented.

It works in three modes. When the agent drafts text, it applies the rules as it writes. When you give it a draft, it makes the smallest edit that removes AI patterns and keeps your voice. When you ask whether text sounds like AI, it names each pattern with the line it appears on and does not rewrite.

You can also teach it your own style with `/slop-mop personalize`. See [Personal style](#personal-style).

## What it enforces

- Facts only. No invented names, numbers, dates, quotes, or sources. No stretching a small fact into a bigger claim. Failures reported as failures.
- No boasting. No superlatives about the work, no "excited to announce," no "stands as a testament." A benchmark comes with its conditions.
- Plain language. Common words, terms defined on first use, one idea per sentence, an example when the idea is abstract.
- No staging. No "not X but Y," no throat clearing, no one-line closers, no colon reveals, no "the key point is," no sentences that frame the work as a philosophy instead of saying what happens.
- Sounds like a person. No em dashes, no forced triads, no synonym rotation, no bold labels on every list item, no chatbot wrappers.

The full rules are in `slop-mop/SKILL.md`.

When the agent delegates slop-mop work to subagents, the skill tells it to run them on Opus or a more capable model. Smaller models miss the rules that need judgment, such as the framing check.

## Install

Clone this repo, then copy the skill directory into your agent's skills folder. For Claude Code:

```
git clone https://github.com/pliablepixels/slop-mop.git
mkdir -p ~/.claude/skills
cp -r slop-mop/slop-mop ~/.claude/skills/
```

Then tell your agent to use it for prose. In Claude Code, add a line like this to `~/.claude/CLAUDE.md`:

```
Use the slop-mop skill for all prose: replies, docs, READMEs, reports, commit messages, and PR bodies.
```

### Use it as an output style (Claude Code)

The CLAUDE.md line asks the agent to load the skill, and the agent decides when a task counts as prose. It can get that wrong. A first message like "check if this issue is true" looks like a code task, so the agent answers without the skill and without your personal rules. Rules printed by a SessionStart hook did not fix this either: the agent had them in context and still wrote in a neutral voice.

An [output style](https://code.claude.com/docs/en/output-styles) fits better. Claude Code sends the active style with every request, as part of the system prompt, so the rules apply to every reply without the agent choosing to load anything. Build one from the skill and your `personal.md`:

```
sh ~/.claude/skills/slop-mop/install-style.sh
```

This writes `~/.claude/output-styles/slop-mop.md`. With a `personal.md`, the style puts your rules and samples first and states the samples' word range as the length target. After them come the skill's drafting rules, minus the Voice section and any rule you replaced with `[overrides: <rule name>]`, so no base rule argues against your voice. The edit, detect, and personalize procedures stay in the skill. The style sets `keep-coding-instructions: true`, so Claude Code keeps its software engineering instructions. Then set the style in `~/.claude/settings.json` and restart Claude Code:

```json
"outputStyle": "slop-mop"
```

If you have a `personal.md`, also import it into `~/.claude/CLAUDE.md`:

```
My personal rules: @~/.claude/skills/slop-mop/personal.md
```

Claude Code gives CLAUDE.md more weight than an output style, so other writing instructions in CLAUDE.md, such as "replies in full sentences", win over rules that only live in the style. An Opus grader scored replies from 1 to 5 for matching one writer's voice. With the style alone, nine replies to three prompts averaged about 2. With the import added, 33 replies to six prompts averaged about 3. Three of the writer's own comments averaged about 4. Check your CLAUDE.md for lines that set reply length or tone, and point them at the personal rules.

A project's `.claude/settings.json` or `.claude/settings.local.json` can set its own `outputStyle` and override yours. Running `/output-style` or picking a style in `/config` writes one to `settings.local.json`, so check there if the style stops applying in one project.

Claude Code reads style files at startup. Re-run `install-style.sh` after you change `personal.md` or update the skill, then restart. `/slop-mop personalize` does the re-run for you when the style file exists. The style is about 20,000 characters (roughly 5,000 tokens) of input per request, most of it served from the prompt cache after the first request. An output style does not apply to subagents other than forks, which use their own system prompts.

## Personal style

This step is optional. Without it, the skill uses only its default rules. A fresh install has no personal rules. Yours get created when you run the command below.

Run `/slop-mop personalize` and give it samples of your own writing, or state rules directly ("I never say folks"). Samples can be pasted text, file paths, or a link to things you wrote, such as a GitHub issue list where you comment a lot. Use writing you did without AI help, at least 500 words in total. The agent reads the samples, lists the habits that repeat, quotes an example for each, and keeps five to eight samples verbatim, since agents copy examples more closely than rules. After you confirm the list, it writes the rules to `personal.md` in the installed skill directory. Run it again with new samples to add or refine rules.

After writing the file, the agent checks your instruction files (in Claude Code, `~/.claude/CLAUDE.md` and the project's `CLAUDE.md`) for lines that would override your rules, such as "keep replies neutral." Those files outrank skills. The agent quotes each conflicting line, suggests a replacement, and changes it only if you say yes.

The skill reads `personal.md` on every use. Your rules apply to everything the agent writes for you, including its replies, and win over the style rules, including the dash rule. They never override the rule against inventing facts. Re-running the install `cp` leaves `personal.md` in place, and the repo's `.gitignore` keeps it out of commits.

## Where it came from

slop-mop merges three earlier skills:

- [humanizer](https://github.com/blader/humanizer) by blader, which ranks AI writing patterns by strength and explains why models produce them.
- [stop-slop](https://github.com/hardikpandya/stop-slop) by Hardik Pandya, which adds the rules against false agency ("the decision emerged") and vague declaratives ("the implications are significant").
- [no-ai-slop](https://github.com/petergyang/no-ai-slop) by Peter Yang, which adds the detect mode, the minimum edit, the portability test, and protecting the specific number.

The pattern list itself traces back to Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).

slop-mop drops the parts of those skills that pull toward punchy or opinionated copy: blanket bans on adverbs and passive voice, scoring rubrics, and instructions to preserve edge and profanity. It adds rules for two things none of them covered: writing for a reader outside the field, and writing about your own work without praising it.

## License

MIT, same as the skills it is built from.
