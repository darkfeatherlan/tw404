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

sed -i 's/^1003886 /1004529 /' "$FILE"
sed -i 's/^1000013 /1004539 /' "$FILE"
sed -i 's/^1000014 /1004544 /' "$FILE"
sed -i 's/^1000016 /1004509 /' "$FILE"
sed -i 's/^1000017 /1006168 /' "$FILE"
sed -i 's/^1000018 /1003035 /' "$FILE"
sed -i 's/^1000024 /1003048 /' "$FILE"
sed -i 's/^1000027 /1004619 /' "$FILE"
sed -i 's/^1001002 /1000222 /' "$FILE"
sed -i 's/^1000035 /1000223 /' "$FILE"
sed -i 's/^1000036 /1002952 /' "$FILE"
sed -i 's/^1000076 /1002945 /' "$FILE"
sed -i 's/^1000077 /1002946 /' "$FILE"
sed -i 's/^1000078 /1002947 /' "$FILE"
sed -i 's/^1000079 /1002948 /' "$FILE"
sed -i 's/^1000080 /1002949 /' "$FILE"
sed -i 's/^1000081 /1003017 /' "$FILE"

echo "Nar_Item item IDs updated."
echo "Check result: grep -E '^[0-9]+' \"$FILE\" | head -23"
