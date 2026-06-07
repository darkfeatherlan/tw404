# Client 啟動器失效時的替代研究

## 1. 問題背景

PIXNET 原文列出：

```text
天翼之鍊日版 4.0.4 客戶端
客戶端中文化
登入器修改版（日版）
登入器修改版（台版）
```

目前狀態：

```text
日版原版 client：可下載
繁中翻譯包：可下載
修改版登入器：下載失效
```

原文的 client 設定依賴修改版登入器：

```text
把下載的登入器修改版解壓縮後放在遊戲目錄內，然後修改 IP.INI 內容，指定虛擬機內 Solaris Server 的 Host IP。
```

因此目前需要研究：沒有修改版登入器時，如何讓原生日版 client 連到自架 server。

## 2. 原文可確認事項

原文指出：

- Server IP 由 `change-ip` / `change-hosts` 設定。
- Client 端本來靠修改版登入器讀取 `IP.INI`。
- Solaris / OpenIndiana 端查 IP：

```bash
ifconfig -a
```

- Client 中文化方式：將 `tw404-client-cht.zip` 解壓縮到遊戲目錄。

## 3. 替代路線 A：直接用 InphaseNXD.EXE 啟動參數

TWPrivate Wiki 提供另一種做法，不依賴修改版登入器，而是建立 batch file 啟動：

```bat
start InphaseNXD.EXE /USE_SERVER 12 /ADDR <IP_AS_INTEGER> /PORT 40000
```

其中：

```text
/USE_SERVER 12
/ADDR <IP 整數格式>
/PORT 40000
```

### IP 整數換算

TWPrivate 的公式是：

```text
若 server IP = A.B.C.D
/ADDR = D * 256^3 + C * 256^2 + B * 256 + A
```

例：

```text
192.168.1.200
= 200 * 256^3 + 1 * 256^2 + 168 * 256 + 192
= 3355551936
```

因此 batch file 會是：

```bat
start InphaseNXD.EXE /USE_SERVER 12 /ADDR 3355551936 /PORT 40000
```

注意：這是 little-endian 形式，不是一般 `int(IPv4Address(ip))` 的 big-endian 形式。

## 4. 本案需要新增 IP 換算工具

repo 需要一個工具：

```text
scripts/ip_to_tw_addr.py
```

功能：

```bash
python3 scripts/ip_to_tw_addr.py 192.168.1.149
```

輸出可直接填入 `/ADDR` 的整數。

公式：

```python
addr = d * 256**3 + c * 256**2 + b * 256 + a
```

## 5. Windows client 初步測試流程

### Step 1：安裝日版 4.0.4 client

保留原始資料夾，不要直接覆蓋唯一一份。建議：

```text
TalesWeaver_404_original
TalesWeaver_404_test
```

### Step 2：套繁中翻譯包

將 `tw404-client-cht.zip` 解壓到測試用 client 目錄。

### Step 3：建立 launch-local.bat

放在 client 目錄：

```bat
@echo off
start InphaseNXD.EXE /USE_SERVER 12 /ADDR <IP_AS_INTEGER> /PORT 40000
```

### Step 4：設定相容性

TWPrivate 建議：

```text
Right click InphaseNXD.EXE
Properties
Compatibility
Reduced color mode
16-bit color
```

### Step 5：日文 Locale

若日版 client 亂碼或啟動失敗，使用 Locale Emulator：

```text
Locale Emulator -> Run in Japanese
```

## 6. 待確認事項

- [ ] 原生日版 client 目錄內是否有 `InphaseNXD.EXE`。
- [ ] 原生日版 client 是否可用 `/USE_SERVER /ADDR /PORT` 啟動。
- [ ] `/PORT 40000` 是否與 `ttales0` 實際 listening port 一致。
- [ ] `ttales0` 啟動後用 `netstat -an` 確認實際 port。
- [ ] 是否仍需要 `IP.INI`。
- [ ] 繁中補丁是否會改 executable 或只改 data / text。
- [ ] 中文角色名稱是否需要 client 端字型或編碼支援。

## 7. 替代路線 B：研究 IP.INI 格式

若原生 client 無法接受啟動參數，則研究 `IP.INI`。

步驟：

```text
1. 在 client 目錄搜尋 IP.INI。
2. 若不存在，手動建立並測試。
3. 搜尋 client 目錄內是否有 server list / patch list 類檔案。
4. 使用 strings 搜尋 InphaseNXD.EXE 是否含 IP.INI / USE_SERVER / ADDR / PORT 字樣。
```

Windows 可用：

```powershell
Select-String -Path .\* -Pattern "IP.INI","USE_SERVER","ADDR","PORT" -SimpleMatch
```

或用 Sysinternals `strings.exe` 分析 executable。

## 8. 替代路線 C：比較修改版登入器

若未來找到修改版登入器，優先做 diff，不直接依賴來源不明 binary。

比較項目：

```text
檔名
檔案大小
strings 結果
是否讀取 IP.INI
是否呼叫 InphaseNXD.EXE
是否只是包裝 batch 行為
```

如果修改版登入器只是 wrapper，則 A 路線即可取代。

## 9. 本案目前建議

優先採用：

```text
日版 4.0.4 client
+ 繁中翻譯包
+ launch-local.bat
+ InphaseNXD.EXE 參數啟動
```

暫不依賴失效的修改版登入器。

等 server 端 `ttales0` 成功啟動後，再確認實際 client port。
