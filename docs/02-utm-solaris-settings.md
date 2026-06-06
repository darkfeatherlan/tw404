# UTM Solaris / OpenIndiana 設定筆記

來源：UTM Discussion #5752：Solaris 11.4 x86 running on Mac M1 Pro using UTM。

## 1. 這篇的意義

該討論串證實：

- Apple Silicon Mac 上使用 UTM / QEMU 有人成功跑 Solaris 11.4 x86。
- OpenIndiana 也有人回報類似可行。
- 但設定細節很重要，特別是 machine type、disk、network、USB。

本案 `tw404t` 需要 x86 Solaris-like guest，因此這篇對 UTM 設定有參考價值。

## 2. Solaris 11.4 x86 成功設定摘要

討論串中有人回報在 MacBook Pro M3 Pro + UTM 4.4.4 成功安裝 Solaris 11.4 x86，設定如下：

```text
Architecture: x86_64
UEFI Boot: disabled
RNG Device: checked
Balloon Device: checked
Use local time for base clock: checked
Machine: Standard PC (i440FX + PIIX, 1996) / pc-i440fx-7.2
CPU: AMD Opteron 240 (Gen 1 Class Opteron) / Opteron_G1-v1
Exclude CPU feature: mca
RAM: 4 GB
USB: USB 2
Display: virtio-vga
Network: Intel Gigabit Ethernet (e1000), shared
Sound: Intel 82801AA AC97 Audio
```

注意：

- 開機會出現 AMD microcode patch 相關訊息，但可繼續。
- 開機很慢。

## 3. Solaris 11.4 另一組可行設定

另有使用者回報成功設定：

```text
Machine: Standard PC (i440FX + PIIX, 1996)
RAM: 8192 MiB
CPU Cores: 4
UEFI Boot: disabled
Display: virtio-vga
Network: virtio-net-pci
Disk: IDE
```

重要結論：

```text
Solaris 11.4 使用 IDE disk 較穩。
切換成 VirtIO disk 會 boot loop。
```

## 4. OpenIndiana 設定摘要

同一討論串也提到 OpenIndiana 類似，但有差異：

```text
Disable USB
Disk: VirtIO
Multicore works on latest version
```

因此 OpenIndiana 與 Solaris 11.4 的磁碟建議不同：

```text
Solaris 11.4 -> IDE disk
OpenIndiana  -> VirtIO disk + Disable USB
```

## 5. 本案建議 UTM 測試順序

### 第一組：OpenIndiana

```text
Architecture: x86_64
Machine: Standard PC (i440FX + PIIX, 1996)
UEFI Boot: disabled
CPU: default 或 Opteron_G1-v1
RAM: 4096 MiB
Cores: 2 或 4
USB: disabled
Display: virtio-vga
Network: e1000 shared 或 virtio-net-pci
Disk: VirtIO
```

若網路不通，改試：

```text
Network: Intel Gigabit Ethernet (e1000), shared
```

### 第二組：Solaris 11.4 x86

```text
Architecture: x86_64
Machine: Standard PC (i440FX + PIIX, 1996)
UEFI Boot: disabled
CPU: AMD Opteron 240 / Opteron_G1-v1
Exclude CPU feature: mca
RAM: 4096-8192 MiB
Cores: 2 或 4
USB: USB 2 或 disabled
Display: virtio-vga
Network: Intel Gigabit Ethernet (e1000), shared
Disk: IDE
Use local time for base clock: checked
```

安裝卡在 99% 時：

```text
不要立刻重開。
有人回報等 1-2 小時後仍會完成。
觀察 qcow2 image 是否仍在變大。
```

## 6. 不建議設定

### Solaris 11.4 不建議

```text
Disk: VirtIO
```

原因：討論串有人回報會 boot loop。

### USB 問題

原發文者曾遇到：

```text
UHCI host controller is unusable
No SOF interrupts have been received
```

若遇到類似錯誤，請嘗試：

```text
Disable USB
或改 USB 2
```

### Machine type

原發文者使用：

```text
Standard PC (pc-q35-7.2)
```

曾遇到：

```text
SATA disk device at port 0 does not support LBA
maintenance mode
```

後續成功案例多使用：

```text
Standard PC (i440FX + PIIX, 1996)
```

因此本案優先使用 i440FX + PIIX。

## 7. 安裝完成後的第一輪檢查

```bash
uname -a
isainfo -v
ifconfig -a
psrinfo -v
```

確認：

```text
架構應為 i386 / amd64 / x86_64 類
不要是 sparc / sun4u / sun4v
```

## 8. 放入 tw404t 後的檢查

```bash
cd ~
/usr/gnu/bin/tar zxvf tw404t.tar.gz
cd tw404t
file db/db
file ttales0/ttales
ldd db/db
ldd ttales0/ttales
```

若 `ldd` 顯示缺少：

```text
libdb-3.3.so
libstdc++.so.6
libgcc_s.so.1
libz.so
```

再進入 BerkeleyDB / GCC runtime / MySQL 5.0 補齊流程。

## 9. 對 TW404T 的實務結論

目前最值得測的兩條線：

```text
1. OpenIndiana x86_64 on UTM
   - USB disabled
   - Disk VirtIO
   - Network e1000 or virtio-net-pci

2. Solaris 11.4 x86 on UTM
   - i440FX + PIIX
   - UEFI disabled
   - CPU Opteron_G1-v1
   - Disk IDE
   - Network e1000 shared
```

若 OpenIndiana 可以補齊舊 library，優先用 OpenIndiana。若 OpenIndiana 不相容，再測 Solaris 11.4。
