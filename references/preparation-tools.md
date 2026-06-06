# 準備工具來源整理

本文件整理 PIXNET 原文列出的「準備工具」與用途。此處僅保存連結與研究註記，不鏡像、不重新散布任何 client / server / launcher 檔案。

## 1. 虛擬機工具

### Oracle VM VirtualBox

```text
Oracle VM VirtualBox
Windows 7 底下新版會有啟動問題，建議選擇安裝舊版
http://download.virtualbox.org/virtualbox/5.0.8/
```

用途：原文使用的虛擬機工具。

本案調整：

- 原文主機環境偏 Windows + VirtualBox。
- 本案主機環境為 Mac mini M1 + UTM。
- 因 M1 為 ARM 架構，若需跑 Solaris / OpenIndiana x86，需透過 UTM / QEMU 模擬 x86 guest。

## 2. Server 檔案

### 天翼之鍊日版 4.04 Server

```text
https://github.com/Mint-Fans/linux-package/raw/Solaris/tw404j.tar.gz
```

用途：日版 4.04 server。

研究定位：

- 作為日版原始對照。
- 若中文版 server 出現問題，可用日版交叉比對。
- 檔名推測：`tw404j` = TalesWeaver 4.04 Japanese。

### 天翼之鍊中文版 4.04 Server

```text
https://github.com/Mint-Fans/linux-package/raw/Solaris/tw404t.tar.gz
```

原文說明：

```text
角色可使用中文名稱，繁化度 95%
```

用途：中文版 4.04 server。

研究定位：

- 優先研究對象。
- 較符合繁體中文版回味需求。
- 檔名推測：`tw404t` = TalesWeaver 4.04 Traditional Chinese / Taiwan。

注意：

- 不要提交 `tw404j.tar.gz`、`tw404t.tar.gz` 或解壓後內容到本 repo。
- 即使 repo 是 private，也建議只保留筆記與自寫腳本。

## 3. Client 檔案

### 天翼之鍊日版 4.0.4 客戶端

```text
https://mega.nz/#!2MMHVKaA!AY8igGyuBIIsd2gRSYHBxU6pAcY9UmXaKzVRXtXuNWg
```

用途：日版 4.0.4 client。

研究定位：

- 用於連線 4.04 server。
- 需確認與 `tw404j` / `tw404t` 相容。

### 客戶端中文化

```text
https://mega.nz/#!nJ1VzDQL!O1kxSnp2sXXB43TtE-wu5yijlXJNWdy3XLkvzz4jQM4
```

用途：client 中文化補丁。

研究定位：

- 若 server 使用 `tw404t`，client 端仍可能需要中文化檔案。
- 需確認字型、編碼、角色名稱、NPC / item 顯示是否一致。

## 4. 登入器修改版

### 登入器修改版（日版）

```text
https://mega.nz/#!XFEhyQrI!lTuZ9FdWfjyng4J1_NErtpAWs9G1eYw2F6A-f_jvvTs
```

用途：日版 client 用的修改版登入器。

研究定位：

- 可能用於指定 server IP / port。
- 可與日版 client 對應測試。

### 登入器修改版（台版）

```text
https://mega.nz/#!OAlBgC6J!YMxxgKleV39Auhk0iHLFuMAWL7de9EtpMpH3TYI_RPk
```

用途：台版 / 中文化環境用的修改版登入器。

研究定位：

- 優先搭配 `tw404t` 與 client 中文化測試。
- 可能比日版登入器更適合中文角色名稱與繁中顯示。

## 5. 優先研究順序

```text
1. tw404t.tar.gz
2. 台版登入器修改版
3. 日版 4.0.4 client
4. client 中文化補丁
5. tw404j.tar.gz 作為對照
6. 日版登入器修改版作為對照
```

## 6. 本 repo 保存原則

本 repo 可以保存：

- 來源清單
- 架設筆記
- 檔案用途說明
- 自寫腳本
- troubleshooting

本 repo 不保存：

- server tarball
- client 安裝檔
- launcher binary
- 中文化 patch
- 遊戲素材
- database dump
- VM image
