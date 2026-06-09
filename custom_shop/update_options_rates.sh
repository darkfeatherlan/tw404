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

# EXP rate. In this Options.ttales, XP_C is not present.
# expFinalMultRatio uses percent logic: 100 = normal, 2000 = 20x.
perl -i -pe 'if (/^Option\s+gameopt\s+expFinalMultRatio\s+i\s+/) { s/(\s+)\S+\s*$/\12000/; }' "$FILE"

# Free/trial EXP rate. Keep it aligned with expFinalMultRatio.
perl -i -pe 'if (/^Option\s+gameopt\s+expFinalFreeMultRatio\s+i\s+/) { s/(\s+)\S+\s*$/\12000/; }' "$FILE"

# Monster corpse drop rate.
perl -i -pe 'if (/^Option\s+gameopt\s+monsterCorpseDropRate\s+f\s+/) { s/(\s+)\S+\s*$/\12000/; }' "$FILE"

echo "Options rates updated."
echo "Check result:"
grep -E 'expFinalMultRatio|expFinalFreeMultRatio|monsterCorpseDropRate' "$FILE"
