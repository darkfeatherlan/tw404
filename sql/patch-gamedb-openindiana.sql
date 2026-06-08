-- Patch: allow MySQL gamedb login from hostname openindiana.
-- Use this when the OpenIndiana hostname has not been changed to twsrv.
--
-- Usage:
--   /usr/local/mysql/bin/mysql -u root -p < sql/patch-gamedb-openindiana.sql

GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'openindiana'
IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;

UPDATE mysql.user
SET Password='6e4637a643a8fc2b'
WHERE User='gamedb'
  AND Host='openindiana';

FLUSH PRIVILEGES;
