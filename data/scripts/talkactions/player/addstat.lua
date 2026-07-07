local addStatCommand = TalkAction("/addstat")

function addStatCommand.onSay(player, words, param)
    local parts = param:split(" ")
    if #parts ~= 2 then
        player:sendCancelMessage("Usage: /addstat <stat> <amount>")
        player:sendCancelMessage("Stats: strength, dexterity, constitution, intelligence, wisdom, charisma")
        return true
    end
    
    local stat = parts[1]:lower()
    local amount = tonumber(parts[2])
    
    if not amount or amount <= 0 then
        player:sendCancelMessage("Amount must be a positive number")
        return true
    end
    
    if player:spendStatPoint(stat, amount) then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Added " .. amount .. " points to " .. stat .. "!")
        player:sendStats()
    else
        player:sendCancelMessage("Failed to allocate points. Check your unspent points!")
    end
    
    return true
end

addStatCommand:setDescription("[Usage]: /addstat <stat> <amount> - Allocate stat points")
addStatCommand:register()