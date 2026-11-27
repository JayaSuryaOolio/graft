#!/usr/bin/env zsh
# Stack behaviour: start from two worktrees, stop pops and resumes the first.
# Run: zsh test/stack.zsh   (needs git, fswatch, rsync)
set -e
G="${0:A:h}/../bin/graft"
T=$(mktemp -d)
export XDG_CACHE_HOME="$T/cache"
trap 'cd /; (cd "$T/w2" 2>/dev/null && $G stop >/dev/null 2>&1); (cd "$T/w1" 2>/dev/null && $G stop >/dev/null 2>&1); rm -rf "$T"' EXIT

check() { [[ "$2" == "$3" ]] || { echo "FAIL: $1 (got '$2', want '$3')"; exit 1; }; }

git init -q "$T/main" && cd "$T/main"
echo base > f && git add f && git -c user.email=t@t -c user.name=t commit -qm i
git worktree add -q ../w1 -b b1 && git worktree add -q ../w2 -b b2
echo w1-content > ../w1/f; echo w2-content-longer > ../w2/f

(cd ../w1 && $G start >/dev/null)
check "w1 mirrored" "$(<f)" "w1-content"

(cd ../w2 && $G start >/dev/null)
check "w2 on top" "$(<f)" "w2-content-longer"
check "w1 paused" "$($G list | grep -c paused)" "1"

echo live-edit > ../w2/f; sleep 1.5
check "w2 watcher live" "$(<f)" "live-edit"

(cd ../w2 && $G stop >/dev/null)
check "w1 resumed" "$(<f)" "w1-content"
echo w1-edit-x > ../w1/f; sleep 1.5
check "w1 watcher live" "$(<f)" "w1-edit-x"

(cd ../w1 && $G stop >/dev/null)
check "root restored" "$(<f)" "base"
check "stack empty" "$($G list)" "no graft instances running"
echo "PASS"
