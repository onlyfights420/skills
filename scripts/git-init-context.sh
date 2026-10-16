#!/usr/bin/env bash
set -euo pipefail

# git-init-context.sh
# Configures a repository for SSH (never HTTPS) with the identity of the person
# who works on it, read from ~/skills/.env (untracked; template in .env.example).
#
# Usage, from the repository root (or the empty folder to initialise):
#   git-init-context.sh [key] [remote_url] [branch]
#     key         SSH key in ~/.ssh/ (default: GIT_SSH_KEY from ~/skills/.env);
#                 a value containing / is used as a path
#     remote_url  SSH URL for origin (git@host:org/repo.git or ssh://...); optional
#     branch      default branch (default: main)
#   Example: git-init-context.sh "" git@github.com:onlyfights420/repo.git main
#
# Steps: git init (when the directory is not a repository yet), user.name and
# user.email, core.sshCommand with the key, default branch, and origin.

usage() {
  sed -n '8,14p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

[ "$#" -le 3 ] || usage

ENV_FILE="${SKILLS_ENV:-$HOME/skills/.env}"

# Read one KEY=value from the .env file without sourcing it, so no other
# setting (or secret) in the file is ever loaded or printed.
env_value() {
  local key="$1" line
  [ -f "$ENV_FILE" ] || return 0
  line="$(grep -E "^${key}=" "$ENV_FILE" | tail -n 1 || true)"
  line="${line#*=}"
  line="${line%\"}"
  line="${line#\"}"
  printf '%s' "$line"
}

NAME="$(env_value GIT_NAME)"
EMAIL="$(env_value GIT_EMAIL)"
DEFAULT_KEY="$(env_value GIT_SSH_KEY)"

if [ -z "$NAME" ] || [ -z "$EMAIL" ] || [ -z "$DEFAULT_KEY" ]; then
  echo "Missing GIT_NAME, GIT_EMAIL or GIT_SSH_KEY in $ENV_FILE." >&2
  echo "Copy ~/skills/.env.example to ~/skills/.env (mode 600) and fill in your identity." >&2
  exit 1
fi

KEY_NAME="${1:-}"
REMOTE_URL="${2:-}"
BRANCH="${3:-}"

KEY_NAME="${KEY_NAME:-$DEFAULT_KEY}"
BRANCH="${BRANCH:-main}"
case "$KEY_NAME" in
  */*) KEY="${KEY_NAME/#\~/$HOME}" ;;
  *) KEY="$HOME/.ssh/$KEY_NAME" ;;
esac

if ! git check-ref-format --branch "$BRANCH" >/dev/null 2>&1; then
  echo "Invalid branch name: $BRANCH" >&2
  exit 1
fi
if [ -n "$REMOTE_URL" ] && [[ ! "$REMOTE_URL" =~ ^(git@|ssh://) ]]; then
  echo "The remote must be an SSH URL (git@host:org/repo.git or ssh://...), not: $REMOTE_URL" >&2
  exit 1
fi

# --- Repository: initialise here, or require the root of an existing one ---
if top=$(git rev-parse --show-toplevel 2>/dev/null); then
  if [ "$(cd "$top" && pwd -P)" != "$(pwd -P)" ]; then
    echo "Run this from the repository root ($top), not from a subdirectory." >&2
    exit 1
  fi
else
  git init
fi

# --- Identity ---
git config user.name "$NAME"
git config user.email "$EMAIL"

# --- SSH key forced for this repository ---
if [ ! -f "$KEY" ]; then
  echo "WARNING: SSH key not found: $KEY (available keys: ls ~/.ssh/)" >&2
fi
git config core.sshCommand "ssh -i $(printf '%q' "$KEY") -o IdentitiesOnly=yes"

# --- Default branch ---
if git rev-parse --verify -q HEAD >/dev/null; then
  git branch -M "$BRANCH"
else
  # No commits yet: point HEAD at the new branch name.
  git symbolic-ref HEAD "refs/heads/$BRANCH"
fi

# --- Remote ---
if [ -n "$REMOTE_URL" ]; then
  if git remote get-url origin >/dev/null 2>&1; then
    git remote set-url origin "$REMOTE_URL"
  else
    git remote add origin "$REMOTE_URL"
  fi
fi

echo "=== CONFIGURATION ==="
echo "Identity: $(git config user.name) <$(git config user.email)>"
echo "SSH:      $(git config core.sshCommand)"
echo "Remote:   $(git remote get-url origin 2>/dev/null || echo '(not configured)')"
echo "Branch:   $(git symbolic-ref --short HEAD)"
echo "====================="
