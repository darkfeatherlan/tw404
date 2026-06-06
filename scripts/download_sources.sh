#!/usr/bin/env bash
set -euo pipefail

mkdir -p .local/downloads
cd .local/downloads

echo "Downloading TW404 source packages..."

curl -L -o tw404j.tar.gz \
  https://github.com/Mint-Fans/linux-package/raw/Solaris/tw404j.tar.gz

curl -L -o tw404t.tar.gz \
  https://github.com/Mint-Fans/linux-package/raw/Solaris/tw404t.tar.gz

echo "Done. Files stored in .local/downloads/"
