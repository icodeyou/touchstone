#!/bin/sh

missing=""
[ -d .ai ] || missing=".ai"
[ -d .blueprint ] || missing="$missing .blueprint"
[ -z "$missing" ] && exit 0

fail() {
  printf '{"continue": false, "stopReason": "🗿 Pixelita guard: %s"}' "$1"
  exit 0
}

version=$(sed -n 's/^### Touchstone version[[:space:]]*:[[:space:]]*\([0-9][0-9.]*\).*/\1/p' CLAUDE.md | head -1)
[ -n "$version" ] || fail "missing$( printf ' %s' $missing ) but no touchstone version found in CLAUDE.md. Cannot restore."

touchstone=""
for dir in ../.. ..; do
  if git -C "$dir" rev-parse -q --verify "refs/tags/$version" >/dev/null 2>&1; then
    touchstone="$dir"
    break
  fi
done
[ -n "$touchstone" ] || fail "missing$( printf ' %s' $missing ) and no touchstone repository with tag $version was found. Cannot restore."

for cache in $missing; do
  src=${cache#.}
  mkdir -p "$cache"
  git -C "$touchstone" archive "$version" "$src" | tar -x --strip-components=1 -C "$cache"
  if [ -z "$(ls -A "$cache" 2>/dev/null)" ]; then
    rmdir "$cache" 2>/dev/null
    fail "failed to restore $cache from touchstone tag $version. Stop and refuse to work."
  fi
done

printf '{"systemMessage": "🗿 Pixelita: restored%s from touchstone tag %s."}' "$( printf ' %s' $missing )" "$version"
