# BerkeleyDB 3.3 / TW404 Runtime 設定

本文件記錄 TW404 server binary 在 OpenIndiana 上執行時需要的 runtime library 設定。

## 1. 問題背景

TW404 server binary 是 32-bit Solaris / i386 程式。

若未設定 runtime library path，執行：

```bash
cd ~/tw404t/db
ldd ./db
```

可能看到：

```text
libdb-3.3.so => (file not found)
libstdc++.so.6 => (file not found)
libgcc_s.so.1 => (file not found)
```

或直接執行：

```bash
./db
```

出現：

```text
fatal: libdb-3.3.so: open failed
```

## 2. 已確認的 library 來源

本案已編譯並安裝 32-bit BerkeleyDB 3.3：

```text
/usr/local/BerkeleyDB.3.3-32/lib/libdb-3.3.so
```

GCC runtime 使用：

```text
/usr/gcc/10/lib
```

或依實機情況使用：

```text
/usr/gcc/14/lib
```

建議先以 GCC 10 為主，因 TW404 屬舊式 32-bit binary。

## 3. 臨時設定

每次登入 shell 後，可先設定：

```bash
export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/10/lib:$LD_LIBRARY_PATH
```

若實機 `libstdc++.so.6` / `libgcc_s.so.1` 在 GCC 14，可改：

```bash
export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/14/lib:$LD_LIBRARY_PATH
```

查找實際位置：

```bash
find / -name "libstdc++.so.6" 2>/dev/null
find / -name "libgcc_s.so.1" 2>/dev/null
find / -name "libdb-3.3.so" 2>/dev/null
```

## 4. 驗證

```bash
cd ~/tw404t/db
ldd ./db
```

應看到類似：

```text
libdb-3.3.so => /usr/local/BerkeleyDB.3.3-32/lib/libdb-3.3.so
libstdc++.so.6 => /usr/gcc/10/lib/libstdc++.so.6
libgcc_s.so.1 => /usr/gcc/10/lib/libgcc_s.so.1
```

不應再出現：

```text
(file not found)
```

## 5. 持久化方式

### 方式 A：寫入使用者 profile

```bash
echo 'export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/10/lib:$LD_LIBRARY_PATH' >> ~/.profile
```

套用：

```bash
source ~/.profile
```

重新登入後確認：

```bash
echo $LD_LIBRARY_PATH
```

### 方式 B：只寫進 TW404 啟動腳本

不建議把 `LD_LIBRARY_PATH` 污染到所有系統程式，尤其若 OpenIndiana 系統服務發生異常時，應優先改用啟動腳本方式。

可建立：

```bash
vi ~/tw404t/env.sh
```

內容：

```bash
#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/BerkeleyDB.3.3-32/lib:/usr/gcc/10/lib:$LD_LIBRARY_PATH
```

使用時：

```bash
source ~/tw404t/env.sh
```

本案建議後續整理成專用啟動腳本，避免影響 `sshd` 等系統服務。

## 6. 啟動 DB Server

```bash
cd ~/tw404t/db
source ~/tw404t/env.sh
nohup ./db > db.log 2>&1 &
```

查看 log：

```bash
tail -f db.log
```

成功訊息：

```text
ENDRE DataBase Server ready, port: 45012
```

## 7. 停止 DB Server

查 PID：

```bash
ps -ef | grep './db'
```

停止：

```bash
kill <PID>
```

或：

```bash
pkill db
```

## 8. 重開機後注意事項

`nohup` 不是開機服務。重開機後：

```text
./db 會停止
LD_LIBRARY_PATH 也可能消失
```

因此重開機後至少要重新執行：

```bash
source ~/.profile
# 或
source ~/tw404t/env.sh
```

再啟動：

```bash
cd ~/tw404t/db
nohup ./db > db.log 2>&1 &
```

## 9. 本案實測狀態

已成功啟動：

```text
ENDRE DataBase Server initializing...
start cache thread
start select thread
start request threads: 4
start transact threads: 6
ENDRE DataBase Server ready, port: 45012
```
