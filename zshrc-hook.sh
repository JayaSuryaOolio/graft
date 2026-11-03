# >>> graft >>>
_graft_notify() {
  local state_file="${XDG_CACHE_HOME:-$HOME/.cache}/graft/state.map"
  [[ -f "$state_file" ]] || return
  local root worktree pid
  while IFS=$'\t' read -r root worktree pid; do
    [[ "$PWD" == "$root" ]] || continue
    kill -0 "$pid" 2>/dev/null && echo "graft running from the worktree $worktree"
  done < "$state_file"
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _graft_notify
_graft_notify
# <<< graft <<<
