# TW404T 可行安裝流程總整理（Parallels / Mac mini M1 版）

本文件重新整理安裝方案，前提改為：

```text
Host: Mac mini M1
Virtualization: Parallels Desktop
Client: Windows PC
Server package: tw404t.tar.gz
```

## 一、核心變更：Parallels 與 UTM 的差異

原先假設使用 UTM / QEMU，可模擬 x86 guest OS。現在改為 Parallels 後，路線必須調整。

### Parallels on Apple Silicon 的限制

Mac mini M1 是 ARM64 架構。Parallels 在 Apple Silicon 上主要提供 ARM guest 虛擬化，例如：

```text
Windows 11 ARM
Linux ARM64
```

它不是用來完整模擬 x86 Solaris / OpenSolaris 的工具。

### tw404t 的限制

`tw404t.tar.gz` 內核心 server binary 是：

```text
db/db:           ELF 32-bit i386 Solaris binary, interpreter /usr/lib/ld.so.1
ttales0/ttales:  ELF 32-bit i386 Solaris binary, interpreter /usr/lib/ld.so.1
ttales1/ttales:  ELF 32-bit i386 Solaris binary, interpreter /usr/lib/ld.so.1
ttales2/ttales:  ELF 32-bit i386 Solaris binary, interpreter /usr/lib/ld.so.1
```

因此它需要的是：

```text
x86 / i386 Solaris-like environment
```

不是 ARM Linux，也不是 Windows 11 ARM。

## 二、結論

### Parallels 不能作為 tw404t server 的第一選擇

原因：

```text
Parallels on M1 = ARM guest virtualization
TW404T server = 32-bit i386 Solaris binary
```

兩者架構不合。

### Parallels 可以做什麼？

Parallels 仍可用於：

1. 跑 Windows 11 ARM 做管理機。
2. 使用 Windows ARM 內的 x86 模擬執行部分 Windows 工具。
3. 測 Windows client / 登入器，但不保證舊遊戲 client 完整相容。
4. 管理另一台真正的 x86 server / VM。

但 Parallels 不適合直接跑 OpenSolaris x86 server。

## 三、目前可行方案排序

## 方案 A：Mac mini M1 + UTM / QEMU 跑 x86 Solaris-like（最接近原技術需求）

```text
Mac mini M1
  -> UTM / QEMU x86 emulation
  -> OpenSolaris / OpenIndiana / Solaris x86
  -> tw404t server
  -> Windows PC client
```

優點：

- 能跑 x86 Solaris-like guest。
- 與 tw404t binary 架構相符。
- 可在同一台 Mac mini 上完成 server。

缺點：

- x86 emulation 較慢。
- Solaris-like OS 安裝較麻煩。
- 仍需處理 MySQL 5.0 / BerkeleyDB 3.3。

此方案是「Mac mini M1 當 server」的合理主線，但需要 UTM / QEMU，而不是 Parallels。

## 方案 B：另找一台 Intel x86 小主機跑 Solaris-like（成功率最高）

```text
Intel mini PC / 舊筆電 / x86 NUC
  -> VirtualBox / VMware / bare metal
  -> OpenSolaris / Solaris 10 / OpenIndiana x86
  -> tw404t server
  -> Windows PC client
```

優點：

- 架構完全對。
- 可直接照 PIXNET / VirtualBox 類教學。
- 成功率高於 Apple Silicon。
- 效能足夠，硬體需求很低。

缺點：

- 需要另一台 x86 機器。

此方案是整體成功率最高的路線。

## 方案 C：Parallels + Windows 11 ARM 作 client / 管理機，不跑 server

```text
Mac mini M1
  -> Parallels
  -> Windows 11 ARM
  -> 測 client / launcher / IP.INI

另一台 x86 server
  -> tw404t server
```

優點：

- 可保留目前 Parallels 投資。
- 可用 Windows ARM 測部分 client 工具。

缺點：

- Windows 舊遊戲 client 在 ARM x86 模擬下不保證穩定。
- server 仍需要 x86 Solaris-like 環境。

## 方案 D：Ubuntu / Linux port（低可行性，不建議）

不可直接跑，因為 tw404t 是 Solaris binary。

除非有：

```text
server source code
或完整重寫 emulator
或 Solaris binary compatibility layer
```

否則不建議。

## 四、如果你堅持只用 Parallels，能怎麼做？

### 1. Parallels 跑 Windows 11 ARM

可用於：

- 保存檔案。
- 編輯 `IP.INI`。
- 測登入器是否能啟動。
- 測 client 中文化。

但不建議把它當 server OS。

### 2. Parallels 跑 Linux ARM64

可用於：

- 解壓 `tw404t.tar.gz`。
- 檔案分析。
- 編輯腳本。
- grep / strings / readelf。

但無法直接執行 `ttales` / `db`。

### 3. Parallels 跑 x86 Solaris？

在 Apple Silicon 上，Parallels 不適合做 x86 full emulation。若目標是 x86 Solaris-like guest，應改用 UTM / QEMU。

## 五、重新整理後的建議路線

### 最務實路線 1：買／找一台 Intel x86 小主機

```text
Intel 小主機
  -> VirtualBox 5.x / VMware
  -> OpenSolaris 2010 snv_134 或 Solaris 10 x86
  -> tw404t
  -> Windows PC client
```

適合你如果想「比較快架起來玩」。

### 最務實路線 2：Mac mini M1 改用 UTM

```text
Mac mini M1
  -> UTM
  -> OpenSolaris / OpenIndiana x86
  -> tw404t
  -> Windows PC client
```

適合你如果想「只用 Mac mini 當 server」。

### Parallels 角色重新定位

```text
Parallels = client / 管理 / 文件分析
不是 tw404t server 執行環境
```

## 六、Parallels 環境下仍可先做的準備

即使不跑 server，仍可先在 Parallels Windows 11 ARM 做：

1. 下載 client。
2. 解壓日版 4.04 client。
3. 套 client 中文化。
4. 放入台版登入器。
5. 編輯 `IP.INI`。
6. 等 server 端 IP 確定後連線測試。

也可在 Parallels Linux ARM 做：

```bash
mkdir -p ~/tw404-analysis
cd ~/tw404-analysis
tar xzf tw404t.tar.gz
find tw404t -maxdepth 3 -type f | head
file tw404t/db/db
file tw404t/ttales0/ttales
strings tw404t/ttales0/ttales | head
```

但這些是分析，不是執行。

## 七、Server 端真正安裝流程（仍需 x86 Solaris-like）

若改用 x86 server 或 UTM，流程如下：

```text
1. 安裝 OpenSolaris / OpenIndiana / Solaris 10 x86
2. 設定 Bridge network / 固定 IP
3. 解壓 tw404t.tar.gz
4. ldd 檢查 db/db 與 ttales0/ttales
5. 補 BerkeleyDB 3.3
6. 補 MySQL 5.0
7. 匯入 db-inst.txt 指示的資料庫
8. 執行 change-ip
9. 執行 change-hosts
10. 執行 twsrv-init
11. 執行 create-accounts
12. 執行 start-twsrv
13. Windows client 修改 IP.INI 連線
```

## 八、目前決策建議

如果你的優先目標是「成功玩到」：

```text
找 Intel x86 小主機 > Mac mini M1 + UTM > Mac mini M1 + Parallels
```

如果你的優先目標是「一定要 Mac mini M1 當 server」：

```text
請改用 UTM / QEMU，不建議 Parallels。
```

如果你的優先目標是「只想用現有 Parallels」：

```text
Parallels 只能做 client / 管理 / 分析；server 端另找 x86 環境。
```

## 九、下一步

建議下一步先決定：

```text
A. 是否願意在 Mac mini M1 加裝 UTM？
B. 是否有 Intel x86 舊電腦 / 小主機？
C. 是否只想用 Parallels 做 client，server 另找機器？
```

依目前分析，Parallels 不應再作為 tw404t server 主線。
