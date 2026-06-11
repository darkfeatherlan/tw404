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
# Kaul_Item custom shop list: pet eggs, bags, Odin set, anniversary ring, enhanced wings.

perl -i -pe 's/^1003886(\s+)/1003036$1/' "$FILE"  # 小Q比的蛋
perl -i -pe 's/^1000013(\s+)/1003037$1/' "$FILE"  # 小泡芙的蛋
perl -i -pe 's/^1000014(\s+)/1003038$1/' "$FILE"  # 濃濃的蛋
perl -i -pe 's/^1000016(\s+)/1003039$1/' "$FILE"  # 阿帽的蛋
perl -i -pe 's/^1000017(\s+)/1003040$1/' "$FILE"  # 小果凍雞的蛋
perl -i -pe 's/^1000018(\s+)/1003041$1/' "$FILE"  # 瓢蟲的蛋
perl -i -pe 's/^1000024(\s+)/1003042$1/' "$FILE"  # 小虎魚的蛋
perl -i -pe 's/^1000027(\s+)/1003043$1/' "$FILE"  # 青翅鬼Jr.的蛋
perl -i -pe 's/^1001002(\s+)/1003044$1/' "$FILE"  # 小小妖精的蛋
perl -i -pe 's/^1000035(\s+)/1003667$1/' "$FILE"  # 克拉拉的蛋
perl -i -pe 's/^1000036(\s+)/1003774$1/' "$FILE"  # 阿嬌的蛋
perl -i -pe 's/^1000077(\s+)/1004167$1/' "$FILE"  # 紅色包包
perl -i -pe 's/^1000078(\s+)/1004168$1/' "$FILE"  # 紫色包包
perl -i -pe 's/^1000089(\s+)/1004169$1/' "$FILE"  # 黃色包包
perl -i -pe 's/^1000092(\s+)/1004170$1/' "$FILE"  # 綠色包包
perl -i -pe 's/^1000095(\s+)/1004219$1/' "$FILE"  # 小潘達的蛋
perl -i -pe 's/^1000104(\s+)/1004528$1/' "$FILE"  # 生命之音的蛋
perl -i -pe 's/^1000043(\s+)/1004662$1/' "$FILE"  # N-小Q比的蛋
perl -i -pe 's/^1000044(\s+)/1004663$1/' "$FILE"  # N-小泡芙的蛋
perl -i -pe 's/^1000045(\s+)/1004664$1/' "$FILE"  # N-濃濃的蛋
perl -i -pe 's/^1000046(\s+)/1004665$1/' "$FILE"  # N-阿帽的蛋
perl -i -pe 's/^1000047(\s+)/1004666$1/' "$FILE"  # N-阿嬌的蛋
perl -i -pe 's/^1000048(\s+)/1004667$1/' "$FILE"  # N-小潘達的蛋
perl -i -pe 's/^1000049(\s+)/1004668$1/' "$FILE"  # N-生命之音的蛋
perl -i -pe 's/^1000050(\s+)/1004669$1/' "$FILE"  # N-小果凍的蛋
perl -i -pe 's/^1000051(\s+)/1004670$1/' "$FILE"  # N-瓢蟲的蛋
perl -i -pe 's/^1000052(\s+)/1004671$1/' "$FILE"  # N-虎魚的蛋
perl -i -pe 's/^1000111(\s+)/1004672$1/' "$FILE"  # N-青翅鬼Jr.的蛋
perl -i -pe 's/^1000153(\s+)/1004673$1/' "$FILE"  # N-小小妖精的蛋
perl -i -pe 's/^1000154(\s+)/1004873$1/' "$FILE"  # N-瓢蟲的蛋
perl -i -pe 's/^1000155(\s+)/1004874$1/' "$FILE"  # N-虎魚少女的蛋
perl -i -pe 's/^1000156(\s+)/1004875$1/' "$FILE"  # N-魔菇的蛋
perl -i -pe 's/^1000182(\s+)/1004876$1/' "$FILE"  # N-守護者Jr的蛋
perl -i -pe 's/^1000887(\s+)/1004877$1/' "$FILE"  # N-小花貓的蛋
perl -i -pe 's/^1000882(\s+)/1006220$1/' "$FILE"  # N-雪梟的蛋

# Added equipment items sold together.
perl -i -pe 's/^1000902(\s+)/1004639$1/' "$FILE"  # 奧丁盔甲(頭飾)
perl -i -pe 's/^1000905(\s+)/1004640$1/' "$FILE"  # 奧丁盔甲(頭盔)
perl -i -pe 's/^1000906(\s+)/1004641$1/' "$FILE"  # 奧丁盔甲(鏈甲)
perl -i -pe 's/^1000896(\s+)/1004642$1/' "$FILE"  # 奧丁盔甲(鋼盾)
perl -i -pe 's/^1000913(\s+)/1004643$1/' "$FILE"  # 奧丁盔甲(披風)
perl -i -pe 's/^1000914(\s+)/1004644$1/' "$FILE"  # 奧丁盔甲(指輪)
perl -i -pe 's/^1000915(\s+)/1004645$1/' "$FILE"  # 奧丁盔甲(皮靴)
perl -i -pe 's/^1000916(\s+)/1004646$1/' "$FILE"  # 天翼之鍊2週年紀念戒指
perl -i -pe 's/^1000917(\s+)/1004648$1/' "$FILE"  # 晨映之翼【強化】
perl -i -pe 's/^1000918(\s+)/1004649$1/' "$FILE"  # 櫻扉之羽【強化】

echo "Kaul_Item item IDs updated."
echo "Check result:"
grep -E '^[0-9]+' "$FILE" | head -45
