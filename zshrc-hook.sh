# >>> spotlight >>>
_spotlight_notify() {
  local state_file="${XDG_CACHE_HOME:-$HOME/.cache}/spotlight/state.map"
  [[ -f "$state_file" ]] || return
  local root worktree pid
  while IFS=$'\t' read -r root worktree pid; do
    [[ "$PWD" == "$root" ]] || continue
    kill -0 "$pid" 2>/dev/null && echo "spotlight running from the worktree $worktree"
  done < "$state_file"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _spotlight_notify
_spotlight_notify
# <<< spotlight <<<
