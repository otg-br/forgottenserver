local handler = PacketHandler(0xED)

function handler.onReceive(player, msg)
	local RESOURCE_BANK = 0
	local RESOURCE_INVENTORY = 1
	local RESOURCE_PREY_CARDS = 2
	local RESOURCE_TASK_HUNTING = 3
	
	local function sendResource(resourceType, value)
		local resourceMsg = NetworkMessage()
		resourceMsg:addByte(0xEE)
		resourceMsg:addByte(resourceType)
		resourceMsg:addU64(value)
		resourceMsg:sendToPlayer(player)
		resourceMsg:delete()
	end
	
	sendResource(RESOURCE_BANK, player:getBankBalance())
	sendResource(RESOURCE_INVENTORY, player:getMoney())
	sendResource(RESOURCE_PREY_CARDS, player:getPreyWildcards())
	sendResource(RESOURCE_TASK_HUNTING, 0)
	
	for slotId = 0, PreyConfig.maxSlots - 1 do
		local slot = player:getPreyData(slotId)
		if not slot then
			return
		end
		
		local preyMsg = NetworkMessage()
		preyMsg:addByte(0xE8)
		preyMsg:addByte(slotId)
		preyMsg:addByte(slot.state)
		
		if slot.state == 0 then
			preyMsg:addByte(player:isPremium() and 1 or 0)
		elseif slot.state == 2 then
			preyMsg:addString(slot.preyMonster)
			
			local mType = MonsterType(slot.preyMonster)
			if mType then
				local outfit = mType:getOutfit()
				preyMsg:addU16(outfit.lookType)
				if outfit.lookType == 0 then
					preyMsg:addU16(outfit.lookTypeEx or 0)
				else
					preyMsg:addByte(outfit.lookHead)
					preyMsg:addByte(outfit.lookBody)
					preyMsg:addByte(outfit.lookLegs)
					preyMsg:addByte(outfit.lookFeet)
					preyMsg:addByte(outfit.lookAddons)
				end
			else
				preyMsg:addU16(0)
				preyMsg:addU16(0)
			end
			
			preyMsg:addByte(slot.bonusType)
			preyMsg:addU16(slot.bonusValue)
			preyMsg:addByte(slot.bonusGrade)
			preyMsg:addU16(slot.timeLeft)
		elseif slot.state == 3 then
			preyMsg:addByte(#slot.preyList)
			for _, monsterName in ipairs(slot.preyList) do
				local mType = MonsterType(monsterName)
				if mType then
					preyMsg:addString(monsterName)
					local outfit = mType:getOutfit()
					preyMsg:addU16(outfit.lookType)
					if outfit.lookType == 0 then
						preyMsg:addU16(outfit.lookTypeEx or 0)
					else
						preyMsg:addByte(outfit.lookHead)
						preyMsg:addByte(outfit.lookBody)
						preyMsg:addByte(outfit.lookLegs)
						preyMsg:addByte(outfit.lookFeet)
						preyMsg:addByte(outfit.lookAddons)
					end
				end
			end
		end
		
		local freeRerollTimeSeconds = player:getFreeRerollTime(slotId) * 60
		preyMsg:addU32(freeRerollTimeSeconds)
		preyMsg:addByte(0)
		
		preyMsg:sendToPlayer(player)
		preyMsg:delete()
	end
	
	local rerollPrice = PreyConfig.rerollPrice + (player:getLevel() * PreyConfig.rerollPricePerLevel)
	local pricesMsg = NetworkMessage()
	pricesMsg:addByte(0xE9)
	pricesMsg:addU32(rerollPrice)
	pricesMsg:addByte(PreyConfig.bonusRerollPrice)
	pricesMsg:addByte(PreyConfig.selectionListPrice)
	pricesMsg:addU32(0)
	pricesMsg:addU32(0)
	pricesMsg:addByte(0)
	pricesMsg:addByte(0)
	pricesMsg:sendToPlayer(player)
	pricesMsg:delete()
end

handler:register()
