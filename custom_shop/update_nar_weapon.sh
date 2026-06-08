#!/bin/sh

set -eu

FILE="${1:-ttales0/quest_data/meta/Nar_Weapon.meta}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"
echo "Backup created: $BACKUP"

# Replace only the first field ItemID and keep the rest of the line unchanged.
perl -i -pe 's/^1000380(\s+)/1000947$1/' "$FILE"
perl -i -pe 's/^1000381(\s+)/1000948$1/' "$FILE"
perl -i -pe 's/^1000382(\s+)/1000949$1/' "$FILE"
perl -i -pe 's/^1000383(\s+)/1000950$1/' "$FILE"
perl -i -pe 's/^1000384(\s+)/1000951$1/' "$FILE"
perl -i -pe 's/^1000385(\s+)/1000974$1/' "$FILE"
perl -i -pe 's/^1000401(\s+)/1002116$1/' "$FILE"
perl -i -pe 's/^1000402(\s+)/1002134$1/' "$FILE"
perl -i -pe 's/^1000403(\s+)/1002135$1/' "$FILE"
perl -i -pe 's/^1000404(\s+)/1002136$1/' "$FILE"
perl -i -pe 's/^1000405(\s+)/1002137$1/' "$FILE"
perl -i -pe 's/^1000406(\s+)/1004382$1/' "$FILE"
perl -i -pe 's/^1000296(\s+)/1004383$1/' "$FILE"
perl -i -pe 's/^1000297(\s+)/1004384$1/' "$FILE"
perl -i -pe 's/^1000298(\s+)/1004385$1/' "$FILE"
perl -i -pe 's/^1000299(\s+)/1004386$1/' "$FILE"
perl -i -pe 's/^1000300(\s+)/1004387$1/' "$FILE"
perl -i -pe 's/^1000301(\s+)/1004388$1/' "$FILE"
perl -i -pe 's/^1000338(\s+)/1004389$1/' "$FILE"
perl -i -pe 's/^1000339(\s+)/1004390$1/' "$FILE"
perl -i -pe 's/^1000340(\s+)/1004391$1/' "$FILE"
perl -i -pe 's/^1000341(\s+)/1004392$1/' "$FILE"
perl -i -pe 's/^1000342(\s+)/1004393$1/' "$FILE"

echo "Nar_Weapon item IDs updated."
echo "Check result: grep -E '^[0-9]+' \"$FILE\" | head -23"
