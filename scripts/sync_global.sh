#!/usr/bin/env bash
#
# sync_global.sh — Install the repository's skills and their rules into the
# global locations each tool reads.
#
# Usage (always from a clone; piping it from curl is not supported):
#   ./scripts/sync_global.sh          # from the root of the clone
#   ~/skills/scripts/sync_global.sh   # from any directory
#
# The canonical clone lives in ~/skills, one to one with the repository, the
# same way incognia/rules lives in ~/rules.
#
# What it does:
#   1. Mirrors every .agents/skills/<name>/ into the global skills directory
#      (files deleted inside a skill are pruned) and removes skills it
#      installed earlier that no longer exist in the repository.
#   2. Symlinks ~/.claude/commands/<name>.md to each installed SKILL.md, only
#      for skills from this repository, never overwriting a command it does
#      not own, and removes dangling links into the skills directory.
#   3. When Antigravity CLI is installed, symlinks each installed skill
#      directory into ~/.gemini/antigravity-cli/skills/ (it does not read
#      ~/.agents/skills) and removes dangling links there.
#   4. When the clone is not ~/skills itself, copies cot/, rulesets/ and
#      scripts/ to ~/skills, which is where the skills read them from.
#
# Author: Rodrigo Álvarez (incognia) <incognia@gmail.com>
# Licence: MIT (see LICENSE)

set -Eeuo pipefail

trap 'echo "✗ Synchronisation aborted: command failed at line $LINENO." >&2' ERR

die() {
    echo "Error: $*" >&2
    exit 1
}

CLONE_HINT="git clone git@github.com:onlyfights420/skills.git ~/skills && ~/skills/scripts/sync_global.sh"

# --- Locate the repository from the script's own path ---
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
if [ ! -f "$SCRIPT_PATH" ]; then
    die "this script must be run from a clone of the repository, not piped from curl.
  $CLONE_HINT"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -d "$REPO_ROOT/.agents/skills" ] || [ ! -f "$REPO_ROOT/scripts/sync_global.sh" ]; then
    die "$REPO_ROOT does not look like a clone of the skills repository.
  $CLONE_HINT"
fi

# --- Detect platform ---
case "$(uname -s)" in
    Darwin) PLATFORM="macos" ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
            PLATFORM="wsl"
        else
            PLATFORM="linux"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ;;
    *) PLATFORM="unknown" ;;
esac

echo "Platform: $PLATFORM"
echo "Repository: $REPO_ROOT"
echo ""

# Mirror a directory: the destination ends up identical to the source,
# including hidden files, and files removed from the source are deleted.
mirror_dir() {
    local src="$1" dst="$2" tmp
    if command -v rsync >/dev/null 2>&1; then
        mkdir -p "$dst"
        rsync -a --delete "$src/" "$dst/"
    else
        tmp="$(mktemp -d "$(dirname "$dst")/.sync.XXXXXX")"
        cp -R "$src/." "$tmp/"
        rm -rf "$dst"
        mv "$tmp" "$dst"
    fi
}

# --- Skills ---
SKILLS_SRC="$REPO_ROOT/.agents/skills"
SKILLS_DST="$HOME/.agents/skills"

echo "=== Skills ==="
mkdir -p "$SKILLS_DST"
# Own list, so it never mixes with the skills that incognia/rules installs.
MANAGED_SKILLS_FILE="$SKILLS_DST/.skills-managed-skills"

# Remove skills installed earlier by this script that left the repository.
if [ -f "$MANAGED_SKILLS_FILE" ]; then
    while IFS= read -r managed_skill || [ -n "$managed_skill" ]; do
        [ -z "$managed_skill" ] && continue
        case "$managed_skill" in */*|.|..) continue ;; esac
        if [ ! -d "$SKILLS_SRC/$managed_skill" ] && [ -e "$SKILLS_DST/$managed_skill" ]; then
            rm -rf "${SKILLS_DST:?}/$managed_skill"
            echo "  - removed obsolete skill: $managed_skill"
        fi
    done < "$MANAGED_SKILLS_FILE"
fi

TMP_MANAGED_SKILLS_FILE="$(mktemp "$SKILLS_DST/.skills-managed-skills.XXXXXX")"
SKILL_COUNT=0
for skill_dir in "$SKILLS_SRC"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    mirror_dir "${skill_dir%/}" "$SKILLS_DST/$skill_name"
    printf '%s\n' "$skill_name" >> "$TMP_MANAGED_SKILLS_FILE"
    SKILL_COUNT=$((SKILL_COUNT + 1))
    echo "  ✓ $skill_name"
done
mv "$TMP_MANAGED_SKILLS_FILE" "$MANAGED_SKILLS_FILE"
echo "  $SKILL_COUNT skills synchronised → $SKILLS_DST"
echo ""

# --- Claude Code ---
# ~/.claude/commands/<name>.md → installed SKILL.md, so Claude Code exposes
# /<name>. The link points at the copy in SKILLS_DST, not at the repository.
echo "=== Claude Code ==="

CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

# True when a symlink target lives inside the skills directory.
points_into_skills() {
    case "$1" in
        "$SKILLS_DST"/*) return 0 ;;
        *) return 1 ;;
    esac
}

CLAUDE_SKILL_COUNT=0
while IFS= read -r skill_name; do
    [ -z "$skill_name" ] && continue
    skill_src="$SKILLS_DST/$skill_name/SKILL.md"
    skill_link="$CLAUDE_COMMANDS_DIR/$skill_name.md"
    [ -f "$skill_src" ] || continue
    if [ -L "$skill_link" ]; then
        if ! points_into_skills "$(readlink "$skill_link")"; then
            echo "  ! $skill_name.md is a symlink not managed by this script; left untouched"
            continue
        fi
    elif [ -e "$skill_link" ]; then
        echo "  ! $skill_name.md already exists as a regular file; left untouched"
        continue
    fi
    ln -sfn "$skill_src" "$skill_link"
    CLAUDE_SKILL_COUNT=$((CLAUDE_SKILL_COUNT + 1))
    echo "  ✓ $skill_name.md → $skill_src"
done < "$MANAGED_SKILLS_FILE"

# Remove dangling links into the skills directory (skills that were removed).
for link in "$CLAUDE_COMMANDS_DIR"/*.md; do
    [ -L "$link" ] || continue
    if points_into_skills "$(readlink "$link")" && [ ! -e "$link" ]; then
        rm -f "$link"
        echo "  - removed dangling link: $(basename "$link")"
    fi
done
echo "  $CLAUDE_SKILL_COUNT skills linked → $CLAUDE_COMMANDS_DIR"
echo ""

# --- Antigravity CLI ---
# Antigravity CLI (agy) reads its global skills from
# ~/.gemini/antigravity-cli/skills/<name>/, so each installed skill is
# symlinked there, only when Antigravity CLI is installed.
AGY_HOME="$HOME/.gemini/antigravity-cli"
if [ -d "$AGY_HOME" ]; then
    echo "=== Antigravity CLI ==="
    AGY_SKILLS_DIR="$AGY_HOME/skills"
    mkdir -p "$AGY_SKILLS_DIR"

    AGY_SKILL_COUNT=0
    while IFS= read -r skill_name; do
        [ -z "$skill_name" ] && continue
        skill_src="$SKILLS_DST/$skill_name"
        skill_link="$AGY_SKILLS_DIR/$skill_name"
        [ -f "$skill_src/SKILL.md" ] || continue
        if [ -L "$skill_link" ]; then
            if ! points_into_skills "$(readlink "$skill_link")"; then
                echo "  ! $skill_name is a symlink not managed by this script; left untouched"
                continue
            fi
        elif [ -e "$skill_link" ]; then
            echo "  ! $skill_name already exists as a regular directory; left untouched"
            continue
        fi
        ln -sfn "$skill_src" "$skill_link"
        AGY_SKILL_COUNT=$((AGY_SKILL_COUNT + 1))
        echo "  ✓ $skill_name → $skill_src"
    done < "$MANAGED_SKILLS_FILE"

    for link in "$AGY_SKILLS_DIR"/*; do
        [ -L "$link" ] || continue
        if points_into_skills "$(readlink "$link")" && [ ! -e "$link" ]; then
            rm -f "$link"
            echo "  - removed dangling link: $(basename "$link")"
        fi
    done
    echo "  $AGY_SKILL_COUNT skills linked → $AGY_SKILLS_DIR"
    echo ""
fi

# --- Rules the skills read (cot, rulesets, scripts) ---
echo "=== Rules (cot, rulesets, scripts) ==="
SKILLS_HOME="$HOME/skills"

if [ "$REPO_ROOT" = "$(cd "$SKILLS_HOME" 2>/dev/null && pwd || echo "$SKILLS_HOME")" ]; then
    echo "  The clone is $SKILLS_HOME itself; nothing to copy."
elif [ -e "$SKILLS_HOME/.git" ]; then
    echo "  ! $SKILLS_HOME is another git checkout; not copying into it (update it with git pull)."
else
    for part in cot rulesets scripts; do
        mkdir -p "$SKILLS_HOME/$part"
        cp -R "$REPO_ROOT/$part/." "$SKILLS_HOME/$part/"
        echo "  ✓ $part → $SKILLS_HOME/$part"
    done
fi
echo ""

echo "Synchronisation complete."
