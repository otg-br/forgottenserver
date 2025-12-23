-- Helper function to send monster outfit
local function sendMonsterOutfit(msg, monsterType)
	if not monsterType then
		msg:addU16(0)
		return
	end
	
	local outfit = monsterType:getOutfit()
	msg:addU16(outfit.lookType)
	
	if outfit.lookType == 0 then
		msg:addU16(outfit.lookTypeEx)
	else
		msg:addByte(outfit.lookHead)
		msg:addByte(outfit.lookBody)
		msg:addByte(outfit.lookLegs)
		msg:addByte(outfit.lookFeet)
		msg:addByte(outfit.lookAddons)
	end
end

function Player:reloadPreySlot(slotId)
	local slot = self:getPreyData(slotId)
	if not slot then
		return
	end
	
	local response = NetworkMessage()
	response:addByte(0xE8)
	response:addByte(slotId)
	response:addByte(slot.state)
	
	if slot.state == PreyDataState.Locked then
		response:addByte(self:isPremium() and 1 or 0)
	elseif slot.state == PreyDataState.Active then
		local monsterType = MonsterType(slot.preyMonster)
		if monsterType then
			response:addString(monsterType:getName())
			sendMonsterOutfit(response, monsterType)
			response:addByte(slot.bonusType)
			response:addU16(slot.bonusValue)
			response:addByte(slot.bonusGrade)
			response:addU16(slot.timeLeft)
		end
	elseif slot.state == PreyDataState.Selection then
		response:addByte(#slot.preyList)
		for _, monsterName in pairs(slot.preyList) do
			local monsterType = MonsterType(monsterName)
			if monsterType then
				response:addString(monsterType:getName())
				sendMonsterOutfit(response, monsterType)
			end
		end
	elseif slot.state == PreyDataState.SelectionChangeMonster then
		response:addByte(slot.bonusType)
		response:addU16(slot.bonusValue)
		response:addByte(slot.bonusGrade)
		response:addByte(#slot.preyList)
		for _, monsterName in pairs(slot.preyList) do
			local monsterType = MonsterType(monsterName)
			if monsterType then
				response:addString(monsterType:getName())
				sendMonsterOutfit(response, monsterType)
			end
		end
	elseif slot.state == PreyDataState.ListSelection then
		local bestiaryClasses = Game.getBestiary()
		local monsterList = {}
		for _, class in pairs(bestiaryClasses) do
			for _, monsterType in pairs(class.monsterTypes) do
				local info = monsterType:getBestiaryInfo()
				table.insert(monsterList, info.raceId)
			end
		end
		response:addU16(#monsterList)
		for _, raceId in pairs(monsterList) do
			response:addU16(raceId)
		end
	end
	
	local freeRerollTime = self:getFreeRerollTime(slotId)
	local timeLeft = freeRerollTime * 60
	response:addU32(timeLeft)
	response:addByte(0) -- Option (not supported in simple C++ binding mostly, defaulting to 0)
	
	response:sendToPlayer(self)
	response:delete()
end
