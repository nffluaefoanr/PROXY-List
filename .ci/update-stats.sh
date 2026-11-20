#!/usr/bin/env bash
# Refresh list counters in the README.
set -euo pipefail

T=$(wc -l < http.txt)
S4=$(wc -l < socks4.txt)
S5=$(wc -l < socks5.txt)
TOT=$((T + S4 + S5))

sed -i -E "s/^Total Proxies: \`[0-9]+\`/Total Proxies: \`$TOT\`/" README.md || true
sed -i -E "s/^Last Updated: \`[^\`]+\`/Last Updated: \`$(date -u +'%Y-%m-%d %H:%M:%S') UTC\`/" README.md || true

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add README.md
git commit -m "docs: refresh list counters" || echo "no changes"
git push origin master || true
