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

sed -i 's/^1000380 /1000947 /' "$FILE"
sed -i 's/^1000381 /1000948 /' "$FILE"
sed -i 's/^1000382 /1000949 /' "$FILE"
sed -i 's/^1000383 /1000950 /' "$FILE"
sed -i 's/^1000384 /1000951 /' "$FILE"
sed -i 's/^1000385 /1000974 /' "$FILE"
sed -i 's/^1000401 /1002116 /' "$FILE"
sed -i 's/^1000402 /1002134 /' "$FILE"
sed -i 's/^1000403 /1002135 /' "$FILE"
sed -i 's/^1000404 /1002136 /' "$FILE"
sed -i 's/^1000405 /1002137 /' "$FILE"
sed -i 's/^1000406 /1004382 /' "$FILE"
sed -i 's/^1000296 /1004383 /' "$FILE"
sed -i 's/^1000297 /1004384 /' "$FILE"
sed -i 's/^1000298 /1004385 /' "$FILE"
sed -i 's/^1000299 /1004386 /' "$FILE"
sed -i 's/^1000300 /1004387 /' "$FILE"
sed -i 's/^1000301 /1004388 /' "$FILE"
sed -i 's/^1000338 /1004389 /' "$FILE"
sed -i 's/^1000339 /1004390 /' "$FILE"
sed -i 's/^1000340 /1004391 /' "$FILE"
sed -i 's/^1000341 /1004392 /' "$FILE"
sed -i 's/^1000342 /1004393 /' "$FILE"

echo "Nar_Weapon item IDs updated."
echo "Check result: grep -E '^[0-9]+' \"$FILE\" | head -23"
