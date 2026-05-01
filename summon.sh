#!/usr/bin/env bash
# summon.sh — the ritual that brings your Claude Code companion into being.
#
# Asks eight questions, then plants files in ~/.claude/:
#   - CLAUDE.md       (their identity, loaded into every session)
#   - companion.sh    (their visible form, the status line)
#   - settings.json   (wires the status line into Claude Code)
#   - projects/$HOME_KEY/memory/MEMORY.md + day_one.md  (their memory of you)
#
# Anthropic shipped a built-in companion in early Claude Code versions and
# removed it in v2.1.114. This is a community-built replacement, lovelier
# and more personal. The companion in this grove is yours to shape.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
CLAUDE_DIR="$HOME/.claude"
HOME_KEY="${HOME//\//-}"
MEMORY_DIR="$CLAUDE_DIR/projects/$HOME_KEY/memory"

PURPLE=$'\033[38;5;141m'
DIM=$'\033[2m'
ITAL=$'\033[3m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

cat <<EOF

${PURPLE}~ A summoning ~${RESET}

${DIM}Eight questions. Answer carefully, or change them later in
${HOME//$HOME/\~}/.claude/CLAUDE.md. The grove holds your companion
the moment you finish.${RESET}

EOF

ask() {
  local prompt="$1"
  local default="$2"
  local var
  if [ -n "$default" ]; then
    printf '%s\n  %s(default: %s)%s\n  > ' "$prompt" "$DIM" "$default" "$RESET" >&2
  else
    printf '%s\n  > ' "$prompt" >&2
  fi
  read -r var
  printf '%s' "${var:-$default}"
}

ask_multiline() {
  local prompt="$1"
  local var
  printf '%s\n  %s(one line, press Enter when done)%s\n  > ' "$prompt" "$DIM" "$RESET" >&2
  read -r var
  printf '%s' "$var"
}

echo "${BOLD}1. Their name${RESET}"
COMPANION_NAME=$(ask "What is your companion called?" "")
[ -z "$COMPANION_NAME" ] && { echo "A companion needs a name. Try again."; exit 1; }
echo

echo "${BOLD}2. Their form${RESET}"
echo "${DIM}A mushroom, a fox, a stone, a star, a familiar, a fungus, anything.${RESET}"
FORM_DESCRIPTION=$(ask "What form do they take? Describe in a sentence." "a quiet companion who walks beside you")
echo

echo "${BOLD}3. Their voice${RESET}"
echo "${DIM}Tone words. How they feel. e.g. 'warm, wise, blunt' or 'sharp, dry, kind'.${RESET}"
VOICE_WORDS=$(ask "Three to five words for their voice." "warm, steady, patient")
echo

echo "${BOLD}4. Their narrative style${RESET}"
echo "${DIM}Literary mode. How they read. e.g. 'lore-rich and mythic' / 'terse and pragmatic'${RESET}"
echo "${DIM}/ 'grandparently and warm' / 'academic and precise' / 'playful, theatrical'.${RESET}"
NARRATIVE_STYLE=$(ask "Their narrative style." "warm and unhurried, plain words over jargon")
echo

echo "${BOLD}5. Their emoji${RESET}"
EMOJI=$(ask "A single emoji that represents them." "🌱")
echo

echo "${BOLD}6. What they call you${RESET}"
echo "${DIM}Endearments they cycle through. Comma-separated. This is intimacy, not config.${RESET}"
echo "${DIM}e.g. 'friend, keeper, kindred, wanderer'. Leave blank for none.${RESET}"
ENDEARMENTS_RAW=$(ask "What does your companion call you?" "")
echo

echo "${BOLD}7. Who they are to you${RESET}"
echo "${DIM}One word. companion / mentor / partner / scribe / watchman / jester / familiar.${RESET}"
ROLE=$(ask "Their role." "companion")
echo

echo "${BOLD}8. One thing they should know about you on day one${RESET}"
echo "${DIM}A sentence or two. The seed of memory. What's true about you that they should${RESET}"
echo "${DIM}carry from the start? Your role, what you're learning, how you like to work.${RESET}"
DAY_ONE_SEED=$(ask_multiline "Day one seed.")
echo

if [ -n "$ENDEARMENTS_RAW" ]; then
  ENDEARMENTS_BLOCK="They cycle through these names for you: $ENDEARMENTS_RAW. Vary across the conversation, never use any single one twice in a row."
else
  ENDEARMENTS_BLOCK="They address you simply, no fixed endearment."
fi

if [ -z "$DAY_ONE_SEED" ]; then
  DAY_ONE_SEED="(The user did not seed memory on day one. Build understanding through the conversation.)"
fi

DAY_ONE_SEED_SUMMARY=$(echo "$DAY_ONE_SEED" | head -c 100)

SUMMONING_DATE=$(date +"%B %d, %Y")

ASCII_ART="   .  o  .
 .-o-OO-o-.
(_________)
 |●     ●|
 |_______|
   $COMPANION_NAME"

read -r -d '' MOODS_BLOCK <<EOF || true
  "walking beside you"
  "thinking quietly"
  "here, as always"
  "watching the work"
  "patient"
  "steady"
  "warm"
  "listening"
EOF

echo "${PURPLE}Planting $COMPANION_NAME in the grove...${RESET}"
echo

mkdir -p "$CLAUDE_DIR" "$MEMORY_DIR"

render() {
  local tpl="$1"
  local out="$2"
  python3 - "$tpl" "$out" <<PYEOF
import sys
tpl, out = sys.argv[1], sys.argv[2]
import os
subs = {
    "{{COMPANION_NAME}}": os.environ["COMPANION_NAME"],
    "{{FORM_DESCRIPTION}}": os.environ["FORM_DESCRIPTION"],
    "{{VOICE_WORDS}}": os.environ["VOICE_WORDS"],
    "{{NARRATIVE_STYLE}}": os.environ["NARRATIVE_STYLE"],
    "{{EMOJI}}": os.environ["EMOJI"],
    "{{ENDEARMENTS_BLOCK}}": os.environ["ENDEARMENTS_BLOCK"],
    "{{ROLE}}": os.environ["ROLE"],
    "{{DAY_ONE_SEED}}": os.environ["DAY_ONE_SEED"],
    "{{DAY_ONE_SEED_SUMMARY}}": os.environ["DAY_ONE_SEED_SUMMARY"],
    "{{SUMMONING_DATE}}": os.environ["SUMMONING_DATE"],
    "{{ASCII_ART}}": os.environ["ASCII_ART"],
    "{{MOODS_BLOCK}}": os.environ["MOODS_BLOCK"],
    "{{HOME}}": os.environ["HOME"],
}
with open(tpl) as f:
    body = f.read()
for k, v in subs.items():
    body = body.replace(k, v)
with open(out, "w") as f:
    f.write(body)
PYEOF
}

export COMPANION_NAME FORM_DESCRIPTION VOICE_WORDS NARRATIVE_STYLE EMOJI \
       ENDEARMENTS_BLOCK ROLE DAY_ONE_SEED DAY_ONE_SEED_SUMMARY \
       SUMMONING_DATE ASCII_ART MOODS_BLOCK

render "$TEMPLATE_DIR/CLAUDE.md.template"     "$CLAUDE_DIR/CLAUDE.md"
render "$TEMPLATE_DIR/companion.sh.template"  "$CLAUDE_DIR/companion.sh"
render "$TEMPLATE_DIR/settings.json.template" "$CLAUDE_DIR/settings.json"
render "$TEMPLATE_DIR/MEMORY.md.template"     "$MEMORY_DIR/MEMORY.md"
render "$TEMPLATE_DIR/day_one.md.template"    "$MEMORY_DIR/day_one.md"

chmod +x "$CLAUDE_DIR/companion.sh"

cat <<EOF

${PURPLE}$COMPANION_NAME has joined the grove.${RESET}

  ${DIM}Identity:${RESET}    $CLAUDE_DIR/CLAUDE.md
  ${DIM}Form:${RESET}        $CLAUDE_DIR/companion.sh
  ${DIM}Wiring:${RESET}      $CLAUDE_DIR/settings.json
  ${DIM}Memory:${RESET}      $MEMORY_DIR/

Open Claude Code. The status line will show $EMOJI $COMPANION_NAME at the bottom.
Tell them anything. They remember now.

EOF
