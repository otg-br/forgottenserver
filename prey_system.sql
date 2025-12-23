-- Prey System Database Tables
-- Add this to your database after running schema.sql

-- Table for prey slots data
CREATE TABLE IF NOT EXISTS `player_prey` (
  `player_id` int NOT NULL,
  `slot` tinyint NOT NULL,
  `state` tinyint NOT NULL DEFAULT '0',
  `raceid` varchar(250) NOT NULL DEFAULT '',
  `bonus_type` tinyint NOT NULL DEFAULT '0',
  `bonus_value` smallint NOT NULL DEFAULT '0',
  `bonus_grade` tinyint NOT NULL DEFAULT '0',
  `bonus_time_left` smallint NOT NULL DEFAULT '0',
  `free_reroll` bigint NOT NULL DEFAULT '0',
  `option` tinyint NOT NULL DEFAULT '0',
  `monster_list` text DEFAULT NULL,
  PRIMARY KEY (`player_id`, `slot`),
  FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;

-- Add prey wildcards column to players table
ALTER TABLE `players` ADD COLUMN `prey_wildcards` int unsigned NOT NULL DEFAULT '0' AFTER `stamina`;

-- Optional: Add initial wildcards to existing players (remove this line if you don't want to give free wildcards)
-- UPDATE `players` SET `prey_wildcards` = 5;
