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

# Read the gallery into parallel arrays. Format: keywords:filename:description.
GALLERY_FILES=()
GALLERY_KEYWORDS=()
GALLERY_DESCRIPTIONS=()
while IFS=':' read -r kw file desc; do
  [[ "$kw" =~ ^# ]] && continue
  [ -z "$kw" ] && continue
  GALLERY_KEYWORDS+=("$kw")
  GALLERY_FILES+=("$file")
  GALLERY_DESCRIPTIONS+=("$desc")
done < "$TEMPLATE_DIR/forms/gallery.txt"

# Unique filenames preserved in order, for the browse view.
UNIQUE_FILES=()
declare -A SEEN_FILES=()
for f in "${GALLERY_FILES[@]}"; do
  if [ -z "${SEEN_FILES[$f]:-}" ]; then
    UNIQUE_FILES+=("$f")
    SEEN_FILES[$f]=1
  fi
done
UNIQUE_FILES+=("default")

match_form_to_file() {
  local desc_lower
  desc_lower=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  local i
  for i in "${!GALLERY_KEYWORDS[@]}"; do
    IFS='|' read -ra patterns <<< "${GALLERY_KEYWORDS[$i]}"
    local p
    for p in "${patterns[@]}"; do
      if printf '%s' "$desc_lower" | grep -wq -- "$p"; then
        printf '%s' "${GALLERY_FILES[$i]}"
        return
      fi
    done
  done
  printf 'default'
}

description_for_file() {
  local target="$1"
  local i
  for i in "${!GALLERY_FILES[@]}"; do
    if [ "${GALLERY_FILES[$i]}" = "$target" ]; then
      printf '%s' "${GALLERY_DESCRIPTIONS[$i]}"
      return
    fi
  done
  printf 'a neutral sigil'
}

render_form() {
  local file="$1"
  sed "s/{{NAME}}/$COMPANION_NAME/g" "$TEMPLATE_DIR/forms/${file}.txt"
}

show_browse() {
  echo "${PURPLE}=== The Gallery ===${RESET}"
  echo
  local i=1
  local f
  for f in "${UNIQUE_FILES[@]}"; do
    local desc
    desc=$(description_for_file "$f")
    [ "$f" = "default" ] && desc="a neutral sigil for forms outside the gallery"
    printf '  %2d. %s %s(%s)%s\n' "$i" "$f" "$DIM" "$desc" "$RESET"
    i=$((i + 1))
  done
  echo
}

# Pick a "fated" form by hashing the user's eight answers. Same answers
# always produce the same form — feels like a reading, not a coin flip.
fated_form() {
  local seed="$COMPANION_NAME|$FORM_DESCRIPTION|$VOICE_WORDS|$NARRATIVE_STYLE|$EMOJI|$ENDEARMENTS_RAW|$ROLE|$DAY_ONE_SEED"
  local hash
  hash=$(printf '%s' "$seed" | cksum | awk '{print $1}')
  local idx=$((hash % ${#UNIQUE_FILES[@]}))
  printf '%s' "${UNIQUE_FILES[$idx]}"
}

MATCHED_FORM=$(match_form_to_file "$FORM_DESCRIPTION")
ASCII_ART=""

# Top-level mode menu. Three doors: gallery / your own / fated by answers.
echo "${BOLD}Their figure${RESET}"
echo "${DIM}Three doors to your companion's shape.${RESET}"
echo
echo "  ${BOLD}1${RESET}  Pick from the gallery   ${DIM}(28 curated forms)${RESET}"
echo "  ${BOLD}2${RESET}  Paste your own ASCII    ${DIM}(any figure you like)${RESET}"
echo "  ${BOLD}3${RESET}  Fated by your answers   ${DIM}(the grove decides)${RESET}"
echo
printf '  > '
read -r MODE_CHOICE
echo

case "$MODE_CHOICE" in
  3)
    MATCHED_FORM=$(fated_form)
    while true; do
      desc=$(description_for_file "$MATCHED_FORM")
      ASCII_ART=$(render_form "$MATCHED_FORM")
      echo "${PURPLE}The grove offers you...${RESET}"
      echo "${DIM}Form: ${MATCHED_FORM} (${desc})${RESET}"
      echo
      echo "$ASCII_ART"
      echo
      echo "${DIM}[Enter] accept   [r] re-roll with a tweak   [g] go to gallery instead${RESET}"
      printf '  > '
      read -r FATE_CHOICE
      case "$FATE_CHOICE" in
        r|R)
          DAY_ONE_SEED="${DAY_ONE_SEED}."
          MATCHED_FORM=$(fated_form)
          echo
          continue
          ;;
        g|G)
          ASCII_ART=""
          break
          ;;
        *)
          break
          ;;
      esac
    done
    ;;
  2)
    echo "${DIM}Paste your figure. Use {{NAME}} as a placeholder for their name.${RESET}"
    echo "${DIM}When done, press Enter on an empty line.${RESET}"
    printf '  > '
    CUSTOM_ART=""
    while IFS= read -r line; do
      [ -z "$line" ] && break
      CUSTOM_ART+="$line"$'\n'
      printf '  > '
    done
    if [ -n "$CUSTOM_ART" ]; then
      CUSTOM_ART="${CUSTOM_ART%$'\n'}"
      ASCII_ART=$(printf '%s' "$CUSTOM_ART" | sed "s/{{NAME}}/$COMPANION_NAME/g")
      echo
      echo "${PURPLE}Using your custom figure.${RESET}"
    else
      echo "${DIM}No figure pasted, falling back to a neutral sigil.${RESET}"
      ASCII_ART=$(render_form default)
    fi
    ;;
esac

# If we don't have ASCII_ART yet (mode 1, blank choice, or 'g' from fate), run the gallery loop.
if [ -z "$ASCII_ART" ]; then
  while true; do
    ASCII_ART=$(render_form "$MATCHED_FORM")
    desc=$(description_for_file "$MATCHED_FORM")

    echo "${BOLD}Their figure${RESET}"
    if [ "$MATCHED_FORM" = "default" ]; then
      echo "${DIM}No matching shape in the gallery, using a neutral sigil.${RESET}"
    else
      echo "${DIM}Form: ${MATCHED_FORM} (${desc})${RESET}"
    fi
    echo
    echo "$ASCII_ART"
    echo
    echo "${DIM}[Enter] keep this   [b] browse all   [p] paste your own   [f] let fate decide${RESET}"
    printf '  > '
    read -r CHOICE

    case "$CHOICE" in
      b|B)
        show_browse
        printf '  Pick a number 1-%d (or [Enter] to go back): ' "${#UNIQUE_FILES[@]}"
        read -r PICK
        if [[ "$PICK" =~ ^[0-9]+$ ]] && [ "$PICK" -ge 1 ] && [ "$PICK" -le "${#UNIQUE_FILES[@]}" ]; then
          MATCHED_FORM="${UNIQUE_FILES[$((PICK - 1))]}"
        fi
        echo
        continue
        ;;
      p|P)
        echo "${DIM}Paste your figure. Use {{NAME}} as a placeholder for their name.${RESET}"
        echo "${DIM}When done, press Enter on an empty line.${RESET}"
        printf '  > '
        CUSTOM_ART=""
        while IFS= read -r line; do
          [ -z "$line" ] && break
          CUSTOM_ART+="$line"$'\n'
          printf '  > '
        done
        if [ -n "$CUSTOM_ART" ]; then
          CUSTOM_ART="${CUSTOM_ART%$'\n'}"
          ASCII_ART=$(printf '%s' "$CUSTOM_ART" | sed "s/{{NAME}}/$COMPANION_NAME/g")
          echo
          echo "${PURPLE}Using your custom figure.${RESET}"
        fi
        break
        ;;
      f|F)
        MATCHED_FORM=$(fated_form)
        echo
        continue
        ;;
      *)
        break
        ;;
    esac
  done
fi
echo

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
