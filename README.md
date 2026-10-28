# spotlight

Mirror a git worktree into its repo's root checkout in the background, so
path-bound tools (macOS Spotlight, Finder, anything hardcoded to a fixed
directory) always see whichever worktree you're actively working in —
handy when you juggle many worktrees (e.g. Conductor workspaces) off a
single main clone.

`spotlight start` continuously syncs the current worktree's tracked and
working-tree files (via `fswatch` + `rsync`, skipping `.git` and anything
`.gitignore`d) into the repo's root checkout, and prints that root path.
`spotlight stop` tears the mirror down and restores the root checkout to
its own clean state.

## Install

```sh
git clone <this-repo> spotlight && cd spotlight && ./install.sh
```

This installs the `spotlight` command to `~/.local/bin` (override with
`SPOTLIGHT_INSTALL_DIR`), checks for `fswatch`/`rsync` and offers to
install any that are missing (via Homebrew on macOS; apt/dnf/yum/pacman/apk
on Linux), and appends a `chpwd` hook to `~/.zshrc` that prints
`spotlight running from the worktree {worktree}` whenever you `cd` into
(or open a new shell already sitting in) a repo root with an active
mirror.

Restart your shell (or `source ~/.zshrc`) after installing.

## Usage

```sh
spotlight start          # from inside a worktree — mirrors it into the repo root
spotlight list           # show every repo with an active mirror
spotlight stop [root]    # stop mirroring (defaults to the current repo)
```

Only one worktree can mirror into a given repo root at a time — starting
a second one for the same root fails with an error; run `spotlight stop`
first. Different repos can each have their own independent mirror running.

## Requirements

- zsh
- git
- `rsync`
- `fswatch` (macOS: `brew install fswatch`; Debian/Ubuntu: `apt-get install
  fswatch`; Fedora/RHEL: `dnf install fswatch`; Arch: `pacman -S fswatch`)
