#!/bin/bash
# Turn a full-size photo or screenshot (e.g. from raw/) into a web image in
# site/images/: JPEG, at most 1200 px on the long side.
#
#   scripts/add-image.sh raw/GlowLamp.png glowlamp
#     -> site/images/glowlamp.jpg
set -euo pipefail
[ $# -eq 2 ] || { sed -n 2,7p "$0"; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
src="$1"; name="${2%.jpg}"
[ -f "$src" ] || { echo "not found: $src" >&2; exit 1; }
out="$ROOT/site/images/$name.jpg"
sips -s format jpeg -s formatOptions 80 -Z 1200 "$src" --out "$out" >/dev/null
sips -g pixelWidth -g pixelHeight "$out" | awk 'NR>1{printf "%s ", $2} END{print ""}' | sed "s#^#$(basename "$out"): #; s# \$# px, $(du -h "$out" | cut -f1)#"
