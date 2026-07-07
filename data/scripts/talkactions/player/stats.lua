local statsCommand = TalkAction("!stats")

function statsCommand.onSay(player, words, param)
    local text = "Character Attributes:\n\n"
    
    -- Get all stats
    local strength = player:getStat(STAT_STRENGTH) or player:getStatStrength()
    local dexterity = player:getStat(STAT_DEXTERITY) or player:getStatDexterity()
    local constitution = player:getStat(STAT_CONSTITUTION) or player:getStatConstitution()
    local intelligence = player:getStat(STAT_INTELLIGENCE) or player:getStatIntelligence()
    local wisdom = player:getStat(STAT_WISDOM) or player:getStatWisdom()
    local charisma = player:getStat(STAT_CHARISMA) or player:getStatCharisma()
    local unspentPoints = player:getUnspentStatPoints()
    
    -- Format the display
    text = text .. "Strength: " .. strength .. "\n"
    text = text .. "Dexterity: " .. dexterity .. "\n"
    text = text .. "Constitution: " .. constitution .. "\n"
    text = text .. "Intelligence: " .. intelligence .. "\n"
    text = text .. "Wisdom: " .. wisdom .. "\n"
    text = text .. "Charisma: " .. charisma .. "\n"
    text = text .. "\nUnspent Points: " .. unspentPoints .. "\n"
    
    -- Show stat effects
    text = text .. "\n---Effects---\n"
    text = text .. "Melee Damage: +" .. math.floor(strength / 5) .. "\n"
    text = text .. "Attack Speed: -" .. math.floor((dexterity / 10) * 50) .. "ms\n"
    text = text .. "Max Health: +" .. math.floor(constitution / 2) .. "\n"
    text = text .. "Magic Level: +" .. math.floor(intelligence / 10) .. "\n"
    text = text .. "Max Mana: +" .. math.floor(wisdom / 2) .. "\n"
    text = text .. "NPC Prices: " .. math.floor(charisma / 5) .. "%\n"
    
    player:showTextDialog(639, text)
    return true
end

statsCommand:setDescription("[Usage]: !stats - Display your character attributes")
statsCommand:register()