# TW404 Research Notes

私人研究筆記：整理 TalesWeaver 4.04 舊版伺服器環境的架設線索、Mac mini M1 + UTM 方案、設定檔位置與測試流程。

## 目標

在不公開營運、不散布檔案的前提下，研究如何於本機或區網環境回味舊版天翼之鍊。

目標架構：

```text
Mac mini M1
  -> UTM
  -> x86 Solaris-like guest OS
  -> TW 4.04 server environment
  -> Windows PC running 4.04 client
```

## 主要來源

本 repo 目前以 PIXNET 中文教學所列 GitHub raw 來源為主線：

```text
Mint-Fans/linux-package, Solaris branch
- tw404j.tar.gz：日版 4.04 Server
- tw404t.tar.gz：中文版 4.04 Server（角色可使用中文名稱，繁化度約 95%）
```

其中 `tw404t.tar.gz` 為優先研究對象，`tw404j.tar.gz` 作為對照。

## 不提交原則

即使本 repo 是 private，也不建議提交下列檔案：

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
- 環境紀錄
- 自寫輔助腳本
- 設定檔範本
- troubleshooting

## 文件結構

```text
.
├─ README.md
├─ docs/
│  ├─ 01-pixnet-mintfans-main-guide.md
│  ├─ 02-mac-mini-utm-plan.md
│  ├─ 03-server-layout.md
│  ├─ 04-ip-config.md
│  └─ 99-troubleshooting.md
├─ scripts/
│  ├─ ip_to_tw_addr.py
│  └─ replace_server_ip.sh
├─ references/
│  └─ sources.md
└─ .gitignore
```

## 目前判斷

1. `tw404t.tar.gz` 是最符合繁體中文回味需求的版本。
2. Mac mini M1 可作為低功耗伺服器，但 guest OS 可能需要 x86 模擬。
3. UTM 的 Bridge 網路最適合讓 Windows client 直接連 VM。
4. 需避免把 client / server 檔案直接納入 repo。
