#!/usr/bin/env bash
# Post-seat record keeping: keep one rolling signature window in README,
# archive pointer indexes under records/, nothing heavier.
set -euo pipefail
STAMP=$(date -u +%Y%m%d%H%M%S)
NONCE_FILE="records/run-history"
touch "$NONCE_FILE"
tail -400 "$NONCE_FILE" > "$NONCE_FILE.tmp" && mv "$NONCE_FILE.tmp" "$NONCE_FILE"
IDNT="$(openssl rand -hex 12 2>/dev/null || echo $RANDOM$RANDOM)"
echo "${STAMP}-${IDNT}" >> "$NONCE_FILE"
# README: keep exactly one dated signature paragraph, refreshed each seat
KEY="<!-- seat-signature -->"
PARA="${KEY}
_Session anchor:_ \`${STAMP}\` (_rev. \`${IDNT:0:8}\`)_"
if grep -q "^${KEY}$" README.md; then
  awk -v key="$KEY" -v para="$PARA" '
    BEGIN{skip=0; done=0}
    $0==key && !done {print para; done=1; skip=1; next}
    skip==1 && /^$/ {skip=0; next}
    skip==1 && /^[[:space:]]*$/ {next}
    skip==1 {next}
    {print}' README.md > README.md.new && mv README.md.new README.md
else
  printf '\n%s\n' "$PARA" >> README.md
fi
git add README.md records .ci/run-post.sh 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -qm "docs: refresh maintenance notes" || true
fi
