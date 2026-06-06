# PIXNET 安裝流程整理

來源：PIXNET「天翼之鍊 4.04 版單機板架設 (Solaris 11 / OpenIndiana / OpenSolaris)」。本文件僅整理流程與檢查點，不保存任何 client/server 檔案。

## 1. 架設環境

原文環境：

```text
Solaris 11 / OpenSolaris / OpenIndiana + VirtualBox + MySQL
```

本案轉換：

```text
Mac mini M1 + UTM + x86 Solaris-like guest + MySQL
```

## 2. OS 選型

原文列出：

- OpenSolaris 2009 svn 111
- OpenSolaris 2010 svn 134
- OpenIndiana 2018
- Solaris 11.3

原文建議重點：

- Solaris 11.3 較吃資源，不太建議。
- OpenSolaris 較輕量，單機版建議用 OpenSolaris。
- OpenSolaris 2010 svn 134 較推薦。
- 若實機架設，OpenIndiana 驅動較新。

本案判斷：

- Mac mini M1 + UTM 需要跑 x86 guest，效能會受 QEMU 模擬影響。
- 優先順序可先測 OpenSolaris 2010 svn 134，再測 OpenIndiana。
- Solaris 11.3 作為最後備案。

## 3. OpenSolaris 軟體倉庫

原文指出 OpenSolaris 已停止更新，安裝後需更新軟體倉庫：

```bash
pfexec pkg set-publisher -O http://pkg.openindiana.org/legacy opensolaris.org
```

## 4. Solaris 安裝設定

原文 VirtualBox 設定：

- 網路：橋接介面卡
- 共享資料夾：方便傳輸檔案

本案 UTM 對應：

- 網路優先使用 Bridged。
- 若 UTM bridge 不穩，改用 NAT + port forwarding。
- 檔案傳輸可用 SSH/SCP、共享資料夾或 ISO 掛載。

## 5. Solaris 系統配置

原文包含：

- 安裝 VBoxGuestAdditions Modules
- sudo 免密碼
- 自動登入
- PS1 主題
- Nautilus root file manager link

本案建議：

- UTM 不使用 VBoxGuestAdditions，需改查 UTM/QEMU 對 Solaris guest 的檔案分享方式。
- sudo 免密碼與自動登入屬便利設定，不是必要條件。
- 若只當 server，圖形介面可關閉以節省資源。

## 6. 編譯安裝所需套件

原文列出三個 GitHub raw 腳本：

```text
build-berkeleydb.txt
install-mysql-5.0-opensolaris.txt
build-mysql-5.0-solaris.txt
```

用途：

- 編譯 BerkeleyDB。
- 在 OpenSolaris 安裝與設定 MySQL 5.0。
- 在 OpenIndiana 2018 / Solaris 11 編譯與設定 MySQL 5.0。

重要提醒：

原文指出每次啟動 Server 前，必須在 MySQL 啟動之前設定時間，因此不建議 MySQL 開機自動啟動。

## 7. Server 架設流程

原文流程：

```bash
cd ~
/usr/gnu/bin/tar zxvf tw404j.tar.gz
```

繁中版實作時應改用：

```bash
cd ~
/usr/gnu/bin/tar zxvf tw404t.tar.gz
```

建立遊戲資料庫：

```text
tw404/docs/db-inst.txt
```

修改 Server IP：

```bash
cd ~/tw404
./change-ip
```

指定 HOSTS：

```bash
cd ~/tw404
./change-hosts
```

原文說明：

- 單機版選擇 `2`。
- 架私服選擇 `3` 指定外網 IP 與 Hostname。

本案只做家用區網，通常應視情況選單機或區網設定，不建議外網公開。

## 8. 修改允許登入的 Client 版本

原文位置：

```text
~/tw404/jtales*/table/Patches.jtales
```

原文範例：

```text
Patch    2    404    R    PatchNotice    NoName        1    ftp://patch.nexon.co.kr/softmax/talesweaver/update
```

用途：允許 4.04 client 登入。

## 9. 建立帳號

原文流程：

```bash
cd ~/tw404
./twsrv-init

cd ~/tw404
./create-accounts
```

推測：

- `twsrv-init`：初始化帳號目錄 / server 環境。
- `create-accounts`：建立遊戲帳號。

## 10. 啟動 Server

### 方法一：自動啟動

原文推薦：

```bash
cd ~/tw404
./start-twsrv
```

該腳本會自動修改伺服器日期並自動啟動 MySQL。

### 方法二：手動啟動

修改伺服器時間，避免進入遊戲掉線：

```bash
sudo date 0101000003
```

啟動 MySQL：

```bash
sudo /etc/init.d/mysql.server start
```

或：

```bash
sudo /usr/local/mysql/bin/mysqld_safe --user=mysql &
```

開啟帳號資料庫：

```bash
cd ~/tw404/db
./db
```

登入伺服器：

```bash
cd ~/tw404/jtales0
./jtales -d 12 jtales0
```

世界地圖一：

```bash
cd ~/tw404/jtales1
./jtales -d 12 jtales1
```

世界地圖二：

```bash
cd ~/tw404/jtales2
./jtales -d 12 jtales2
```

若手動啟動後進入遊戲掉線，原文建議：

1. 關閉 Server。
2. 關閉 MySQL。
3. 執行：

```bash
~/tw404/clear-logs
```

4. 重新按步驟啟動。

## 11. 停止 Server

```bash
cd ~/tw404
./stop-twsrv
```

## 12. 顯示管理器啟用 / 禁用

```bash
cd ~/tw404
./dm-manager
```

用途：開啟或關閉圖形介面。若要在文字模式下運作，可在啟動 Server 前使用。

## 13. Client 設定

原文流程：

1. 將登入器修改版解壓縮後放在遊戲目錄內。
2. 修改 `IP.INI`。
3. 指定虛擬機內 Solaris Server 的 Host IP，例如：`192.168.1.xxx`。
4. Solaris 查看 IP：

```bash
ifconfig -a
```

5. 啟動登入器進入遊戲。

## 14. 日版 Client 亂碼問題

原文建議使用 Locale Emulator：

1. 下載 Locale Emulator。
2. 解壓縮到 Program Files。
3. 執行 `LEInstaller.exe`。
4. 點選 `Install for current user`。
5. 在登入器修改版 `TalesWeaver-xx.exe` 上按右鍵。
6. 選擇 `Locale Emulator` -> `Run in Japanese` 啟動遊戲。

## 15. Client 中文化

原文流程：

```text
將 tw404-client-cht.zip 解壓縮到遊戲目錄即可。
```

## 16. 本案待處理清單

- [ ] 確認 UTM 可否順利跑 OpenSolaris 2010 svn 134。
- [ ] 確認 OpenIndiana 在 UTM x86 模擬下效能是否可接受。
- [ ] 研究 Mint-Fans 的 `build-berkeleydb.txt`。
- [ ] 研究 Mint-Fans 的 `install-mysql-5.0-opensolaris.txt`。
- [ ] 研究 Mint-Fans 的 `build-mysql-5.0-solaris.txt`。
- [ ] 下載但不提交 `tw404t.tar.gz`。
- [ ] 解壓後檢查 `tw404/docs/db-inst.txt`。
- [ ] 檢查 `change-ip`、`change-hosts`、`twsrv-init`、`create-accounts`、`start-twsrv`、`stop-twsrv`、`dm-manager`、`clear-logs`。
- [ ] 確認 `Patches.jtales` 允許 4.04 client。
- [ ] Windows client 修改 `IP.INI` 指向 VM IP。
- [ ] 測試中文角色名稱。
