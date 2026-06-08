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

# EXP rate: Option gameopt XP_C i <value>
perl -0777 -i -pe 's/^Option\s+gameopt\s+XP_C\s+i\s+\S+\s*$/Option\tgameopt\t\tXP_C\t\t\t\ti\t2000/m' "$FILE"

# Monster corpse drop rate: Option gameopt monsterCorpseDropRate f <value>
perl -0777 -i -pe 's/^Option\s+gameopt\s+monsterCorpseDropRate\s+f\s+\S+\s*$/Option\tgameopt\t\tmonsterCorpseDropRate\t\tf\t2000/m' "$FILE"

echo "Options rates updated."
echo "Check result:"
grep -E 'XP_C|monsterCorpseDropRate' "$FILE"
