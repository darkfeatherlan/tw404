# UTM Solaris / OpenIndiana 設定筆記

來源：UTM Discussion #5752：Solaris 11.4 x86 running on Mac M1 Pro using UTM，以及本案實測回報。

## 1. 這篇的意義

該討論串證實：

- Apple Silicon Mac 上使用 UTM / QEMU 有人成功跑 Solaris 11.4 x86。
- OpenIndiana 也有人回報類似可行。
- 但設定細節很重要，特別是 machine type、disk、network、USB、UEFI、display。

本案 `tw404t` 需要 x86 Solaris-like guest，因此這篇對 UTM 設定有參考價值。

## 2. 本案目前實測修正

使用者在 OpenIndiana / UTM 安裝過程遇到：

```text
Shell>
qemu-x86_64-softmmu: combined size ... exceeds 8388608 bytes
```

實測後確認只要調整：

```text
UEFI Boot: Off
Display: VGA
```

即可避開問題。

判斷：

- `Shell>` 是進入 UEFI Shell，代表不應使用 UEFI boot。
- `combined size ... exceeds 8388608 bytes` 多半與傳統 BIOS Option ROM 空間不足相關，`virtio-vga` 可能造成 ROM 過大。
- 改為 `VGA` 可降低開機 ROM 負擔。

因此本案 OpenIndiana / UTM 主線設定應改為：

```text
Architecture: x86_64
Machine: Standard PC (i440FX + PIIX, 1996)
UEFI Boot: Off
Display: VGA
USB: Disabled
Network: e1000 Shared Network
Disk: VirtIO 或 IDE，若 VirtIO 有問題再改 IDE
RAM: 4096 MiB
CPU Cores: 2
```

## 3. OpenIndiana 建議設定（本案主線）

```text
Architecture: x86_64
Machine: Standard PC (i440FX + PIIX, 1996)
UEFI Boot: Off
RAM: 4096 MiB
CPU Cores: 2
USB: Disabled
Display: VGA
Network: Intel Gigabit Ethernet (e1000), Shared Network
Disk: VirtIO（若安裝或開機異常，改 IDE）
```

若仍遇到 `combined size ... exceeds 8388608 bytes`：

```text
1. 確認 Display 是 VGA，不是 virtio-vga。
2. 暫時關閉 Network。
3. 關閉 Sound。
4. 只保留 1 顆硬碟 + 1 個 ISO 光碟。
5. Disk 改 IDE。
```

## 4. Solaris 11.4 x86 成功設定摘要

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
- 若本案遇到 Option ROM 問題，Display 改 VGA。

## 5. Solaris 11.4 另一組可行設定

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

## 6. OpenIndiana 與 Solaris 11.4 差異

討論串提到 OpenIndiana 類似可行，但有差異：

```text
OpenIndiana:
- Disable USB
- Disk: VirtIO
- Multicore works on latest version

Solaris 11.4:
- Disk: IDE 較穩
```

本案實測補充：

```text
OpenIndiana:
- UEFI Boot 必須 Off
- Display 用 VGA 較穩
```

## 7. 不建議設定

### UEFI Boot

若出現：

```text
Shell>
```

代表進入 EFI Shell。處理方式：

```text
UEFI Boot: Off
```

### Display: virtio-vga

若出現：

```text
combined size ... exceeds 8388608 bytes
```

處理方式：

```text
Display: VGA
```

### Solaris 11.4 不建議 VirtIO Disk

```text
Disk: VirtIO
```

原因：討論串有人回報 Solaris 11.4 會 boot loop。

### USB 問題

若遇到：

```text
UHCI host controller is unusable
No SOF interrupts have been received
```

處理方式：

```text
Disable USB
或改 USB 2
```

### Machine type

不優先使用：

```text
Standard PC (pc-q35-7.2)
```

因有人遇到：

```text
SATA disk device at port 0 does not support LBA
maintenance mode
```

優先使用：

```text
Standard PC (i440FX + PIIX, 1996)
```

## 8. 安裝完成後的第一輪檢查

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

## 9. 放入 tw404t 後的檢查

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

## 10. 對 TW404T 的實務結論

目前最值得測的兩條線：

```text
1. OpenIndiana x86_64 on UTM
   - i440FX + PIIX
   - UEFI Boot Off
   - Display VGA
   - USB disabled
   - Disk VirtIO first, IDE fallback
   - Network e1000 shared

2. Solaris 11.4 x86 on UTM
   - i440FX + PIIX
   - UEFI Boot Off
   - CPU Opteron_G1-v1
   - Display VGA if virtio-vga fails
   - Disk IDE
   - Network e1000 shared
```

若 OpenIndiana 可以補齊舊 library，優先用 OpenIndiana。若 OpenIndiana 不相容，再測 Solaris 11.4。
