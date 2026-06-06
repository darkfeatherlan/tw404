# TW404 UTM Server Lab

私人研究筆記：以 **Mac mini M1 + UTM** 架設 TalesWeaver 4.04 繁中版伺服器環境，供本機／區網回味使用。

## 目標架構

```text
Mac mini M1
  -> UTM / QEMU x86 emulation
  -> OpenSolaris / OpenIndiana / Solaris x86 guest
  -> tw404t server
  -> Windows PC running 4.04 client
```

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
- 主線改為 UTM / QEMU 模擬 x86 Solaris-like guest。
- OS 測試優先序：OpenIndiana -> OpenSolaris 2010 snv_134 -> Solaris 10 x86。

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
│  ├─ 00-utm-installation-flow.md
│  ├─ 01-pixnet-install-flow.md
│  ├─ 05-tw404t-static-analysis.md
│  └─ 99-troubleshooting.md
├─ scripts/
│  └─ download_sources.sh
├─ references/
│  └─ preparation-tools.md
└─ .gitignore
```

## 下一步

1. 在 UTM 建立 x86 Solaris-like VM。
2. 優先測 OpenIndiana；若 library 相容性不足，再測 OpenSolaris 2010 snv_134。
3. 解壓 `tw404t.tar.gz` 後執行 `file` / `ldd`。
4. 補 BerkeleyDB 3.3 與 MySQL 5.0。
5. 執行 `change-ip`、`change-hosts`、`twsrv-init`、`create-accounts`、`start-twsrv`。
6. Windows client 修改 `IP.INI` 指向 VM IP。
