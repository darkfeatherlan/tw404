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

# TODO: Add Nar_Item item ID replacements here.
# Example:
# sed -i 's/^OLD_ID /NEW_ID /' "$FILE"

echo "Nar_Item update script placeholder created."
