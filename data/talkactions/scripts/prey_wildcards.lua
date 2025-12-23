-- Comando para adicionar Prey Wildcards
-- Use: /preycards [quantidade]
-- Exemplo: /preycards 10

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	local amount = tonumber(param)
	if not amount or amount <= 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Use: /preycards [quantidade]")
		return false
	end
	
	player:addPreyWildcards(amount)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu " .. amount .. " Prey Wildcards!")
	
	return false
end
