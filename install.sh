#!/usr/bin/env bash
# Installs the `graft` command and its zshrc hook, and checks/installs
# its dependencies (fswatch, rsync) on macOS and Linux.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${GRAFT_INSTALL_DIR:-$HOME/.local/bin}"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
OS="$(uname -s)"

install_dep() {
  local name="$1"
  command -v "$name" >/dev/null 2>&1 && return 0

  echo "graft: '$name' is required but not installed."
  read -r -p "Install $name now? [y/N] " reply
  case "$reply" in
    [yY]*) ;;
    *)
      echo "Skipping $name — 'graft start' will fail without it. Install it manually later."
      return 1
      ;;
  esac

  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew not found. Install it from https://brew.sh, then run: brew install $name"
      return 1
    fi
    brew install "$name"
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y "$name"
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y "$name"
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y "$name"
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm "$name"
    elif command -v apk >/dev/null 2>&1; then
      sudo apk add "$name"
    else
      echo "Unrecognized package manager — install '$name' manually."
      return 1
    fi
  else
    echo "Unsupported OS '$OS' — install '$name' manually."
    return 1
  fi
}

mkdir -p "$INSTALL_DIR"
install -m 755 "$REPO_DIR/bin/graft" "$INSTALL_DIR/graft"
echo "Installed graft to $INSTALL_DIR/graft"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Warning: $INSTALL_DIR is not on your PATH. Add it in your shell profile to run 'graft' directly." ;;
esac

install_dep fswatch || true
install_dep rsync || true

MARKER="# >>> graft >>>"
if [[ -f "$ZSHRC" ]] && grep -qF "$MARKER" "$ZSHRC"; then
  echo "graft hook already present in $ZSHRC, skipping"
else
  { echo ""; cat "$REPO_DIR/zshrc-hook.sh"; } >> "$ZSHRC"
  echo "Added graft chpwd hook to $ZSHRC"
fi

echo
echo "Done. Run 'source $ZSHRC' (or open a new terminal), then:"
echo "  graft start        # from inside a worktree"
echo "  graft list"
echo "  graft stop [root]"
