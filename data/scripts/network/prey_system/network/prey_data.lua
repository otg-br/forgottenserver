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

local handler = PacketHandler(0xE8)

function handler.onReceive(player, msg)
	local slotId = msg:getByte()
	local slot = PreyHelper.getSlotData(player, slotId)
	
	if not slot then
		slot = {
			id = slotId,
			state = PreyDataState.Locked,
			selectedRaceId = 0,
			bonus = PreyBonus.None,
			bonusPercentage = 0,
			bonusRarity = 0,
			bonusTimeLeft = 0,
			raceIdList = {},
			freeRerollTime = 0,
			option = 0
		}
	end
	
	local response = NetworkMessage()
	response:addByte(0xE8)
	response:addByte(slot.id)
	response:addByte(slot.state)
	
	if slot.state == PreyDataState.Locked then
		response:addByte(player:isPremium() and 1 or 0)
	elseif slot.state == PreyDataState.Active then
		local monsterType = MonsterType(slot.selectedRaceId)
		if monsterType then
			response:addString(monsterType:getName())
			sendMonsterOutfit(response, monsterType)
			response:addByte(slot.bonus)
			response:addU16(slot.bonusPercentage)
			response:addByte(slot.bonusRarity)
			response:addU16(slot.bonusTimeLeft)
		end
	elseif slot.state == PreyDataState.Selection then
		response:addByte(#slot.raceIdList)
		for _, raceId in pairs(slot.raceIdList) do
			local monsterType = MonsterType(raceId)
			if monsterType then
				response:addString(monsterType:getName())
				sendMonsterOutfit(response, monsterType)
			end
		end
	elseif slot.state == PreyDataState.SelectionChangeMonster then
		response:addByte(slot.bonus)
		response:addU16(slot.bonusPercentage)
		response:addByte(slot.bonusRarity)
		response:addByte(#slot.raceIdList)
		for _, raceId in pairs(slot.raceIdList) do
			local monsterType = MonsterType(raceId)
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
	
	local currentTime = os.time()
	local timeLeft = math.max(0, slot.freeRerollTime - currentTime)
	response:addU32(timeLeft)
	response:addByte(slot.option)
	
	response:sendToPlayer(player)
	response:delete()
end

handler:register()
