#!/bin/sh

set -eu

FILE="${1:-ttales0/quest_data/meta/Nar_Item.meta}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"
echo "Backup created: $BACKUP"

# Replace only the first field ItemID and keep the rest of the line unchanged.
perl -i -pe 's/^1003886(\s+)/1004529$1/' "$FILE"
perl -i -pe 's/^1000013(\s+)/1004539$1/' "$FILE"
perl -i -pe 's/^1000014(\s+)/1004544$1/' "$FILE"
perl -i -pe 's/^1000016(\s+)/1002814$1/' "$FILE"
perl -i -pe 's/^1000017(\s+)/1006168$1/' "$FILE"
perl -i -pe 's/^1000018(\s+)/1003035$1/' "$FILE"
perl -i -pe 's/^1000024(\s+)/1003048$1/' "$FILE"
perl -i -pe 's/^1000027(\s+)/1004619$1/' "$FILE"
perl -i -pe 's/^1001002(\s+)/1000222$1/' "$FILE"
perl -i -pe 's/^1000035(\s+)/1000223$1/' "$FILE"
perl -i -pe 's/^1000036(\s+)/1002952$1/' "$FILE"
perl -i -pe 's/^1000076(\s+)/1002945$1/' "$FILE"
perl -i -pe 's/^1000077(\s+)/1002946$1/' "$FILE"
perl -i -pe 's/^1000078(\s+)/1002947$1/' "$FILE"
perl -i -pe 's/^1000079(\s+)/1002948$1/' "$FILE"
perl -i -pe 's/^1000080(\s+)/1002949$1/' "$FILE"
perl -i -pe 's/^1000081(\s+)/1003017$1/' "$FILE"

echo "Nar_Item item IDs updated."
echo "Check result: grep -E '^[0-9]+' \"$FILE\" | head -23"
