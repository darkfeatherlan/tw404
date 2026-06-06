# TW404T 可行安裝流程總整理

本文件整合 PIXNET 原文、`tw404t.tar.gz` 靜態分析結果，以及 Mac mini M1 + UTM 的實際限制，整理出目前最可行的安裝路線。

## 一、核心結論

### 1. Ubuntu 不適合作為 Server OS

`tw404t.tar.gz` 內核心執行檔為 Solaris binary：

```text
db/db:          ELF 32-bit i386, interpreter /usr/lib/ld.so.1
ttales0/ttales: ELF 32-bit i386, interpreter /usr/lib/ld.so.1
ttales1/ttales: ELF 32-bit i386, interpreter /usr/lib/ld.so.1
ttales2/ttales: ELF 32-bit i386, interpreter /usr/lib/ld.so.1
```

`/usr/lib/ld.so.1` 是 Solaris / SunOS 系動態連結器，不是 Linux。Ubuntu 可用於分析檔案，但不適合直接跑 server。

### 2. 這包目標接近 Solaris 8 / SunOS 5.8

`strings` 顯示：

```text
SunOS 5.8
Solaris Link Editors 5.8
GCC i386-pc-solaris2.8 3.4.3
```

因此最合理方向是 Solaris / OpenSolaris / OpenIndiana / illumos 類環境。

### 3. 繁中版目錄名稱是 `ttales`，不是 `jtales`

繁中版結構：

```text
tw404t/
├─ db/
├─ ttales0/
├─ ttales1/
└─ ttales2/
```

日版資料常見 `jtales`，但本案應以 `ttales` 為準。

### 4. 主要依賴

```text
BerkeleyDB 3.3
MySQL 5.0.x
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

## 二、建議主線方案

### 主線 A：OpenIndiana / OpenSolaris on UTM

```text
Mac mini M1
  -> UTM
  -> x86 Solaris-like guest
  -> tw404t server
  -> Windows PC client
```

建議測試順序：

```text
1. OpenIndiana text installer
2. OpenSolaris 2010 snv_134
3. Solaris 10 x86
4. Solaris 11.x
```

### 為什麼先測 OpenIndiana？

優點：

- 仍可取得。
- 比 OpenSolaris 容易處理現代硬體 / 虛擬機。
- 屬 illumos / Solaris-like 系統。

風險：

- 可能缺舊版 32-bit library。
- MySQL 5.0 / BerkeleyDB 3.3 需自行補齊。

### 為什麼 OpenSolaris 2010 是備案？

優點：

- 最接近 PIXNET 原教學。
- 對舊 Solaris binary 相容性可能較好。

風險：

- 已停止維護。
- ISO 與套件庫不穩。
- 在 UTM / QEMU 上可能較難安裝。

## 三、安裝流程總覽

```text
Step 0  準備主機與檔案
Step 1  建立 UTM VM
Step 2  安裝 Solaris-like OS
Step 3  設定網路與固定 IP
Step 4  安裝 / 編譯 BerkeleyDB 3.3
Step 5  安裝 / 編譯 MySQL 5.0
Step 6  解壓 tw404t.tar.gz
Step 7  建立遊戲資料庫
Step 8  執行 change-ip / change-hosts
Step 9  執行 twsrv-init / create-accounts
Step 10 啟動 server
Step 11 Windows client 設定 IP.INI
Step 12 登入、建角、測中文角色名稱
```

## 四、Step 0：準備檔案

本 repo 不保存 server/client 檔案。建議於本機下載到忽略目錄：

```bash
mkdir -p .local/downloads
```

需要：

```text
tw404t.tar.gz                  # 繁中版 server，優先使用
tw404j.tar.gz                  # 日版 server，對照用
日版 4.0.4 client               # Windows 端
client 中文化補丁               # Windows 端
登入器修改版（台版優先）         # Windows 端
```

## 五、Step 1：建立 UTM VM

### 建議設定

```text
Architecture: x86_64 或 i386 模擬
CPU: 1-2 cores
RAM: 2-4 GB
Disk: 20-40 GB
Network: Bridged 優先
Display: 可用最低需求；穩定後可改文字模式
```

### 網路建議

優先使用 Bridge：

```text
Mac mini:      192.168.1.10
UTM guest:     192.168.1.149 或其他固定 IP
Windows PC:    192.168.1.30
```

若 Bridge 不可用，再考慮 NAT + port forwarding。

## 六、Step 2：安裝 OS

### 首選測試：OpenIndiana

安裝後先確認：

```bash
uname -a
isainfo -v
ifconfig -a
```

目標：確認是否能跑 32-bit x86 userland / binary。

### 若使用 OpenSolaris

PIXNET 原文提到 OpenSolaris 停止更新，需改 legacy repository：

```bash
pfexec pkg set-publisher -O http://pkg.openindiana.org/legacy opensolaris.org
```

## 七、Step 3：確認 tw404t binary 能否被系統辨識

將 `tw404t.tar.gz` 放入 guest 後：

```bash
cd ~
/usr/gnu/bin/tar zxvf tw404t.tar.gz
```

若 `/usr/gnu/bin/tar` 不存在，可先試：

```bash
gtar zxvf tw404t.tar.gz
```

或：

```bash
tar xzf tw404t.tar.gz
```

檢查 binary：

```bash
file ~/tw404t/db/db
file ~/tw404t/ttales0/ttales
ldd ~/tw404t/db/db
ldd ~/tw404t/ttales0/ttales
```

### 成功條件

`ldd` 不應出現大量：

```text
not found
```

若缺：

```text
libdb-3.3.so
libstdc++.so.6
libgcc_s.so.1
```

則進入 BerkeleyDB / GCC runtime 補齊流程。

## 八、Step 4：BerkeleyDB 3.3

`db/db` 依賴：

```text
libdb-3.3.so
```

處理方式：

1. 優先查看 `tw404t/docs/` 是否已有 build note。
2. 參考 Mint-Fans / PIXNET 提到的 `build-berkeleydb.txt`。
3. 編譯後確認 library 路徑可被找到。

常見處理方向：

```bash
crle
LD_LIBRARY_PATH=/usr/local/lib:/usr/local/BerkeleyDB.3.3/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
```

具體路徑需依實際安裝位置調整。

## 九、Step 5：MySQL 5.0

`ttales` 內有 MySQL C API symbols：

```text
mysql_real_connect
mysql_select_db
mysql_real_query
mysql_store_result
mysql_fetch_row
mysql_close
```

原文要求 MySQL 5.0.x。`tw404t/docs/` 內可先查：

```text
build-mysql.txt
mysql-settings.txt
db-inst.txt
```

注意：原文建議不要讓 MySQL 開機自動啟動，因 server 啟動前會先改系統日期。

## 十、Step 6：建立遊戲資料庫

先查看：

```bash
cat ~/tw404t/docs/db-inst.txt
```

再依文件建立資料庫。

待確認項目：

- database 名稱
- MySQL user / password
- character set
- 是否需要 Big5 / UTF-8
- 是否已有 SQL dump

## 十一、Step 7：修改 IP

繁中版預設 IP 靜態分析結果：

```text
192.168.1.149
```

執行：

```bash
cd ~/tw404t
./change-ip
```

它會改：

```text
db/DB.cfg
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
ttales1/table/DBs.ttales
ttales1/table/Servers.ttales
ttales2/table/DBs.ttales
ttales2/table/Servers.ttales
```

確認：

```bash
grep -R "192.168" ~/tw404t/db ~/tw404t/ttales*/table
```

## 十二、Step 8：修改 hosts

執行：

```bash
cd ~/tw404t
./change-hosts
```

原文說明：

```text
單機版選 2
私服 / 指定外網 IP 選 3
```

本案建議：

- 只在家用區網使用，不做外網公開。
- 若 Windows PC 要連 VM，應確認使用 VM 的區網 IP，而不是 127.0.0.1。

## 十三、Step 9：初始化與建立帳號

```bash
cd ~/tw404t
./twsrv-init
./create-accounts
```

`twsrv-init` 內建 locale 判斷：

```text
k -> kor
j -> jpn
其他 -> taiwan
```

繁中版應使用 taiwan。

## 十四、Step 10：啟動 server

### 推薦方式：自動啟動

```bash
cd ~/tw404t
./start-twsrv
```

`start-twsrv` 會：

1. 設定系統日期：`date 0101000003`
2. 啟動 MySQL
3. 啟動 `db/db`
4. 啟動 `ttales0/start`
5. 啟動 `ttales1/start`
6. 啟動 `ttales2/start`
7. 監控程序，缺了自動重啟

### 檢查程序

```bash
ps -ef | grep db
ps -ef | grep ttales
netstat -an | grep 40000
```

### 手動啟動流程

若要手動排錯：

```bash
sudo date 0101000003
sudo /etc/init.d/mysql.server start

cd ~/tw404t/db
./db

cd ~/tw404t/ttales0
./ttales -d 12 ttales0

cd ~/tw404t/ttales1
./ttales -d 12 ttales1

cd ~/tw404t/ttales2
./ttales -d 12 ttales2
```

## 十五、Step 11：Windows Client 設定

Windows 端需要：

```text
日版 4.0.4 client
client 中文化 patch
登入器修改版（台版優先）
```

將登入器放進遊戲目錄後，修改：

```text
IP.INI
```

設定為 UTM guest IP，例如：

```text
192.168.1.149
```

在 guest 查 IP：

```bash
ifconfig -a
```

## 十六、Step 12：登入測試

測試順序：

```text
1. Windows PC ping UTM guest IP
2. Windows PC telnet / nc 測 port 40000
3. 開登入器
4. 登入帳號
5. 建立角色
6. 測試中文角色名稱
7. 進入遊戲地圖
```

Windows 可測：

```powershell
Test-NetConnection 192.168.1.149 -Port 40000
```

## 十七、常見問題排查

### 1. ldd 顯示 library not found

先補：

```text
libdb-3.3.so
libstdc++.so.6
libgcc_s.so.1
```

再確認 `LD_LIBRARY_PATH` 或 Solaris runtime library path。

### 2. 登入後馬上斷線

原文與社群資料都提到日期問題。確認 server 啟動前有執行：

```bash
date 0101000003
```

若仍失敗：

```bash
cd ~/tw404t
./stop-twsrv
./clear-logs
./start-twsrv
```

### 3. Client 無法連線

檢查：

```text
UTM 是否 Bridge
IP.INI 是否指向 VM IP
server 是否 listening on 40000
防火牆是否擋住
change-ip 是否完成
change-hosts 是否完成
```

### 4. 中文角色名稱失敗

確認：

```text
使用 tw404t，不是 tw404j
使用台版登入器修改版
client 已套中文化
MySQL character set 設定正確
```

### 5. start-twsrv 失敗

改手動啟動，逐一看哪個程序失敗：

```text
MySQL
db/db
ttales0
ttales1
ttales2
```

## 十八、目前最務實路線

```text
1. UTM 建 OpenIndiana VM
2. 解壓 tw404t.tar.gz
3. file / ldd 檢查 db 與 ttales
4. 補 BerkeleyDB 3.3
5. 補 MySQL 5.0
6. 匯入 db-inst.txt 指示的資料庫
7. change-ip / change-hosts
8. twsrv-init / create-accounts
9. start-twsrv
10. Windows client 修改 IP.INI 後登入
```

如果 OpenIndiana 卡在舊 library，改測 OpenSolaris 2010 snv_134。

## 十九、下一步待辦

- [ ] 實測 OpenIndiana 是否可跑 `ttales`。
- [ ] 讀取並整理 `tw404t/docs/db-inst.txt`。
- [ ] 讀取並整理 `tw404t/docs/build-mysql.txt`。
- [ ] 讀取並整理 `tw404t/docs/mysql-settings.txt`。
- [ ] 建立 `docs/07-database-setup.md`。
- [ ] 建立 `docs/08-client-setup.md`。
- [ ] 建立 `docs/09-first-login-test.md`。
