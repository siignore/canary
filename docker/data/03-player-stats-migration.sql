-- Player Stat System Migration
-- Adds 7 new columns to players table for character attribute system

-- Check if columns exist before adding (safe for re-runs)
ALTER TABLE `players`
ADD COLUMN IF NOT EXISTS `stat_strength` INT(11) NOT NULL DEFAULT '0' AFTER `animus_mastery`,
ADD COLUMN IF NOT EXISTS `stat_dexterity` INT(11) NOT NULL DEFAULT '0' AFTER `stat_strength`,
ADD COLUMN IF NOT EXISTS `stat_constitution` INT(11) NOT NULL DEFAULT '0' AFTER `stat_dexterity`,
ADD COLUMN IF NOT EXISTS `stat_intelligence` INT(11) NOT NULL DEFAULT '0' AFTER `stat_constitution`,
ADD COLUMN IF NOT EXISTS `stat_wisdom` INT(11) NOT NULL DEFAULT '0' AFTER `stat_intelligence`,
ADD COLUMN IF NOT EXISTS `stat_charisma` INT(11) NOT NULL DEFAULT '0' AFTER `stat_wisdom`,
ADD COLUMN IF NOT EXISTS `unspent_stat_points` INT(11) NOT NULL DEFAULT '0' AFTER `stat_charisma`;

-- Grant initial stat points to existing test accounts based on their level
UPDATE `players` SET `unspent_stat_points` = `level` / 5 WHERE `level` > 0;

-- Log completion
SELECT 'Player stat system migration completed' as status;
