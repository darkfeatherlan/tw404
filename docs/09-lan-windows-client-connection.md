# 內網 Windows Client 連線規劃

本案 Server 跑在：

```text
Mac mini M1
  -> UTM
  -> OpenIndiana x86 guest
  -> tw404t server
```

Client 跑在：

```text
Windows PC
  -> TalesWeaver 4.04 client
```

因此這不是同一台本機連線，而是內網跨主機連線。

## 1. 網路目標

Windows PC 必須能連到 UTM guest 的 IP，而不是 Mac mini 本機 IP，也不是 `127.0.0.1`。

範例：

```text
Mac mini host:       192.168.1.10
OpenIndiana guest:   192.168.1.149
Windows PC client:   192.168.1.30
```

Client 應連：

```text
192.168.1.149
```

不是：

```text
127.0.0.1
192.168.1.10
```

## 2. UTM 網路模式選擇

### 首選：Bridged Network

若 UTM 可以使用 Bridge，最理想：

```text
OpenIndiana guest 直接取得家中路由器發的 IP。
Windows PC 可直接連 guest IP。
```

優點：

- 最像一台真正的內網伺服器。
- 不需要 port forwarding。
- Windows client 設定最單純。

缺點：

- Apple Silicon + UTM + 某些網卡模式可能不穩。
- 目前安裝階段曾先關閉 Network；需安裝完成後再加回 e1000。

### 備案：Shared Network + Port Forwarding

若 Bridge 不可用，使用 Shared Network 時：

```text
Windows PC 無法直接連 guest 私有 IP。
需要在 UTM 做 port forwarding。
```

此時 Windows PC 可能連 Mac mini host IP，例如：

```text
192.168.1.10:40000
```

再由 UTM 轉到 guest：

```text
guest:40000
```

但 TW server 可能不只用 40000，還可能有 DB / login / world 相關 ports，因此 Bridge 比 port forwarding 更適合。

## 3. OpenIndiana 裡查 IP

在 guest 執行：

```bash
ifconfig -a
```

或：

```bash
ipadm show-addr
```

確認是否取得內網 IP。

如果沒有 IP，先確認 UTM 已加回網卡：

```text
Network: Intel e1000
Mode: Bridged 或 Shared
```

## 4. Windows 端測試連線

在 Windows PowerShell：

```powershell
ping 192.168.1.149
```

測 port：

```powershell
Test-NetConnection 192.168.1.149 -Port 40000
Test-NetConnection 192.168.1.149 -Port 45012
```

說明：

- `45012` 是目前已成功啟動的 `db/db` port。
- client 最終不一定需要直接連 45012；但此 port 可用來確認 guest 服務是否可從內網被看到。
- login / client port 需等 `ttales0` 成功啟動後再確認。

## 5. TW404 server 端 IP 修改

Server 包內有：

```bash
./change-ip
./change-hosts
```

目前預設 IP 曾分析為：

```text
192.168.1.149
```

實際使用時，應以 OpenIndiana guest 取得的 IP 為準。

需要檢查：

```bash
grep -R "192.168" ~/tw404t/db ~/tw404t/ttales*/table
```

可能涉及：

```text
db/DB.cfg
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
ttales1/table/DBs.ttales
ttales1/table/Servers.ttales
ttales2/table/DBs.ttales
ttales2/table/Servers.ttales
```

若 Windows client 連不到，先確認 server table 內 IP 不是：

```text
127.0.0.1
localhost
舊的 192.168.1.x
```

## 6. 固定 IP 建議

建議讓 OpenIndiana guest 固定 IP，避免每次重開變動。

可用兩種方式：

1. 在家用路由器上設定 DHCP reservation。
2. 在 OpenIndiana guest 內設定 static IP。

優先建議：

```text
DHCP reservation
```

比較不容易把 guest 網路設壞。

## 7. 待確認 ports

目前已知：

```text
45012 -> db/db ready port
```

待 `ttales0/1/2` 啟動後確認：

```bash
netstat -an | grep LISTEN
```

或：

```bash
netstat -an | grep -E "40000|45012|LISTEN"
```

之後再整理 client 實際需要連的 ports。
