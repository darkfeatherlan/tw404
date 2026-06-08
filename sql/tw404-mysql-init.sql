-- TW404 MySQL initialization schema
-- Generated from the complete db-inst.txt uploaded in ChatGPT conversation.
-- Target: MySQL 5.0.x on OpenIndiana/Solaris runtime.
--
-- Usage:
--   /usr/local/mysql/bin/mysql -u root -p < sql/tw404-mysql-init.sql
--
-- Notes:
--   1. Database and table charsets are explicitly set to utf8.
--   2. The original db-inst.txt used many "use dbname" lines without semicolons.
--      This file fixes those statements.
--   3. The original password string appears as "vlql=nrt" where the last character
--      before '=' is lowercase L, not number 1.
--   4. This file intentionally avoids changing the global MySQL my.cnf. Charset is
--      handled at database/table level for safer reuse on /usr/local/mysql builds.
--   5. The original guide also forced the old MySQL password hash
--      6e4637a643a8fc2b for gamedb@twsrv. This file applies the same hash to
--      common local/LAN host forms used by DBs.ttales. If your server IP changes,
--      adjust or add the corresponding gamedb@<IP> grant.

SET NAMES utf8;

GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'localhost' IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'127.0.0.1' IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'%' IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'twsrv' IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'gamedb'@'192.168.1.149' IDENTIFIED BY 'vlql=nrt' WITH GRANT OPTION;

UPDATE mysql.user
SET Password='6e4637a643a8fc2b'
WHERE User='gamedb'
  AND Host IN ('localhost','127.0.0.1','%','twsrv','192.168.1.149');

FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS ttales12_account DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_castle DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_episode DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_friendList DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_gamestat DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_group DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_guild DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_pet DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_refuse DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS ttales12_share DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
USE ttales12_account;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS delete_character_list;
CREATE TABLE `account` (
`tid` int(10) unsigned NOT NULL,
 `tusername` varchar(30) NOT NULL,
 `tpassword` varchar(30) NOT NULL,
 `temail` varchar(50) NOT NULL,
 `tregtime` datetime default NULL,
 `tregip` varchar(45) NOT NULL,
 `id` int(10) unsigned NOT NULL auto_increment,
 `username` varchar(30) NOT NULL,
 `password` varchar(30) NOT NULL,
 `email` varchar(50) NOT NULL,
 `regtime` datetime default NULL,
 `regip` varchar(45) NOT NULL,
 `passwd` varchar(30) NOT NULL,
 PRIMARY KEY  USING BTREE (`id`),
 UNIQUE KEY `UNIQUE` USING BTREE (`tusername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
CREATE TABLE `delete_character_list` (
`requestdate` datetime NOT NULL,
 PRIMARY KEY  USING BTREE (`requestdate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
USE ttales12_castle;
DROP TABLE IF EXISTS castle;
DROP TABLE IF EXISTS castle_entrusted;
DROP TABLE IF EXISTS guardian;
CREATE TABLE `castle` (
`castleNum` int(11) NOT NULL default '0',
 `castleName` varchar(50) default NULL,
 `king` varchar(20) default NULL,
 `guild` varchar(20) default NULL,
 `loser` varchar(20) default NULL,
 `state` int(11) NOT NULL default '0',
 `fortitude` int(11) NOT NULL default '0',
 `remainTime` int(11) NOT NULL default '0',
 `victories` int(11) NOT NULL default '0',
 `challengerGuild` varchar(20) default NULL,
 `victoryTick` int(11) NOT NULL default '0',
 `readyGuild` varchar(20) default NULL,
 UNIQUE KEY `castleNum` (`castleNum`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `castle_entrusted` (
 `castleNum` int(11) NOT NULL default '0',
 `image` blob
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guardian` (
 `guardianNumber` int(11) NOT NULL default '0',
 `ownerGuildName` varchar(20) NOT NULL default 'NO_NAME',
 `catchedTick` int(10) unsigned NOT NULL default '0',
 UNIQUE KEY `guardianNumber` (`guardianNumber`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_episode;
DROP TABLE IF EXISTS goodwill_data;
DROP TABLE IF EXISTS switch_data;
DROP TABLE IF EXISTS switch_log;
CREATE TABLE `goodwill_data` (
`characterid` varchar(32) NOT NULL default '',
 `goodwill` blob NOT NULL,
 PRIMARY KEY  (`characterid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `switch_data` (
`characterid` varchar(32) NOT NULL default '',
 `episode` smallint(5) unsigned NOT NULL default '0',
 `switch` blob NOT NULL,
 UNIQUE KEY `characterId` (`characterid`,`episode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `switch_log` (
`name` varchar(50) NOT NULL default '',
 `episode` int(11) NOT NULL default '0',
 `tick` int(10) unsigned NOT NULL default '0',
 `log` varchar(250) NOT NULL default '',
 UNIQUE KEY `switchLogUniqueIndex` (`name`,`episode`,`tick`,`log`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_friendList;
DROP TABLE IF EXISTS FLfriend;
DROP TABLE IF EXISTS FLgroup;
CREATE TABLE `FLfriend` (
`myName` varchar(50) NOT NULL default '',
 `friendName` varchar(50) NOT NULL default '',
 `groupId` int(11) default '0',
 UNIQUE KEY `uIndex` (`myName`,`friendName`),
 KEY `myList` (`myName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `FLgroup` (
`id` int(11) NOT NULL default '0',
 `name` varchar(50) NOT NULL default '',
 `ownerName` varchar(50) NOT NULL default '',
 UNIQUE KEY `idIndex` (`id`,`ownerName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_gamestat;
DROP TABLE IF EXISTS GSMonster;
DROP TABLE IF EXISTS GSSoldItem;
DROP TABLE IF EXISTS GSWorld;
CREATE TABLE `GSMonster` (
`monName` varchar(50) NOT NULL default '',
 `level` int(11) default '0',
 `killed` int(11) default '0',
 `updatetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `GSSoldItem` (
`itemName` varchar(50) NOT NULL default '',
 `sold` int(11) default '0',
 `updatetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `GSWorld` (
 `worldName` varchar(50) NOT NULL default '',
 `level` int(11) NOT NULL default '0',
 `inCount` int(11) default '0',
 `stayTime` int(11) default '0',
 `updatetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_group;
DROP TABLE IF EXISTS member;
CREATE TABLE `member` (
`name` varchar(50) NOT NULL default '',
 `team` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `db` int(11) NOT NULL default '0',
 `pk` int(11) NOT NULL default '0',
 `tick` int(11) NOT NULL default '0',
 `level` int(11) NOT NULL default '0',
 `state` bigint(20) unsigned NOT NULL default '0',
 UNIQUE KEY `nameindex` (`name`),
 KEY `teamindex` (`team`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 PACK_KEYS=1;
USE ttales12_guild;
DROP TABLE IF EXISTS guild;
DROP TABLE IF EXISTS guildAnnounce;
DROP TABLE IF EXISTS guildBank;
DROP TABLE IF EXISTS guildBankLog;
DROP TABLE IF EXISTS guildLog;
DROP TABLE IF EXISTS guildMember;
CREATE TABLE `guild` (
`name` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `subType` int(11) NOT NULL default '0',
 `birthTick` int(10) unsigned NOT NULL default '0',
 `markType` int(11) NOT NULL default '0',
 `markResourceId` int(10) unsigned NOT NULL default '0',
 `level` int(11) NOT NULL default '0',
 `acceptMinLevel` int(11) NOT NULL default '0',
 `acceptMaxLevel` int(11) NOT NULL default '0',
 `hpUrl` varchar(80) NOT NULL default '',
 `intro` varchar(250) NOT NULL default '',
 `exp` int(10) unsigned NOT NULL default '0',
 `goodwill` int(10) unsigned NOT NULL default '0',
 `voteTick` int(10) unsigned NOT NULL default '0',
 `taxLevied` int(11) NOT NULL default '0',
 `currentTax` int(11) NOT NULL default '0',
 `taxDelayed` int(11) NOT NULL default '0',
 `collectingTaxTick` int(10) unsigned NOT NULL default '0',
 `taxDelayMonth` int(11) NOT NULL default '0',
 `state` int(10) unsigned NOT NULL default '0',
 UNIQUE KEY `guildNameIndex` (`name`,`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guildAnnounce` (
`name` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `tick` int(10) unsigned NOT NULL default '0',
 `announce` varchar(250) NOT NULL default '',
 UNIQUE KEY `guildAnnounceUniqueIndex` (`name`,`type`,`tick`,`announce`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guildBank` (
`guildName` varchar(50) NOT NULL default '',
 `guildType` int(11) NOT NULL default '0',
 `attribute` blob NOT NULL,
 UNIQUE KEY `guildBankIndex` (`guildName`,`guildType`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guildBankLog` (
`name` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `tick` int(10) unsigned NOT NULL default '0',
 `log` varchar(250) NOT NULL default '',
 UNIQUE KEY `guildBankLogUniqueIndex` (`name`,`type`,`tick`,`log`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guildLog` (
`name` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `tick` int(10) unsigned NOT NULL default '0',
 `log` varchar(250) NOT NULL default '',
 UNIQUE KEY `guildLogUniqueIndex` (`name`,`type`,`tick`,`log`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `guildMember` (
`name` varchar(50) NOT NULL default '',
 `type` int(11) NOT NULL default '0',
 `guildName` varchar(50) NOT NULL default '',
 `guildType` int(11) NOT NULL default '0',
 `title` varchar(50) NOT NULL default '',
 `DBID` int(11) NOT NULL default '0',
 `level` int(11) NOT NULL default '0',
 `joinTick` int(10) unsigned NOT NULL default '0',
 `resignTick` int(10) unsigned NOT NULL default '0',
 `rank` int(11) NOT NULL default '0',
 `vote` int(11) NOT NULL default '0',
 `logoutTick` int(10) unsigned NOT NULL default '0',
 `exp` int(10) unsigned NOT NULL default '0',
 `state` int(10) unsigned NOT NULL default '0',
 UNIQUE KEY `guildMemberNameIndex` (`guildName`,`guildType`,`name`),
 KEY `guildMemberIndex` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_pet;
DROP TABLE IF EXISTS pet;
CREATE TABLE `pet` (
 `owner` varchar(16) NOT NULL default '',
 `type` int(11) NOT NULL default '-1',
 `nutrition` int(11) NOT NULL default '0',
 `nutritionTick` int(11) NOT NULL default '0',
 `sanitation` int(11) NOT NULL default '0',
 `sanitationTick` int(11) NOT NULL default '0',
 `remainTime` int(11) NOT NULL default '0',
 `eggid` varchar(8) NOT NULL default 'NO_NAME',
 `dbid` varchar(8) NOT NULL default 'NO_NAME',
 `color` int(11) NOT NULL default '0',
 `name` varchar(32) NOT NULL default 'Pet',
 `level` int(11) NOT NULL default '0',
 `vital` int(11) NOT NULL default '0',
 `exp` int(11) NOT NULL default '0',
 `birthTime` int(11) NOT NULL default '0',
 `bHibernated` int(11) NOT NULL default '0',
 `partnerOwner` varchar(16) NOT NULL default 'NO_NAME',
 `partner` int(11) NOT NULL default '0',
 `cleanItem` blob NOT NULL,
 `nutritionItem` blob NOT NULL,
 `foodItem` blob NOT NULL,
 `skills` blob,
 UNIQUE KEY `owner` (`owner`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_refuse;
DROP TABLE IF EXISTS refuse;
CREATE TABLE `refuse` (
 `ownerName` varchar(50) NOT NULL default '',
 `otherName` varchar(50) NOT NULL default '',
 UNIQUE KEY `uIndex` (`ownerName`,`otherName`),
 KEY `myList` (`ownerName`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
USE ttales12_share;
DROP TABLE IF EXISTS share;
CREATE TABLE `share` (
 `idx` int(11) NOT NULL auto_increment,
 `receiver` varchar(16) NOT NULL default '',
 `sender` varchar(16) NOT NULL default '',
 `time` int(11) NOT NULL default '0',
 `image` blob,
 `seed` int(11) NOT NULL default '0',
 UNIQUE KEY `shareItemIndex` (`idx`,`receiver`,`sender`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
