local preyunlock = TalkAction("/preyunlock")

function preyunlock.onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end
	
	if param == "" then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Use: /preyunlock [slotId] or /preyunlock all")
		return false
	end
	
	if param == "all" then
		for slotId = 0, 2 do
			local monsterList = getRandomPreyMonsters(9)
			local preyData = {
				state = 3,
				bonusType = 0,
				bonusValue = 0,
				bonusGrade = 0,
				preyMonster = "",
				timeLeft = 0,
				preyList = monsterList
			}
			player:setPreyData(slotId, preyData)
			player:setFreeRerollTime(slotId, 0)
		end
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "All prey slots unlocked!")
		return false
	end
	
	local slotId = tonumber(param)
	if not slotId or slotId < 0 or slotId > 2 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid slot! Use 0, 1 or 2")
		return false
	end
	
	local monsterList = getRandomPreyMonsters(9)
	local preyData = {
		state = 3,
		bonusType = 0,
		bonusValue = 0,
		bonusGrade = 0,
		preyMonster = "",
		timeLeft = 0,
		preyList = monsterList
	}
	player:setPreyData(slotId, preyData)
	player:setFreeRerollTime(slotId, 0)
	
	local msg = NetworkMessage()
	msg:addByte(0xE8)
	msg:addByte(slotId)
	msg:addByte(3)
	msg:addByte(#monsterList)
	for _, monsterName in ipairs(monsterList) do
		local mType = MonsterType(monsterName)
		if mType then
			msg:addString(monsterName)
			local outfit = mType:getOutfit()
			msg:addU16(outfit.lookType)
			if outfit.lookType == 0 then
				msg:addU16(outfit.lookTypeEx or 0)
			else
				msg:addByte(outfit.lookHead)
				msg:addByte(outfit.lookBody)
				msg:addByte(outfit.lookLegs)
				msg:addByte(outfit.lookFeet)
				msg:addByte(outfit.lookAddons)
			end
		end
	end
	msg:addU32(0)
	msg:addByte(0)
	msg:sendToPlayer(player)
	msg:delete()
	
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Prey slot " .. slotId .. " unlocked!")
	return false
end

preyunlock:register()
