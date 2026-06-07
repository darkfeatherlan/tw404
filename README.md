# TW404 UTM Server Lab

私人研究筆記：以 **Mac mini M1 + UTM** 架設 TalesWeaver 4.04 繁中版伺服器環境，供本機／區網回味使用。

## 目前實測主線

```text
Mac mini M1
  -> UTM / QEMU x86_64 emulation
  -> OpenIndiana x86 guest
  -> tw404t server
  -> Windows PC running 4.04 client
```

## 目前已成功

- OpenIndiana 已在 UTM 成功安裝，`uname` 顯示 `i386`。
- `tw404t` 核心檔案為 32-bit i386 Solaris ELF，可被 OpenIndiana 辨識。
- `libstdc++.so.6`、`libgcc_s.so.1` 已透過 `/usr/gcc/10/lib` 解決。
- BerkeleyDB 3.3 已重新編譯成 32-bit 版本。
- `db/db` 已成功啟動：

```text
ENDRE DataBase Server ready, port: 45012
```

## 目前卡點

正在補 **MySQL 5.0.86**。

目前進度：

- `mysql-5.0.86` 已下載並解壓。
- `./configure` 已成功完成。
- 目前缺 `gmake`，需安裝 `developer/build/gnu-make` 後才能繼續編譯。

## 主線版本

本 repo 以 PIXNET 中文教學所列 GitHub raw 來源為主線：

```text
Mint-Fans/linux-package, Solaris branch
- tw404t.tar.gz：中文版 4.04 Server（角色可使用中文名稱，繁化度約 95%）
- tw404j.tar.gz：日版 4.04 Server，僅作對照
```

目前優先研究：`tw404t.tar.gz`。

## 重要技術判斷

已靜態分析 `tw404t.tar.gz`，核心執行檔是：

```text
db/db           -> 32-bit i386 Solaris ELF, /usr/lib/ld.so.1
ttales0/ttales  -> 32-bit i386 Solaris ELF, /usr/lib/ld.so.1
ttales1/ttales  -> 32-bit i386 Solaris ELF, /usr/lib/ld.so.1
ttales2/ttales  -> 32-bit i386 Solaris ELF, /usr/lib/ld.so.1
```

所以：

- Ubuntu / Linux 不適合作為 Server OS。
- Parallels on M1 不作為主線。
- 主線為 UTM / QEMU 模擬 x86 Solaris-like guest。
- 目前 OpenIndiana 已可行，不再優先測 OpenSolaris / Solaris 10。

## 不提交原則

即使 repo 是 private，也不建議提交：

- `tw404j.tar.gz`
- `tw404t.tar.gz`
- 解壓後的 server binaries
- client 安裝檔
- client 中文化 patch
- 修改版 launcher
- 原始遊戲素材、地圖、音樂、資料庫 dump
- VM 映像檔

本 repo 僅保存：

- 架設筆記
- 靜態分析
- 自寫輔助腳本
- troubleshooting
- 來源清單

## 文件結構

```text
.
├─ README.md
├─ docs/
│  ├─ 00-utm-current-progress.md
│  ├─ 01-pixnet-install-flow.md
│  ├─ 02-utm-solaris-settings.md
│  ├─ 05-tw404t-static-analysis.md
│  ├─ 07-berkeleydb-setup.md
│  ├─ 08-mysql-setup.md
│  └─ 99-troubleshooting.md
├─ scripts/
│  └─ download_sources.sh
├─ references/
│  └─ preparation-tools.md
└─ .gitignore
```

## 下一步

1. 安裝 `gmake`：`sudo pkg install developer/build/gnu-make`。
2. 在 `mysql-5.0.86` 執行 `gmake`。
3. 執行 `sudo gmake install`。
4. 確認 MySQL 路徑，必要時建立 `/usr/local/mysql` 相容 symlink。
5. 執行 `twsrv-init`、`create-accounts`、`start-twsrv`。
6. 啟動 `ttales0`、`ttales1`、`ttales2` 後，再測 Windows client。
