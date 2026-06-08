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
- MySQL 5.0.86 已在 OpenIndiana 上成功編譯、安裝、初始化與啟動。
- MySQL 已確認：
  - `select version();` 回傳 `5.0.86`。
  - `datadir` 為 `/usr/local/mysql/var/`。
  - 3306 port 正常 LISTEN。
  - 建庫、建表、insert/select 正常。
  - mysqld 重啟後資料仍保留。
- BerkeleyDB 3.3 已重新編譯成 32-bit 版本。
- TW404 runtime library 已確認可透過 `LD_LIBRARY_PATH` 解決：

```bash
export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/10/lib:$LD_LIBRARY_PATH
```

- `db/db` 已成功啟動：

```text
ENDRE DataBase Server ready, port: 45012
```

- `twsrv-init` 已成功初始化 `db/character` 與 `db/master` hash directories。
- `ttales0` 已可啟動並開始載入 GameDB，例如：

```text
GameDB (...:account) process started.
GameDB (...:group) process started.
GameDB (...:guild) process started.
```

## 目前待處理

目前 `ttales0` 曾出現：

```text
group db [member] not ready. waiting
```

暫判斷不是 server binary 問題，而是 MySQL 內尚未完成 TW404 所需的 user、database 與 table 建置。下一步應依 `docs/db-inst.txt` 建立：

```text
gamedb user
ttales12_account
ttales12_castle
ttales12_episode
ttales12_friendList
ttales12_gamestat
ttales12_group
ttales12_guild
ttales12_pet
ttales12_refuse
ttales12_share
```

並匯入各 database 所需 table。

## 暫時放棄項目

OpenIndiana 目前內建 OpenSSH 10.3p1，`/usr/sbin/sshd -D -d` 會 Segmentation Fault。已確認不是單純 host key、SMF、hostname 或 missing library 問題。SSH 暫不列為主線，後續若需要再考慮 UTM shared directory、替代 SSH server 或換較舊 OpenIndiana。

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
│  ├─ 08-mysql-5.0.86-openindiana.md
│  ├─ 09-berkeleydb-runtime.md
│  ├─ 10-client-launcher-replacement.md
│  ├─ 11-change-ip-hosts-lan-mode.md
│  └─ 99-troubleshooting.md
├─ scripts/
│  └─ download_sources.sh
├─ references/
│  └─ preparation-tools.md
└─ .gitignore
```

## 下一步

1. 依 `docs/db-inst.txt` 建立 MySQL user、database 與 tables。
2. 確認 `ttales12_group.member` table 是否建立成功。
3. 重新啟動 MySQL。
4. 設定 TW404 runtime：

```bash
source ~/tw404t/env.sh
```

或：

```bash
export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/10/lib:$LD_LIBRARY_PATH
```

5. 啟動 `db/db`：

```bash
cd ~/tw404t/db
nohup ./db > db.log 2>&1 &
```

6. 啟動 `ttales0`、`ttales1`、`ttales2`。
7. 處理 Windows client：日版 4.0.4 client + 繁中包 + 自製 launcher / `InphaseNXD.EXE` 參數啟動。
