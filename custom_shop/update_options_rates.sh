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
sed -i 's/^Option[[:space:]]\+gameopt[[:space:]]\+XP_C[[:space:]]\+i[[:space:]]\+[0-9][0-9]*$/Option\tgameopt\t\tXP_C\t\t\t\ti\t2000/' "$FILE"

# Monster corpse drop rate: Option gameopt monsterCorpseDropRate f <value>
sed -i 's/^Option[[:space:]]\+gameopt[[:space:]]\+monsterCorpseDropRate[[:space:]]\+f[[:space:]]\+[0-9.][0-9.]*$/Option\tgameopt\t\tmonsterCorpseDropRate\t\tf\t2000/' "$FILE"

echo "Options rates updated."
echo "Check result:"
grep -E 'XP_C|monsterCorpseDropRate' "$FILE"
