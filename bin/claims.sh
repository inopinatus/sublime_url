#!/bin/bash
#
# List LaunchServices registrations that claim the subl:// URL scheme,
# optionally deregister stale claims.

LSREGISTER="${LSREGISTER:-/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister}"

usage() {
  cat >&2 <<EOF
usage: $(basename -- "$0") [-d]
  -h: print this help message
  -d: deregister stale claims

List registered subl:// registered URL scheme claims.
EOF
  exit 1
}

clean=false
[ "$1" = "-h" ] && usage
[ "$1" = "-d" ] && clean=true

paths=$("$LSREGISTER" -dump | awk '
  /^-+$/                                     { blk=""; next }
                                             { blk = blk $0 "\n" }
  /claimed schemes:.*subl:|bindings:.*subl:/ {
    n = split(blk, L, "\n"); p = ""
    for (i = 1; i <= n; i++)
      if (L[i] ~ /^path:/) { line = L[i]; sub(/^path: */, "", line); sub(/ *\(0x[0-9a-f]+\) *$/, "", line); p = line }
    if (p != "") print p
  }' | sort -u)

if $clean; then
  echo "$paths" | while IFS= read -r p; do
    [ -n "$p" ] && [ ! -e "$p" ] || continue
    echo "Unregistering stale claim: $p"
    "$LSREGISTER" -u "$p"
  done
fi

echo "subl:// URL scheme claims in LaunchServices:"
if [ -z "$paths" ]; then
  echo "  (none)"
else
  echo "$paths" | while IFS= read -r p; do
    if [ -e "$p" ]; then echo "  [active] $p"; else echo "  [stale ] $p"; fi
  done
fi
