#!/bin/bash
# Check www.smallsharptools.com and its redirects from the public internet.
# Exits non-zero if anything is off.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WWW=https://www.smallsharptools.com
fail=0

check() {  # check URL expected-code [expected-redirect]
  local got loc
  read -r got loc < <(curl -s -o /dev/null -m 15 -w '%{http_code} %{redirect_url}\n' "$1")
  if [ "$got" = "$2" ] && { [ -z "${3:-}" ] || [ "$loc" = "$3" ]; }; then
    printf '  ok    %-46s %s %s\n' "$1" "$got" "$loc"
  else
    printf '  FAIL  %-46s %s %s (expected %s %s)\n' "$1" "$got" "$loc" "$2" "${3:-}"; fail=1
  fi
}

echo "== site"
check "$WWW/" 200
for img in $(grep -oE 'src="images/[^"]+"' "$ROOT/site/index.html" | sed -E 's/^src="//; s/"$//' | sort -u); do
  check "$WWW/$img" 200
done
check "$WWW/README.md" 404
check "$WWW/scripts/deploy.sh" 404

echo "== redirects"
check http://www.smallsharptools.com/  301 "$WWW/"
check https://smallsharptools.com/     301 "$WWW/"
check http://smallsharptools.com/a/b   301 "$WWW/a/b"
check https://www.sstools.co/          301 "$WWW/"
check https://sstools.co/              301 "$WWW/"

echo "== certificate"
end=$(echo | openssl s_client -connect www.smallsharptools.com:443 -servername www.smallsharptools.com 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
if [ -n "$end" ]; then echo "  expires $end"; else echo "  FAIL  could not read the certificate"; fail=1; fi

[ "$fail" = 0 ] && echo "All checks passed." || echo "Some checks failed."
exit $fail
