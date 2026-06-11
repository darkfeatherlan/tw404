#!/bin/sh

set -eu

FILE="${1:-ttales0/quest_data/meta/Kaul_Item.meta}"

if [ ! -f "$FILE" ]; then
  echo "ERROR: file not found: $FILE" >&2
  exit 1
fi

BACKUP="${FILE}.bak.$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"
echo "Backup created: $BACKUP"

# Replace only the first field ItemID and keep the rest of the line unchanged.
# Pet eggs and bags.
perl -i -pe 's/^1003886(\s+)/1003036$1/' "$FILE"
perl -i -pe 's/^1000013(\s+)/1003037$1/' "$FILE"
perl -i