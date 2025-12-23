local preycards = TalkAction("/preycards")

function preycards.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	local amount = tonumber(param) or 5
	player:addPreyWildcards(amount)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You received %d prey wildcards! Total: %d", amount, player:getPreyWildcards()))
	return false
end

preycards:register()
