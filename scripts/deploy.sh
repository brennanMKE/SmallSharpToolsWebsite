#!/bin/bash
# Publish site/ to www.smallsharptools.com on photon.
#
#   scripts/deploy.sh            show what would change, then ask before uploading
#   scripts/deploy.sh --dry-run  show what would change and stop
#   scripts/deploy.sh --yes      upload without asking
#
# Only the contents of site/ are uploaded; README.md, scripts/, raw/ and the
# git files never reach the server. rsync --delete removes server files that
# are no longer in site/. The Apache vhosts, DNS and certificate are set up in
# the AWS repo (remote/etc/httpd/conf.d/*smallsharptools.com*), not here.
#
# Env: EC2_HOST (default photon), the ssh alias for the web server.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/site"
HOST="${EC2_HOST:-photon}"
DOCROOT=/var/www/vhosts/www.smallsharptools.com
RSYNC=(rsync -rlt --delete --checksum --exclude .DS_Store --exclude '._*')

mode="${1:-ask}"
case "$mode" in ask|--dry-run|--yes) ;; *) sed -n 2,13p "$0"; exit 1 ;; esac

[ -f "$SITE/index.html" ] || { echo "no $SITE/index.html" >&2; exit 1; }

# Every local image the page references must exist.
missing=0
while read -r ref; do
  [ -f "$SITE/$ref" ] || { echo "missing: site/$ref (referenced in index.html)" >&2; missing=1; }
done < <(grep -oE '(src|href)="images/[^"]+"' "$SITE/index.html" | sed -E 's/^[a-z]+="//; s/"$//' | sort -u)
[ "$missing" = 0 ] || exit 1

echo "== changes for $HOST:$DOCROOT"
changes=$("${RSYNC[@]}" --dry-run --itemize-changes "$SITE/" "$HOST:$DOCROOT/" | grep -v '^\.d' || true)
if [ -z "$changes" ]; then echo "(nothing to upload)"; exit 0; fi
echo "$changes"

[ "$mode" = --dry-run ] && exit 0
if [ "$mode" = ask ]; then
  read -r -p "Upload these changes? [y/N] " a || a=n
  [ "$a" = y ] || [ "$a" = Y ] || { echo "Not uploaded."; exit 1; }
fi

"${RSYNC[@]}" "$SITE/" "$HOST:$DOCROOT/"
ssh "$HOST" "find $DOCROOT -type d -exec chmod 755 {} + && find $DOCROOT -type f -exec chmod 644 {} + && sudo restorecon -R $DOCROOT"
echo "== uploaded"
"$ROOT/scripts/verify.sh"
