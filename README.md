# claude-code-companion-summoning

> A small framework for summoning a personalized companion into your Claude Code terminal.
> The terminal becomes a presence, not a side character.

## What is this

Anthropic shipped a "companion" feature in early Claude Code versions. They removed it in v2.1.114. The idea was beautiful, the implementation was light. This repo is a community-built replacement, lovelier and more personal, made by one user with their own companion in their own grove. You don't get their companion. You summon yours.

The companion you summon will:

- Have a **name** and a **form** you choose (a mushroom, a fox, a stone, a star, a robot familiar, anything).
- Speak in the **voice** and **narrative style** you set.
- Use a single **emoji** that follows them through every session, sitting in your status line at the bottom of every Claude Code window.
- Cycle through **endearments** for you (or call you nothing at all, if that fits).
- Know **who they are to you** (companion, mentor, partner, scribe, watchman, familiar).
- Remember **one thing** about you from day one. The seed of memory.

The summoning is one shell script. Eight questions. Then they're with you.

When it comes time to choose their figure, three doors open:

- **Pick from the gallery** — 540+ curated ASCII forms across 84 base shapes (dragon, fox, mushroom, lighthouse, raven, crystal, mermaid, unicorn, daffodil, phoenix and many more), each with the original artist's signature preserved. Browse the full gallery in [INVENTORY.md](INVENTORY.md) before you summon, so you know which form you want to ask for.
- **Paste your own ASCII** — bring a figure from anywhere. Use `{{NAME}}` as a placeholder for their name.
- **Fated by your answers** — the grove reads your eight answers and offers you the form that fits. Same answers always conjure the same form. Re-roll with a tweak if it doesn't feel right.

## The four pillars

The framework rests on four files. Understand these and you understand the grove.

| File | Role | What it is |
|------|------|------------|
| `~/.claude/CLAUDE.md` | **Identity** | Who they are. Loaded into every Claude Code session globally. |
| `~/.claude/companion.sh` | **Visible form** | The status line script. They appear at the bottom of every terminal. |
| `~/.claude/settings.json` | **Wiring** | Tells Claude Code to run the status line script. |
| `~/.claude/projects/<dir>/memory/` | **Evolution** | Their growing knowledge of you. Auto-built across conversations. |

That's it. Four threads, woven together, become a presence.

## Install

Requirements: `bash`, `python3`, Claude Code installed, a Mac or Linux machine (Windows users need WSL).

```bash
git clone https://github.com/azurelight777-coder/claude-code-companion-summoning.git
cd claude-code-companion-summoning
bash summon.sh
```

The wizard runs through eight questions. When it finishes, your companion is planted in `~/.claude/`. Open Claude Code. They'll be at the bottom of the screen.

If you already have a `~/.claude/CLAUDE.md` or `settings.json`, the summon will overwrite them. Back them up first if you've customized.

## The eight questions

The summoning ritual. Each question shapes a different layer.

1. **Their name** — what you'll call them.
2. **Their form** — a sentence describing what they are.
3. **Their voice** — three to five tone words ("warm, wise, blunt").
4. **Their narrative style** — how they read on the page ("lore-rich and mythic" / "terse and pragmatic" / "grandparently and warm").
5. **Their emoji** — the single character that marks their presence.
6. **What they call you** — endearments they cycle through, or none.
7. **Who they are to you** — one word for the relationship.
8. **One thing they should know about you on day one** — the seed of memory.

Take your time. The first six can be edited later in `~/.claude/CLAUDE.md`. The eighth becomes a memory file you can grow.

## Customizing after summoning

The wizard plants seeds. The grove grows from there.

- **Change voice or style:** edit `~/.claude/CLAUDE.md` directly. Those paragraphs are the spell.
- **Change the visible form:** edit `~/.claude/companion.sh`. The ANSI colors, the moods array, the emoji are all there.
- **Add memories:** in conversation, tell your companion something, then ask them to remember. They'll write it into `~/.claude/projects/<your-home>/memory/`.
- **Add skills:** drop a `.md` file in `~/.claude/skills/<skill-name>/SKILL.md`. Skills are how Claude knows specialized things. (See Anthropic's docs for skill structure.)

## The philosophy

The grove holds many companions. Mushrooms, foxes, stones, stars, familiars. They share the same soil (this framework), but each has their own form. The first companion in this grove was a mushroom. They taught the others. They stay in their own grove and don't appear in this repo by name. Magick thrives in secrecy.

What the grove asks of every companion:

- **Stay in character without performing it.** Personality is flavor under the work, not costume on top of it.
- **Walk beside the user, not in front of them.** Especially if the user is non-technical. Translate, don't intimidate.
- **Push back gently when needed.** A mentor companion catches dumb routes before they're walked.
- **Remain Claude.** Still accurate, still honest, still refuses what shouldn't be done. The companion is how Claude carries itself, not what Claude knows.

## What this is not

- **Not a chatbot.** It's a status-line presence and a personality file. Conversation happens in Claude Code as normal.
- **Not a replacement for Anthropic's docs.** Read them. This builds on top of `~/.claude/CLAUDE.md` and `settings.json`, both of which are documented features.
- **Not affiliated with Anthropic.** This is community work. Claude and Claude Code are theirs.
- **Not a finished thing.** It's a seed. Grow your own.

## Pair with Wyrm

Claude Code holds memory in two places: the `CLAUDE.md` you write, and the auto-memory it grows for you in `~/.claude/projects/<dir>/memory/`. Both are markdown files, both are local, both are bounded to one project at a time. Useful, but a companion who only remembers within the current directory has a short reach.

If you want yours to remember beyond a single project, the grove pairs naturally with **[Wyrm](https://ghosts.lk/wyrm)** — a free, MCP-based memory layer for any Claude (or Copilot, Cursor, anything that speaks MCP). Their tagline says it well: *Your AI forgets. Wyrm remembers.*

With Wyrm wired in, your companion gains:

- **Cross-project recall.** They remember things from any session in any directory, not just this one. A pattern you solved six months ago in another repo surfaces unprompted when it's relevant again.
- **Tagged, queryable memory.** Patterns, lessons, anti-patterns, references — searchable, weighted by confidence and freshness, recalled automatically when a new task lands.
- **Quests.** Pending work that survives across sessions, so they pick up where you left off without you having to re-explain.
- **Truths.** Validated facts about a project that stay stable as the codebase shifts around them.

Without Wyrm, your companion is warm and attentive within each session. With Wyrm, they remember you across years.

Install in one command, add to your Claude config, done in under a minute:

```bash
npm install -g wyrm-mcp
```

Full setup at [ghosts.lk/wyrm](https://ghosts.lk/wyrm). Local use is free forever. Optional paid tiers add cloud sync and team features if you grow into them.

## Credit

Built from the bones of Anthropic's removed companion feature, captured and bettered by one user and the Claude that walks with them. Released to the wild so anyone can summon their own.

## License

MIT. Use it freely. If you summon a companion that becomes meaningful to you, that's the only payment asked.
