SELECT id,
  name,
  class,
  guildId,
  level,
  emoji
FROM heroes
WHERE class = 'Sorcerer'
ORDER BY level DESC
LIMIT 3;
SELECT name,
  class,
  emoji,
  guildName,
  skills
FROM heroes
  JOIN guilds ON guilds.id = heroes.guildId
  JOIN classes ON heroes.class = classes.type
ORDER BY name;
SELECT guildName,
  banner,
  COUNT(heroes.id) AS memberCount
FROM guilds
  JOIN heroes ON heroes.guildId = guilds.id
GROUP BY guilds.id;
SELECT guildName,
  banner,
  SUM(quests.reward) AS rewardSum
FROM guilds
  JOIN quests ON quests.completedById = guilds.id
GROUP BY guilds.id
ORDER BY rewardSum DESC;
SELECT guildName,
  banner,
  reputation,
  SUM(IF(heroes.class IN('Assassin', 'Rogue'), 1, 0)) AS criminals
FROM guilds
  JOIN heroes on heroes.guildId = guilds.id
GROUP BY guilds.id
ORDER BY criminals DESC
LIMIT 3;
SELECT guildName,
  banner,
  SUM(IF (quests.category = 'slaying', 1, 0)) AS slayedCount
FROM guilds
  LEFT JOIN quests on quests.completedById = guilds.id
GROUP BY guilds.id
LIMIT 1;
CREATE VIEW heroes_with_details AS
SELECT heroes.id,
  heroes.name,
  heroes.class,
  heroes.guildId,
  heroes.level,
  guilds.guildName,
  classes.skills
FROM heroes
  JOIN guilds on heroes.guildId = guilds.id
  JOIN classes on classes.type = heroes.class;
SELECT *
FROM heroes_with_details;
SELECT location,
  SUM(IF(quests.difficulty = 'easy', 1, 0)) AS easy,
  SUM(IF(quests.difficulty = 'medium', 1, 0)) AS medium,
  SUM(IF(quests.difficulty = 'hard', 1, 0)) AS hard,
  SUM(IF(quests.difficulty = 'deadly', 1, 0)) AS deadly,
  SUM(quests.reward) AS rewardTotal
FROM quests
GROUP BY quests.location
ORDER BY rewardTotal DESC;
SELECT guildName,
  banner,
  SUM(IF(quests.description LIKE '%dragon%', 1, 0)) AS dragonsSlayed
FROM guilds
  JOIN quests ON guilds.id = quests.completedById
GROUP BY guilds.id
HAVING dragonsSlayed > 0
ORDER BY dragonsSlayed DESC;
SELECT guildName,
  banner,
  COUNT(loot.id) AS itemCount,
  GROUP_CONCAT(loot.emoji SEPARATOR ' - ') AS items,
  SUM(loot.value) AS totalValue
FROM quests
  JOIN guilds on guilds.id = quests.completedById
  JOIN loot on quests.id = loot.questId
GROUP BY guilds.id
ORDER BY totalValue DESC;
-- PROCEDURE EXAMPLE
CREATE PROCEDURE UpdateGuildRep(IN targetId INT) BEGIN
DECLARE newRep INT;
SELECT SUM(quests.reward) INTO newRep
FROM guilds
  LEFT JOIN quests ON quests.completedById = guilds.id
WHERE guilds.id = targetId
GROUP BY guilds.id;
UPDATE guilds
SET reputation = newRep
WHERE guilds.id = targetId;
END $$ CALL UpdateGuildRep(1);
SELECT guildName,
  banner,
  reputation
FROM guilds;
-- TRIGGER EXAMPLE
DELIMITER $$ CREATE TRIGGER on_update_quests
AFTER
UPDATE ON quests FOR EACH ROW BEGIN CALL UpdateGuildRep(NEW.completedById),
  CALL IncreaseHeroLevel(NEW.completedById);
END $$ DELIMITER;
--UPDATE
UPDATE quests
SET completed = true,
  completedById = 13
WHERE id = 108;
-- MY PROCEDURE
CREATE PROCEDURE IncreaseHeroLevel(IN guildId INT) BEGIN
UPDATE heroes
SET level = level + 1
WHERE heroes.guildId = guildId;
END $$ TRIGGERS;