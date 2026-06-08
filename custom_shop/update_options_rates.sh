#!/bin/sh

set -eu

FILE="${1:-ttales0/table/Options.ttales}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"
echo "Backup created: $BACKUP"

# Replace only the final value on the target lines.
# Keep original tabs/spaces and avoid rebuilding the whole line.
perl -i -pe 'if (/^Option\s+gameopt\s+.*XP_C/) { s/(\s+)\S+\s*$/\12000/; }' "$FILE"
perl -i -pe 'if (/^Option\s+gameopt\s+.*monsterCorpseDropRate/) { s/(\s+)\S+\s*$/\12000/; }' "$FILE"

echo "Options rates updated."
echo "Check result:"
grep -E 'XP_C|monsterCorpseDropRate' "$FILE"
