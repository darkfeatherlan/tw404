# OpenIndiana 上編譯安裝 MySQL 5.0.86

本文件記錄本案實測成功的 MySQL 5.0.86 建置流程。

環境：

```text
Mac mini M1
UTM / QEMU x86_64 emulation
OpenIndiana x86 guest
MySQL 5.0.86 source distribution
GCC 10
GNU make
```

## 1. 前置套件

已安裝：

```bash
sudo pkg install developer/gcc-10
sudo pkg install developer/build/gnu-make
```

確認：

```bash
gcc --version
gmake --version
```

## 2. 解壓縮原始碼

```bash
cd ~
tar zxvf mysql-5.0.86.tar.gz
cd mysql-5.0.86
```

## 3. 設定編譯環境

本案使用 GCC 10：

```bash
export PATH=/usr/gcc/10/bin:$PATH
export CC=/usr/gcc/10/bin/gcc
export CXX=/usr/gcc/10/bin/g++
export CFLAGS="-O3"
export CXXFLAGS="-O3 -std=gnu++98 -fpermissive"
export CPPFLAGS="-O3"
```

注意：

```text
-O3 是英文字母 O，不是數字 0。
```

若誤打成：

```bash
-03
```

`./configure` 會失敗並出現：

```text
C compiler cannot create executables
```

## 4. configure

```bash
./configure \
  --prefix=/usr/local/mysql \
  --with-extra-charsets=all \
  --with-gnu-ld
```

成功後會產生 Makefile。

## 5. 編譯

```bash
gmake > build.log 2>&1
```

若需要重新編譯：

```bash
gmake clean
```

查看錯誤：

```bash
grep -n "error:" build.log | head -20
grep -n "\*\*\*" build.log | head -20
```

## 6. 安裝

```bash
sudo gmake install
```

確認安裝結果：

```bash
ls /usr/local/mysql/bin/
ls -l /usr/local/mysql/libexec/mysqld
```

應可看到：

```text
/usr/local/mysql/bin/mysql
/usr/local/mysql/bin/mysqld_safe
/usr/local/mysql/bin/mysql_install_db
/usr/local/mysql/libexec/mysqld
```

## 7. 初始化 MySQL system tables

```bash
cd /usr/local/mysql
sudo ./bin/mysql_install_db --user=$(whoami)
```

成功訊息應包含：

```text
Installing MySQL system tables... OK
Filling help tables... OK
```

若 `mysql_install_db` 找不到 `my_print_defaults`，確認實際位置：

```bash
find /usr/local/mysql -name my_print_defaults
```

本案實際位置：

```text
/usr/local/mysql/bin/my_print_defaults
```

可改用：

```bash
cd /usr/local/mysql
sudo ./bin/mysql_install_db \
  --basedir=/usr/local/mysql \
  --datadir=/usr/local/mysql/var \
  --user=$(whoami)
```

## 8. 啟動 MySQL

需在 `/usr/local/mysql` 目錄下啟動，避免 `mysqld_safe` 找不到相關檔案：

```bash
cd /usr/local/mysql
./bin/mysqld_safe &
```

若要寫 log：

```bash
cd /usr/local/mysql
nohup ./bin/mysqld_safe > mysqld_safe.log 2>&1 &
```

## 9. 確認 mysqld 是否啟動

```bash
ps -ef | grep mysqld
```

應可看到：

```text
/usr/local/mysql/libexec/mysqld
```

確認 3306 port：

```bash
netstat -an | grep 3306
```

應看到：

```text
*.3306    *.*    LISTEN
```

## 10. 登入 MySQL

首次登入：

```bash
/usr/local/mysql/bin/mysql -u root
```

確認版本：

```sql
select version();
```

結果：

```text
5.0.86
```

## 11. 設定 root 密碼

```bash
/usr/local/mysql/bin/mysqladmin -u root password 'your_password'
```

之後以密碼登入：

```bash
/usr/local/mysql/bin/mysql -u root -p
```

## 12. 確認 datadir

登入 MySQL 後：

```sql
show variables like 'datadir';
```

本案結果：

```text
/usr/local/mysql/var/
```

## 13. 測試資料庫與資料持久化

建立測試資料庫與資料表：

```sql
create database testdb;
use testdb;

create table t1 (
  id int primary key,
  name varchar(50)
);

insert into t1 values (1, 'lan');

select * from t1;
```

結果：

```text
+----+------+
| id | name |
+----+------+
|  1 | lan  |
+----+------+
```

關閉 MySQL：

```bash
/usr/local/mysql/bin/mysqladmin -u root -p shutdown
```

重新啟動：

```bash
cd /usr/local/mysql
./bin/mysqld_safe &
```

重新登入後確認資料仍存在：

```sql
use testdb;
select * from t1;
```

若資料仍存在，表示 MySQL 安裝、啟動、資料目錄與持久化皆正常。

## 14. 本次已確認結果

```text
MySQL version: 5.0.86
Install path: /usr/local/mysql
Data directory: /usr/local/mysql/var/
Port: 3306 LISTEN
Root password: configured
Create database: OK
Create table: OK
Insert/select: OK
Restart persistence: OK
```

## 15. 已排除問題

### configure 失敗

原因：

```bash
CFLAGS="-03"
CPPFLAGS="-03"
```

誤將 `-O3` 打成 `-03`。

正確：

```bash
CFLAGS="-O3"
CPPFLAGS="-O3"
```

### mysqld_safe 找不到檔案

若從 `/usr/local` 執行：

```bash
/usr/local/mysql/bin/mysqld_safe &
```

可能出現找不到 `my_print_defaults` 或 `mysqld` 的錯誤。

解法：

```bash
cd /usr/local/mysql
./bin/mysqld_safe &
```

或明確指定：

```bash
/usr/local/mysql/bin/mysqld_safe \
  --basedir=/usr/local/mysql \
  --datadir=/usr/local/mysql/var &
```

## 16. 備份建議

安裝成功後可備份 MySQL 安裝目錄：

```bash
cd /usr/local
sudo tar czf mysql-5.0.86-openindiana-working.tar.gz mysql
```

備份原始碼目錄：

```bash
cd ~
tar czf mysql-5.0.86-src-working.tar.gz mysql-5.0.86
```
