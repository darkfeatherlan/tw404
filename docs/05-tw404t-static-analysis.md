# tw404t.tar.gz 靜態分析

## 檔案資訊

- 檔案：`tw404t.tar.gz`
- SHA256：`569b806e38e475538c72ec1393375eeffe038c6a3e17e7bd783a2492839dff1c`
- tar 成員數：7,749
- 解壓根目錄：`tw404t/`

## 目錄結構

```text
tw404t/
├─ db/
│  ├─ db
│  ├─ DB.cfg
│  ├─ character/
│  ├─ master/
│  │  ├─ create_master
│  │  ├─ make_hash_dir
│  │  └─ uh
│  └─ start
├─ ttales0/
│  ├─ ttales
│  ├─ start
│  ├─ table/
│  ├─ map/
│  ├─ quest/
│  ├─ quest_data/
│  └─ logs/
├─ ttales1/
├─ ttales2/
├─ docs/
├─ change-ip
├─ change-hosts
├─ clear-logs
├─ create-accounts
├─ dm-manager
├─ start-twsrv
├─ stop-twsrv
└─ twsrv-init
```

## 關鍵結論

### 1. 不是 Ubuntu / Linux 可直接執行的 server

核心執行檔格式：

```text
db/db: ELF 32-bit LSB executable, Intel i386, interpreter /usr/lib/ld.so.1
ttales0/ttales: ELF 32-bit LSB executable, Intel i386, interpreter /usr/lib/ld.so.1
ttales1/ttales: ELF 32-bit LSB executable, Intel i386, interpreter /usr/lib/ld.so.1
ttales2/ttales: ELF 32-bit LSB executable, Intel i386, interpreter /usr/lib/ld.so.1
```

`/usr/lib/ld.so.1` 是 Solaris / SunOS 系的動態連結器路徑，不是 Linux 的 `ld-linux.so`。因此 Ubuntu 不適合作為執行環境，只適合做靜態分析。

### 2. 編譯目標接近 SunOS 5.8 / Solaris 8

`strings` 顯示：

```text
@(#)SunOS 5.8 Generic February 2000
ld: Software Generation Utilities - Solaris Link Editors: 5.8-1.291
/usr/local/lib/gcc/i386-pc-solaris2.8/3.4.3/...
```

判斷：

- 這批 binary 很可能是 Solaris 8 / SunOS 5.8 時代產物。
- OpenSolaris / OpenIndiana / Solaris 10 的成功率高於 Ubuntu。
- 若在較新的 Solaris-like 系統執行，需補齊舊 library。

### 3. 依賴 BerkeleyDB 3.3 與 MySQL 5.0

`strings db/db` 顯示：

```text
libdb-3.3.so
libstdc++.so.6
libgcc_s.so.1
libsocket.so.1
libnsl.so.1
librt.so.1
libpthread.so.1
libc.so.1
libdl.so.1
libz.so
```

`ttales` 內可見大量 MySQL C API symbol，例如：

```text
mysql_real_connect
mysql_select_db
mysql_real_query
mysql_store_result
mysql_fetch_row
mysql_close
```

判斷：

- `db/db` 主要依賴 BerkeleyDB / 檔案式資料。
- `ttales*` 會連 MySQL。
- 原文要求 BerkeleyDB 3.3 + MySQL 5.0 是合理的。

### 4. 繁中版實際名稱為 `ttales`，不是 `jtales`

目錄與檔案如下：

```text
ttales0/ttales
ttales1/ttales
ttales2/ttales
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
ttales0/table/Patches.ttales
```

腳本用這段自動判斷名稱：

```bash
TALES_NAME=$(ls | grep tales0 | sed 's/[0-9]//g')
```

在繁中版會得到：

```text
ttales
```

因此後續文件要以 `ttales` 為主，不要再寫 `jtales`。

## Server IP 設定

目前預設 IP 是：

```text
192.168.1.149
```

出現位置包含：

```text
db/DB.cfg
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
```

`change-ip` 會替換：

```text
db/DB.cfg
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
ttales1/table/DBs.ttales
ttales1/table/Servers.ttales
ttales2/table/DBs.ttales
ttales2/table/Servers.ttales
```

但它沒有處理 `Patches.ttales`，因 `Patches.ttales` 主要是 client 版本允許清單，不是 server IP 清單。

## Client 版本設定

`ttales0/table/Patches.ttales` 中目前啟用：

```text
Patch 2 403 N PatchNotice DeleteMe 1 ftp://patch.nexon.co.kr/softmax/talesweaver/update
Patch 2 404 R PatchNotice NoName   1 ftp://patch.nexon.co.kr/softmax/talesweaver/update
```

`422` 被註解：

```text
;Patch 2 422 R PatchNotice NoName 1 ftp://patch.nexon.co.kr/softmax/talesweaver/update
```

判斷：此包預設允許 4.04 client 登入。

## 內建文件

`docs/` 內包含：

```text
build-mysql.txt
change-mysql-db-char-utf8
mysql-settings.txt
solaris-system-cfg.txt
db-remove.txt
start-tw-server.txt
db-inst.txt
```

重點：

- `build-mysql.txt`：MySQL 5.0.86 編譯筆記。
- `mysql-settings.txt`：MySQL 初始化、my.cnf、root 密碼設定。
- `db-inst.txt`：遊戲資料庫匯入。
- `start-tw-server.txt`：server 啟停與 client 連線流程。
- `solaris-system-cfg.txt`：Solaris / OpenIndiana 系統設定。

## 啟動流程

### 初始化

```bash
cd ~/tw404t
./twsrv-init
./create-accounts
```

`twsrv-init` 預設 locale 為：

```text
taiwan
```

也支援：

```text
k -> kor
j -> jpn
其他 -> taiwan
```

### 啟動

```bash
cd ~/tw404t
./start-twsrv
```

`start-twsrv` 做的事：

1. 設定日期：`date 0101000003`。
2. 啟動 MySQL。
3. 啟動 `db/db`。
4. 啟動 `ttales0/start`、`ttales1/start`、`ttales2/start`。
5. 每 60 秒監控程序，缺了就重啟。

### 停止

```bash
cd ~/tw404t
./stop-twsrv
```

會 kill：

```text
./db
ttales0
ttales1
ttales2
```

並停止 MySQL。

## OS 選擇建議

依目前 binary 分析，建議順序：

1. OpenSolaris 2010 snv_134：最貼近原教學。
2. Solaris 10 x86：可能更接近 SunOS 5.8 相容需求。
3. OpenIndiana：較現代，但需補舊 library。
4. Solaris 11.x：可測，但可能較重。
5. Ubuntu：不建議作為 server OS，只能靜態分析。

## Mac mini M1 / UTM 注意事項

- 這是 32-bit i386 Solaris binary。
- Mac mini M1 是 ARM64。
- 必須透過 UTM / QEMU 跑 x86 / i386 / x86_64 Solaris-like guest。
- 若 OS 是 64-bit，仍須支援 32-bit Solaris binary 與舊版 library。
- Bridge 網路優先，讓 Windows client 直接連 VM IP。

## 待驗證事項

- [ ] OpenIndiana 是否可直接執行 `/usr/lib/ld.so.1` 指向的 32-bit binary。
- [ ] 是否需要安裝 32-bit compatibility libraries。
- [ ] `libdb-3.3.so`、`libgcc_s.so.1`、`libstdc++.so.6` 是否可補齊。
- [ ] MySQL 5.0.86 是否能在目標 OS 編譯或安裝。
- [ ] `db-inst.txt` 內 SQL 是否能正常匯入。
- [ ] `change-ip` 是否能正確抓到 UTM guest IP。
- [ ] Windows client 修改 `IP.INI` 後是否能連到 `40000`。
- [ ] 中文角色名稱建立與登入是否正常。
