# graft

Mirror a git worktree into its repo's root checkout in the background, so
path-bound tools (macOS Spotlight, Finder, anything hardcoded to a fixed
directory) always see whichever worktree you're actively working in —
handy when you juggle many worktrees (e.g. Conductor workspaces) off a
single main clone.

`graft start` continuously syncs the current worktree's tracked and
working-tree files (via `fswatch` + `rsync`, skipping `.git` and anything
`.gitignore`d) into the repo's root checkout, and prints that root path.
`graft stop` tears the mirror down and restores the root checkout to
its own clean state.

## Install

```sh
git clone <this-repo> graft && cd graft && ./install.sh
```

This installs the `graft` command to `~/.local/bin` (override with
`GRAFT_INSTALL_DIR`), checks for `fswatch`/`rsync` and offers to
install any that are missing (via Homebrew on macOS; apt/dnf/yum/pacman/apk
on Linux), and appends a `chpwd` hook to `~/.zshrc` that prints
`graft running from the worktree {worktree}` whenever you `cd` into
(or open a new shell already sitting in) a repo root with an active
mirror.

Restart your shell (or `source ~/.zshrc`) after installing.

## Usage

```sh
graft start          # from inside a worktree — mirrors it into the repo root
graft list           # show every repo with an active mirror
graft stop [root]    # stop mirroring (defaults to the current repo)
```

Only one worktree can mirror into a given repo root at a time — starting
a second one for the same root fails with an error; run `graft stop`
first. Different repos can each have their own independent mirror running.

## Requirements

- zsh
- git
- `rsync`
- `fswatch` (macOS: `brew install fswatch`; Debian/Ubuntu: `apt-get install
  fswatch`; Fedora/RHEL: `dnf install fswatch`; Arch: `pacman -S fswatch`)
