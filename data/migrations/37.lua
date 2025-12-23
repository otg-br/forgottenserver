function onUpdateDatabase()
	print("> Updating database to version 39 (prey system)")

	db.query([[
		CREATE TABLE IF NOT EXISTS `player_prey` (
			`player_id` int NOT NULL,
			`slot` tinyint NOT NULL,
			`state` tinyint NOT NULL DEFAULT 0,
			`raceid` varchar(100) NOT NULL DEFAULT '',
			`bonus_type` tinyint NOT NULL DEFAULT 0,
			`bonus_value` tinyint NOT NULL DEFAULT 0,
			`bonus_grade` tinyint NOT NULL DEFAULT 0,
			`bonus_time_left` smallint NOT NULL DEFAULT 0,
			`free_reroll` smallint NOT NULL DEFAULT 0,
			`option` tinyint NOT NULL DEFAULT 0,
			`monster_list` text,
			PRIMARY KEY (`player_id`, `slot`),
			FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
		) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
	]])

	db.query([[
		ALTER TABLE `players` ADD `prey_wildcards` int NOT NULL DEFAULT 0;
	]])

	return true
end
