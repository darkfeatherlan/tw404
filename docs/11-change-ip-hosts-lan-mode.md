# change-ip / change-hosts 內網模式判斷

## 1. 為什麼這段很重要

原文寫：

```text
修改 Server IP
cd ~/tw404
./change-ip

指定 HOSTS
cd ~/tw404
./change-hosts

單機版選擇「2」即可，如果架私服，選擇「3」指定外網IP與Hostname。
```

但本案不是同機單機，也不是公開外網私服，而是：

```text
Mac mini M1
  -> UTM
  -> OpenIndiana guest
  -> tw404t server

Windows PC
  -> 內網連線到 OpenIndiana guest
```

因此要用「內網伺服器」思維設定。

## 2. 實際腳本內容確認

### change-ip

`change-ip` 會自動判斷 server 目錄名稱：

```bash
TALES_NAME=$(ls | grep tales0 | sed 's/[0-9]//g')
```

在繁中版 `tw404t` 中會得到：

```text
ttales
```

它會抓目前網卡 IP：

```bash
HOSTIP=$(ifconfig -a | grep broadcast | awk '{print $2}')
```

然後替換下列檔案中的舊 IP：

```text
db/DB.cfg
ttales0/table/DBs.ttales
ttales0/table/Servers.ttales
ttales1/table/DBs.ttales
ttales1/table/Servers.ttales
ttales2/table/DBs.ttales
ttales2/table/Servers.ttales
```

它會顯示目前抓到的：

```text
HOST IP: <目前 OpenIndiana 網卡 IP>
Server IP: <目前設定檔內舊 IP>
```

若直接 Enter，會使用 `HOSTIP`。

### change-hosts

`change-hosts` 有三個選項：

```text
1) 127.0.0.1 <hostname>
2) <HOSTIP> <hostname>
3) Custom Modify
```

其中：

```text
1 = localhost / 本機 loopback
2 = 目前網卡 IP
3 = 手動指定 IP 與 hostname
```

因此原文說「單機版選 2」在這個腳本裡容易誤解。以實際腳本來看：

```text
選 1 才是 127.0.0.1
選 2 是目前網卡 IP
選 3 是手動指定
```

## 3. 本案應該怎麼選

### 最佳情況：UTM 使用 Bridged Network

假設：

```text
OpenIndiana guest IP = 192.168.1.149
Windows PC IP        = 192.168.1.30
```

則：

```bash
cd ~/tw404t
./change-ip
```

在 Enter Specify IP 時，若畫面顯示的 `HOST IP` 已經是：

```text
192.168.1.149
```

可以直接 Enter。

接著：

```bash
./change-hosts
```

應選：

```text
2) 192.168.1.149 <hostname>
```

也就是選 `2`。

### 如果 HOSTIP 抓錯

有時 `ifconfig -a | grep broadcast` 可能抓到錯的 IP，或抓到多個網卡。

此時 `change-ip` 不要直接 Enter，手動輸入 OpenIndiana guest 的正確內網 IP，例如：

```text
192.168.1.149
```

`change-hosts` 則選：

```text
3) Custom Modify
```

手動輸入：

```text
IP: 192.168.1.149
Hostname: <目前 hostname>
```

hostname 可用：

```bash
hostname
```

查看。

## 4. 不應該選什麼

### 不要選 127.0.0.1

若 Windows PC 要連進來，不應使用：

```text
127.0.0.1
localhost
```

原因：

```text
127.0.0.1 只代表 OpenIndiana guest 自己。
Windows PC 連不到。
```

### 不要填 Mac mini host IP

不要填：

```text
Mac mini 的 IP
```

除非你明確使用 UTM Shared Network + port forwarding。

一般 Bridged Network 下，應填：

```text
OpenIndiana guest 的 IP
```

## 5. 執行前備份

執行前建議先備份：

```bash
cd ~/tw404t
mkdir -p backup-before-ip-change
cp db/DB.cfg backup-before-ip-change/
cp ttales0/table/DBs.ttales backup-before-ip-change/DBs.ttales.0
cp ttales0/table/Servers.ttales backup-before-ip-change/Servers.ttales.0
cp ttales1/table/DBs.ttales backup-before-ip-change/DBs.ttales.1
cp ttales1/table/Servers.ttales backup-before-ip-change/Servers.ttales.1
cp ttales2/table/DBs.ttales backup-before-ip-change/DBs.ttales.2
cp ttales2/table/Servers.ttales backup-before-ip-change/Servers.ttales.2
sudo cp /etc/inet/hosts backup-before-ip-change/hosts
```

## 6. 執行後檢查

查 server 設定檔：

```bash
grep -R "192.168" ~/tw404t/db ~/tw404t/ttales*/table
```

確認沒有殘留舊 IP。

查 hosts：

```bash
cat /etc/inet/hosts
```

應看到類似：

```text
192.168.1.149 <hostname> <hostname>.local localhost loghost
```

## 7. Windows 端連線測試

在 Windows PowerShell：

```powershell
ping 192.168.1.149
```

等 server 服務起來後測 port：

```powershell
Test-NetConnection 192.168.1.149 -Port 45012
```

`45012` 是目前已成功啟動的 `db/db` port。

等 `ttales0` 起來後，再用 OpenIndiana 查實際 listening ports：

```bash
netstat -an | grep LISTEN
```

再決定 client launcher 要連哪個 port。

## 8. 本案建議結論

若 UTM guest 有內網 IP，例如：

```text
192.168.1.149
```

則建議：

```text
change-ip：輸入或接受 OpenIndiana guest IP
change-hosts：選 2；若抓錯 IP，選 3 手動指定
```

不要用：

```text
127.0.0.1
Mac mini host IP
外網 IP
```

除非你改成 port forwarding 或公開外網架構。
